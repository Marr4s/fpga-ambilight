`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2022 02:04:51 PM
// Design Name: 
// Module Name: get_average
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// TODO: more control/handshake: when is rgb value valid, when should we forward a new avg_rgb, ...

module get_average_sv #(
    parameter v_pix = 1080,
    parameter h_pix = 1920,
    parameter num_h = 10,
    parameter num_v = 5
)(
    input clk,
    
    // data stream interface
    input [23:0] rgb,
    input [15:0] h_cnt,
    input [15:0] v_cnt,
    input v_sync,
    input p_valid,
    
    // data gen interface
    output reg [23:0] avg_rgb,
    output reg trig,
    input nxt_in,
    input t_valid_in,
    input rdy,
    
    // debug
    output [7:0] deb_h_pos,
    output [7:0] deb_v_pos,
    output [7:0] deb_out_cnt,
    output [7:0] led_id
    );
    
    localparam pix_h = h_pix/num_h;
    localparam pix_v = v_pix/num_v;
    localparam num_leds = num_h+2*num_v-2;
    
    wire [7:0] h_pos, v_pos; // current position
    wire [7:0] led_id; // led_id
    reg [7:0] d_led_id;
    reg rst;
    
    wire [15:0] cur_cnt;
    reg [15:0] new_cnt;
    reg [7:0] new_r, new_g, new_b;
    
    wire [7:0] w_r_ave, w_g_ave, w_b_ave;
    
    reg [num_leds:0] [23:0] rgb_buffer;
    reg [num_leds:0] [23:0] out_rgb_buffer;
    reg [num_leds:0] [15:0] cnt_buffer;
    
    reg d_vsync;
    reg [7:0] out_cnt = num_leds; // TODO determine size based on number leds
    
    reg t_valid_reg, t_valid;
    reg nxt_reg, nxt;
    
    assign h_pos = h_cnt/pix_h;
    assign v_pos = v_cnt/pix_v;
    
    // DEBUG
    assign deb_h_pos = h_pos;
    assign deb_v_pos = v_pos;
    assign deb_out_cnt = out_cnt;
    
    /* ex: for num_v=3, num_h=5
    * 2 3 4 5 6
    * 1       7
    * 0       8
    * --> 0-2 first condition, 3-6 second condition, 7-8 third condition
    */
    assign led_id = (h_pos == 0)       ? num_v-v_pos-1 : // left edge
                    (v_pos == 0)       ? num_v+h_pos-1 : // upper border
                    (h_pos == num_h-1) ? num_v+h_pos+v_pos-1 : // right border                 
                    8'hFF; // invalid area -> only look at edges
    
    // pixel capture control logic
    always @(posedge clk) begin
      rst <= 0;
      d_led_id <= led_id;
      // do register updates if led_id changes
      if(d_led_id != led_id) begin
        // update old led_id values
        if(d_led_id < num_leds) begin
          rgb_buffer[d_led_id] <= {w_r_ave, w_g_ave, w_b_ave};
          cnt_buffer[d_led_id] <= cur_cnt;
        end
        
        // init new averages
        if(led_id < num_leds) begin
          new_cnt <= cnt_buffer[led_id];
          new_r <= rgb_buffer[led_id][23:16];
          new_g <= rgb_buffer[led_id][15:8];
          new_b <= rgb_buffer[led_id][7:0];
          rst <= 1;
        end
      end
      
      // new frame, reset buffer
      d_vsync <= v_sync;
      if(d_vsync == 1 && v_sync == 0) begin
        rgb_buffer <= 0;
        cnt_buffer <= 0;
        new_cnt <= 0;
        new_r <= 0;
        new_g <= 0;
        new_b <= 0;
        rst <= 1;
      end
    end
    
    // data ack cdc 
    always @(posedge clk) begin
      {t_valid, t_valid_reg} <= {t_valid_reg, t_valid_in};
      {nxt, nxt_reg} <= {nxt_reg, nxt_in};
    end
    
    // data out logic
    // TODO: do we need more than one frame to send rgb values to led strip --> dont do it every frame
    always @(posedge clk) begin
      // update after full frame but only if transmission is done
      if((d_vsync == 0) && (v_sync == 1) && (out_cnt == num_leds) && rdy) begin// TODO: choose different time? (falling v_valid, ...) before reseting in above logic
        out_rgb_buffer <= rgb_buffer;
        out_cnt <= 0;
      end
      else if(out_cnt < num_leds) begin
        avg_rgb <= out_rgb_buffer[out_cnt];
        if(nxt) trig <= 1;
        if(t_valid && trig) begin
          trig <= 0;
          out_cnt <= out_cnt + 1;
        end
        // TODO: what if rdy in middle of transmission?
      end
      else // out_cnt > num_leds -> error should never happen!
        out_cnt <= num_leds;
    end
    
    // TODO: when trigger data send out (as soon as v_valid low)? done with rising v_sync
    // TODO: when reset avg buffer (as soon as new frame announced (v_sync))? done with falling v_sync
    // TODO: when to update moving averages (only if h_valid and v_valid (clk*h/v_valid))? done with p_valid
    
    // TODO: don't do this every clock cylce if not h/v_valid
    MovingAverage inst_r_ave (
      .clk(clk),
      .rst(rst),
      .value(rgb[23:16]),
      .p_valid(p_valid),
      .init_count(new_cnt),
      .init_average(new_r),
      .count(cur_cnt),
      .average(w_r_ave)
    );
    
    MovingAverage inst_g_ave (
      .clk(clk),
      .rst(rst),
      .value(rgb[7:0]),
      .p_valid(p_valid),
      .init_count(new_cnt),
      .init_average(new_g),
      .count(),
      .average(w_g_ave)
    );
    
    MovingAverage inst_b_ave (
      .clk(clk),
      .rst(rst),
      .value(rgb[15:8]),
      .p_valid(p_valid),
      .init_count(new_cnt),
      .init_average(new_b),
      .count(),
      .average(w_b_ave)
    );
    

endmodule

// Include intermediate value if we get back to area, buffer count?
// TODO: only one instance for rgb (thus only e.g. one count reg)
module MovingAverage(
  input wire clk,
  input wire rst,
  input wire [7:0] value,
  input wire p_valid,
  input wire [15:0] init_count,
  input wire [7:0] init_average,
  output wire [15:0] count,
  output wire [7:0] average
);

  reg [15:0] count_reg;
  reg [15:0] prev_average;

  always @(posedge clk) begin
    if (rst) begin
      count_reg <= init_count;
      prev_average <= init_average;
    end else if(p_valid) begin
      count_reg <= count_reg + 1;
      prev_average <= prev_average + ((value - prev_average) / count_reg);
    end
  end

  assign average = prev_average;
  assign count = count_reg;

endmodule

