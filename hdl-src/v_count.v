`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2022 01:08:08 PM
// Design Name: 
// Module Name: v_count
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


module v_count(
    input clk,
    input valid,
    input vsync,
    output wire [15:0] o_v_cnt,
    output wire [15:0] o_h_cnt
    );
    
    reg d_vsync;
    reg d_valid;
    reg [15:0] v_cnt;
    reg [15:0] h_cnt;
    reg init;
    
    assign o_v_cnt = v_cnt;
    assign o_h_cnt = valid == 1 ? h_cnt : 0;
    
    always @(posedge clk) begin
      // detect rising edges
      d_vsync <= vsync;
      d_valid <= valid;
    end
    
    always @(posedge clk) begin
      if(d_vsync == 0 && vsync == 1) begin
        // new frame
        v_cnt <= 0;
      end
      if(d_valid == 1 && valid == 0) begin
        // new line
        v_cnt <= v_cnt + 1;
        h_cnt <= 0;
      end else if(valid == 1) begin
        h_cnt <= h_cnt + 1;
      end
    end
endmodule
