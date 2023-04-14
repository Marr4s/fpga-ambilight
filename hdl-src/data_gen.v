`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2022 04:27:01 PM
// Design Name: 
// Module Name: data_gen
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


module data_gen(
    input clk,
    output wire d_out,
    input reset,
    
    input [7:0] red,
    input [7:0] green,
    input [7:0] blue,
    
    input trig
    );
    
    // 1 clk -> 0.01us
    localparam T0H=40; //0.4us -> 40 clocks
    localparam T1H=80; // 0.8us -> 80 clocks
    localparam T0L=85; // 0.85us -> 85 clocks
    localparam T1L=45; // 0.45us -> 45 clocks
    // reset 50us -> 5000 clocks (*10 to be safe)
    localparam Tres=50000;
    
    localparam IDLE=4'b0000, TRANS=4'b0001, TRANS0=4'b0010, TRANS1=4'b0011, UPDATE=4'b0100, FIN=4'b0101; 
    
    reg [15:0] counter; // 0-65000
    reg [3:0] state;
    reg i_out;
    reg d_trig;
    reg [7:0] idx;
    //reg [47:0] color = {24'hCB2C21, 24'h66B2FF}; //GRB
    reg [23:0] color = {24'hFFFFFF}; //GRB
    
    assign d_out = i_out;
    
    always @(posedge clk) begin
      d_trig <= trig;
    end
    
    always @(posedge clk) begin
      if(reset) begin
        state <= IDLE;
        counter <= 0;
        i_out <= 0;
        idx <= 23;
      end
      else begin
        //color <= {24'hCB2C21, 24'h66B2FF};
        color <= {green, red, blue};
        case(state)
          IDLE: begin
            i_out <= 0;
            if(d_trig == 0 && trig == 1) begin
              state <= TRANS;
              counter <= 0;
              idx <= 23;
            end
          end
          TRANS: begin
            i_out <= 0;
            if(color[idx] == 1'b0) state <= TRANS0;
            else state <= TRANS1;
          end
          TRANS0: begin
            counter <= counter+1;
            if(counter < T0H) i_out <= 1;
            else i_out <= 0;
            if(counter >= T0H+T0L-3) state <= UPDATE;
          end
          TRANS1: begin
            counter <= counter+1;
            if(counter < T1H) i_out <= 1;
            else i_out <= 0;
            if(counter >= T1H+T1L-3) state <= UPDATE;
          end
          UPDATE: begin
            i_out <= 0;
            counter <= 0;
            if(idx == 0) state <= FIN;
            else begin 
              idx <= idx-1;
              state <= TRANS;
            end
          end
          FIN: begin
            i_out <= 0;
            counter <= counter+1;
            if(counter > Tres) state <= IDLE;
          end
        endcase
      end
    end
    
endmodule
