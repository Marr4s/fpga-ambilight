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
    input clk_100mhz,
    output wire d_out,
    input reset,
    
    input [7:0] red,
    input [7:0] green,
    input [7:0] blue,
    
    input trig_in,
    output nxt_out,
    output wire t_valid,
    output wire rdy
    );
    
    // 1 clk -> 0.01us
    localparam T0H=40; //0.4us -> 40 clocks
    localparam T1H=80; // 0.8us -> 80 clocks
    localparam T0L=85; // 0.85us -> 85 clocks
    localparam T1L=45; // 0.45us -> 45 clocks
    // reset after 50us (5000 clocks) - 300us
    localparam minTres=2500; // consider 25us as safe to continue with previous stream
    localparam Tres=40000; // consider 400us as safe for new data
    
    localparam IDLE=4'b0000, TRANS=4'b0001, TRANS0=4'b0010, TRANS1=4'b0011, UPDATE=4'b0100, FIN=4'b0101; 
    
    reg [15:0] counter; // 0-65000
    reg [3:0] state, l_state;
    reg i_out;
    reg trig_reg, trig, d_trig;
    reg [7:0] idx;
    reg [23:0] buf_color;
    reg [23:0] cur_color = {24'hFFFFFF}; //GRB
    reg buf_up;  // buffer got updated to, buf_color available again
    reg nxt;
    
    assign d_out = i_out;
    assign rdy = (state == IDLE);
    
    // cdc of trigger
    always @(posedge clk_100mhz) begin
	  { trig, trig_reg } <= { trig_reg, trig_in };
	end
    
    // Fill color buffer if there is new data
    assign t_valid = d_trig;
    assign nxt_out = nxt & !t_valid;
    always @(posedge clk_100mhz) begin
      if(d_trig == 0 && trig == 1 && (nxt || rdy)) begin
        buf_color <= {green, red, blue};
        nxt <= 0;
      end
      else if(buf_up) nxt <= 1;
      //else if(state == FIN) nxt <= 0;
      //else if(rdy) nxt <= 1;
      
      d_trig <= trig;
    end
    
    // state counter logic 
    always @(posedge clk_100mhz) begin
      if(l_state != state) counter <= 0;
      else counter <= counter + 1;

      l_state <= state;
    end
    
    
    always @(posedge clk_100mhz) begin
      buf_up <= 0;
      if(reset) begin
        state <= IDLE;
        i_out <= 0;
        idx <= 23;
      end
      else begin
        case(state)
          IDLE: begin
            i_out <= 0;
            if(nxt == 0) begin // new data available
              state <= TRANS;
              cur_color <= buf_color;
              buf_up <= 1;
              idx <= 23;
            end
          end
          TRANS: begin
            i_out <= 0;
            if(cur_color[idx] == 1'b0) state <= TRANS0;
            else state <= TRANS1;
          end
          TRANS0: begin
            if(counter < T0H) i_out <= 1;
            else i_out <= 0;
            if(counter >= T0H+T0L-3) state <= UPDATE;
          end
          TRANS1: begin
            if(counter < T1H) i_out <= 1;
            else i_out <= 0;
            if(counter >= T1H+T1L-3) state <= UPDATE;
          end
          UPDATE: begin
            i_out <= 0;
            if(idx == 0) begin
              if(nxt == 0) begin
                idx <= 23;
                cur_color <= buf_color;
                buf_up <= 1;
                state <= TRANS;
              end else if(counter > minTres) state <= FIN;
            end
            else begin 
              idx <= idx-1;
              state <= TRANS;
            end
          end
          FIN: begin
            i_out <= 0;
            buf_up <= 1; // clear buffer
            if(counter > Tres - minTres) state <= IDLE;
          end
        endcase
      end
    end
    
endmodule
