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
    input [23:0] rgb,
    input [15:0] h_cnt,
    input [15:0] v_cnt,
    output reg [23:0] avg_rgb,
    
    output [7:0] deb_h_pos,
    output [7:0] deb_v_pos,
    output [7:0] led_id
    );
    
    localparam pix_h = h_pix/num_h;
    localparam pix_v = v_pix/num_v;
    
    wire [7:0] h_pos, v_pos; // current position
    wire [7:0] led_id; // led_id
    reg [7:0] d_led_id;
    reg rst;
    
    wire [7:0] w_r_ave, w_g_ave, w_b_ave;
    
    reg [num_h+2*num_v:0] [23:0] rgb_buffer;
    
    assign h_pos = h_cnt/pix_h;
    assign v_pos = v_cnt/pix_v;
    
    // DEBUG
    assign deb_h_pos = h_pos;
    assign deb_v_pos = v_pos;
    
    /* ex: for num_v=3, num_h=5
    * 2 3 4 5 6
    * 1       7
    * 0       8
    * --> 0-2 first condition, 3-6 second condition, 7-8 third condition
    */
    assign led_id = (h_pos == 0)       ? num_v-v_pos-1 : // left edge
                    (v_pos == 0)       ? num_v+h_pos-1 : // upper border
                    (h_pos == num_h-1) ? num_v+h_pos+v_pos : // right border                 
                    8'hFF; // invalid area -> only look at edges
    
    // TODO: do we need more than one frame to send rgb values to led strip --> dont do it every frame
    always @(posedge clk) begin
      if(led_id < num_h+2*num_v) // only update if we are in a valid range
        rgb_buffer[led_id] <= {w_r_ave, w_g_ave, w_b_ave};
      
      //reset if we get to new id
      d_led_id <= led_id;  
      if(d_led_id != led_id) begin
        rst <= 1;
        if(d_led_id < num_h+2*num_v)
          avg_rgb <= rgb_buffer[d_led_id]; // TODO just for debug
      end else
        rst <= 0;
    end
    
    /*always @(posedge clk) begin
      if(v_cnt == 0 && h_cnt == 0) begin
        avg_rgb <= rgb;
      end
    end*/
    
    // TODO: don't do this every clock cylce
    MovingAverage inst_r_ave (
      .clk(clk),
      .rst(rst),
      .value(rgb[23:16]),
      .average(w_r_ave)
    );
    
    MovingAverage inst_g_ave (
      .clk(clk),
      .rst(rst),
      .value(rgb[7:0]),
      .average(w_g_ave)
    );
    
    MovingAverage inst_b_ave (
      .clk(clk),
      .rst(rst),
      .value(rgb[15:8]),
      .average(w_b_ave)
    );
    

endmodule

// Include intermediate value if we get back to area, buffer count?
module MovingAverage(
  input wire clk,
  input wire rst,
  input wire [7:0] value,
  output wire [7:0] average
);

  reg [15:0] count;
  reg [15:0] prev_average;

  always @(posedge clk) begin
    if (rst) begin
      count <= 0;
      prev_average <= 0;
    end else begin
      count <= count + 1;
      prev_average <= prev_average + ((value - prev_average) / count);
    end
  end

  assign average = prev_average;

endmodule

