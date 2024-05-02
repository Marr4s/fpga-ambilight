`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2023 11:41:05 AM
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


module get_average #(
parameter v_pix = 1080,
    parameter h_pix = 1920,
    parameter num_h = 10,
    parameter num_v = 5
)(
    input clk,
    input [23:0] rbg,
    input [15:0] h_cnt,
    input [15:0] v_cnt,
    input p_valid,
    input v_sync,
    output [23:0] avg_rgb,
    
    output trig,
    input nxt,
    input t_valid,
    input rdy

    );
    wire [23:0] rgb;
    
    assign rgb = {rbg[23:16], rbg[7:0], rbg[15:8]};
    
    get_average_sv #(
      .v_pix(v_pix),
      .h_pix(h_pix),
      .num_h(num_h),
      .num_v(num_v)
    ) inst_ave (
      .clk(clk),
      .rgb(rgb),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt),
      .p_valid(p_valid),
      .v_sync(v_sync),
      .avg_rgb(avg_rgb),
      .trig(trig),
      .nxt_in(nxt),
      .t_valid_in(t_valid),
      .rdy(rdy)
    );
endmodule
