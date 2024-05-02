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


module get_average_sv #(
    parameter v_pix = 1080,
    parameter h_pix = 1920,
    parameter num_h = 19,
    parameter num_v = 11,
    parameter cnt4pixavg = 64,
    localparam X_BITS = $clog2(cnt4pixavg), // extra bits needed for sum calculation
    localparam MAX_DIST = cnt4pixavg>>($clog2(cnt4pixavg)/2)  // Calc squareroot of pix - only works for every second power of two (4, 16, 64, ..)
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
    input rdy
    );
    
    // check parameter
    if (cnt4pixavg != 4 && cnt4pixavg != 16 && cnt4pixavg != 64 && cnt4pixavg != 256 && cnt4pixavg != 1024 && cnt4pixavg != 4096)
        $error($sformatf("Illegal values for parameters cnt4pixavg (%0d). Use 4, 16, 64, 256, 1024 or 4096.", cnt4pixavg));
    
    localparam pix_h = h_pix/num_h;
    localparam pix_v = v_pix/num_v;
    localparam num_leds = num_h+2*num_v-2;
    
    // fill lut for pixel center positions
    reg [num_leds:0] [1:0] [15:0] led_pos_lut; // led - x/y - coords
    initial begin
      integer i;
      for(i = 0; i<num_leds; i=i+1) begin
        if(i < num_v) begin
          // left edge
          led_pos_lut[i][0] = 0;
          led_pos_lut[i][1] = v_pix-pix_v*i-pix_v/2;
        end else if(i > num_v+num_h-2) begin
          // right edge
          led_pos_lut[i][0] = h_pix-1;
          led_pos_lut[i][1] = pix_v/2+pix_v*(i-num_v-num_h+2);
        end else begin
          // top
          led_pos_lut[i][0] = pix_h/2+pix_h*(i-num_v+1);
          led_pos_lut[i][1] = 0;
        end
      end
    end
    
    wire [7:0] h_pos, v_pos;// current sector position
    wire [7:0] led_id;      // current led based on sector
    reg [15:0] x_dist;      // x distance from selected led (led_id) to current position
    reg [15:0] y_dist;      // y distance from selected led (led_id) to current position
    
    reg d_vsync;            // delayed vsync for edge detetection
    reg [7:0] out_cnt = num_leds;   // track which led's rgb value is currently forwarded
    
    // handshake cdc to data gen module
    reg t_valid_reg, t_valid;
    reg nxt_reg, nxt;
    
    // capture values in case distance calculation is valid
    reg [23:0] rgb_delayed;
    reg [7:0] led_id_delayed;
    reg buf_valid;
    
    // rgb sum buffers
    reg [num_leds:0] [7+X_BITS:0] r_sum;
    reg [num_leds:0] [7+X_BITS:0] g_sum;
    reg [num_leds:0] [7+X_BITS:0] b_sum;
    
    // buffer final sum which is used for leds
    reg [num_leds:0] [7+X_BITS:0] out_r_sum;
    reg [num_leds:0] [7+X_BITS:0] out_g_sum;
    reg [num_leds:0] [7+X_BITS:0] out_b_sum;

    // current sector
    assign h_pos = h_cnt/pix_h;
    assign v_pos = v_cnt/pix_v;
    
    /**************************
    * ex: for num_v=3, num_h=5
    * 2 3 4 5 6
    * 1       7
    * 0       8
    * --> 0-2 first condition, 3-6 second condition, 7-8 third condition
    ***************************/
    assign led_id = (h_pos == 0)       ? num_v-v_pos-1 : // left edge
                    (v_pos == 0)       ? num_v+h_pos-1 : // upper border
                    (h_pos == num_h-1) ? num_v+h_pos+v_pos-1 : // right border                 
                    8'hFF; // invalid area -> only look at edges
    
    // vsync edge detection:
    // - rising edge: start forwarding data to led
    // - falling edge: reset buffers for next frame
    always @(posedge clk) begin
        d_vsync <= v_sync;
    end
    
    // rgb capture logic
    always @(posedge clk) begin
      buf_valid <= 0;
        
      // buffer values for this cycle
      if(led_id < num_leds && p_valid) begin
        x_dist <= (led_pos_lut[led_id][0]>h_cnt)?(led_pos_lut[led_id][0] - h_cnt):(h_cnt - led_pos_lut[led_id][0]);
        y_dist <= (led_pos_lut[led_id][1]>v_cnt)?(led_pos_lut[led_id][1] - v_cnt):(v_cnt - led_pos_lut[led_id][1]);
        rgb_delayed <= rgb;
        led_id_delayed <= led_id;
        buf_valid <= 1'b1;
      end
        
      // process data from previous cycle
      if(buf_valid) begin
        // calculate sum if distance is ok
        if(x_dist+y_dist<MAX_DIST) begin
          r_sum[led_id_delayed] <= r_sum[led_id_delayed] + rgb_delayed[23:16];
          g_sum[led_id_delayed] <= g_sum[led_id_delayed] + rgb_delayed[15:8];
          b_sum[led_id_delayed] <= b_sum[led_id_delayed] + rgb_delayed[7:0];
        end
      end
        
      // new frame, reset buffer
      if(d_vsync == 1 && v_sync == 0) begin
        r_sum <= 0;
        g_sum <= 0;
        b_sum <= 0;
      end
    end
    
    // data ack cdc 
    always @(posedge clk) begin
      {t_valid, t_valid_reg} <= {t_valid_reg, t_valid_in};
      {nxt, nxt_reg} <= {nxt_reg, nxt_in};
    end
    
    // data out logic
    always @(posedge clk) begin
      // update after full frame but only if transmission is done
      if((d_vsync == 0) && (v_sync == 1) && (out_cnt == num_leds) && rdy) begin
        out_r_sum <= r_sum;
        out_g_sum <= g_sum;
        out_b_sum <= b_sum;
        out_cnt <= 0;
      end
      else if(out_cnt < num_leds) begin
        // only take top bits for avg division (bit shift)
        avg_rgb[23:16] <= out_r_sum[out_cnt][X_BITS+7:X_BITS];
        avg_rgb[15:8] <= out_g_sum[out_cnt][X_BITS+7:X_BITS];
        avg_rgb[7:0] <= out_b_sum[out_cnt][X_BITS+7:X_BITS];
        if(nxt) trig <= 1;
        if(t_valid && trig) begin
          trig <= 0;
          out_cnt <= out_cnt + 1;
        end
      end
      else // out_cnt > num_leds -> error, should never happen!
        out_cnt <= num_leds;
    end


endmodule
