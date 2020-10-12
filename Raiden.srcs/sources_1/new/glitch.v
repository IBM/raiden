`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: X-Force Red
// Engineer: Grzegorz Wypych (h0rac) & Adam Laurie (M@jor Malfunction)
// 
// Create Date: 10/31/2019 07:39:10 AM
// Design Name: 
// Module Name: glitch
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



module glitch(
  input clk,
  input rst,
  input enable,
  input wire [31:0] glitch_delay,
  input wire [31:0] glitch_width,
  input wire [31:0] glitch_count,
  input wire [31:0] glitch_gap,
  input wire [31:0] glitch_max,
  input wire [31:0] reset_target,
  output reg glitched = 1'b0,
  input wire vstart,
  output reg vout = 1'b1,
  output wire finished,
  output wire reset_out
    );
    
parameter DELAY = 3'b000;
parameter GLITCH = 3'b001;
parameter GAP = 3'b010;

  reg [31:0] width_cnt = 32'd0;
  reg [31:0] cnt = 32'd0;
  reg [31:0] cycles = 32'd0;
  reg [31:0] reset_cnt= 32'd0;
  
  reg [2:0] state = DELAY;
  
  assign finished = (glitch_max && cycles == glitch_max);
  assign reset_out = !enable || !reset_target || state != DELAY || (enable && reset_target && state == DELAY && reset_cnt == reset_target);
  
  always @(posedge clk)
  begin
    if(!enable)
      begin
         state <= DELAY;
         if(!glitched)
           begin
             vout <= vstart;
           end
         width_cnt <= 32'd0;
         cnt <= 32'd0;
      end
    if(rst)
      begin
        state <= DELAY;
        vout <= vstart;
        width_cnt <= 32'd0;
        cnt <= 32'd0;
        glitched <= 1'b0;
        cycles <= 32'b0;
        reset_cnt <= 32'b0;
      end
    if(enable)
    begin
      glitched <= 1'b1;
      case(state)
        DELAY:
          begin
            vout <= 1'b1;
            if(reset_target && reset_cnt < reset_target)
              begin
                reset_cnt <= reset_cnt + 32'b1;
              end
            if(width_cnt == glitch_delay)
              begin
                state <= GLITCH;
                vout <= 1'b0;
                width_cnt <= 32'd0;
                reset_cnt <= 32'd0;
              end
            else
              begin
                width_cnt <= width_cnt + 32'b1;
              end
          end
        GLITCH:
          begin
              if(width_cnt == glitch_width - 1 || glitch_width == 0)
                begin
                  width_cnt <= 32'd0;             
                  state <= GAP;
                  vout <= 1'b1;
                  cnt <= cnt + 32'b1;
                  if(cnt == glitch_count - 1)
                    begin
                      cnt <= 32'd0;
                      state <= DELAY;
                      vout <= 1'b1;
                      cycles <= cycles + 32'b1;
                    end
              end
            else
              begin
                width_cnt <= width_cnt + 32'b1;
              end
          end
        GAP:
          begin
            if(width_cnt == glitch_gap - 1 || glitch_gap == 0)
              begin
                width_cnt <= 32'd0;
                state <= GLITCH;
                vout <= 1'b0;
            end
          else
            begin
              width_cnt <= width_cnt + 32'b1;
            end
          end
        default:
          begin
          end
      endcase
    end
  end
endmodule