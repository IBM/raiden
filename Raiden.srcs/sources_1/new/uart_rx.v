//////////////////////////////////////////////////////////////////////////////////
// Company:  X-Force RED
// Engineer: h0rac
// 
// Create Date: 10/31/2019 05:44:22 AM
// Design Name: 
// Module Name: trigger
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Created by chip.fail guys - Modified by h0rac 
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

`define SYSTEM_CLOCK    100_000_000
// 115200 8N1
`define CLKS_PER_BIT	(`SYSTEM_CLOCK/115200)
`define CLKS_PER_BIT_HALF	((`SYSTEM_CLOCK/115200)/2)

module  uart_rx (
    input wire          clk,
    input wire          rst,
    input wire          din,
    input wire [31:0]   baud,
    output reg [7:0]    data_out = 0,
    output reg          valid = 0
);

parameter START_BIT  = 3'b000;
parameter RX_BITS   = 3'b001;
parameter STOP_BIT   = 3'b010;

reg [2:0]   state = START_BIT;
reg [2:0]   bit_cnt = 3'b0;
reg [9:0]   etu_cnt = 10'd0;
reg [2:0]   bit_index = 3'd0;


wire etu_full, etu_half;
assign etu_full = (etu_cnt == (`SYSTEM_CLOCK/baud));
assign etu_half = (etu_cnt == ((`SYSTEM_CLOCK/baud)/2));

always  @ (posedge clk)
begin
  if (rst)
    begin
      state <= START_BIT;
    end
  else
    begin
  // Default assignments
      valid <= 1'b0;
      etu_cnt <= (etu_cnt + 1'b1);
      state <= state;
      data_out <= data_out;
    case(state)
      START_BIT:
        begin
           if(din == 1'b0)
           begin
             // wait .5 ETUs
             if(etu_half)
              begin
               state <= RX_BITS;
               etu_cnt <= 10'd0;
               data_out <= 8'd0;
              end
             end
               else
                etu_cnt <= 10'd0;
              end
              // Data Bits
     RX_BITS:
       if(etu_full)
       begin
         etu_cnt <= 0;
         data_out[bit_index] <= din;
         if (bit_index < 7)
           begin
             bit_index <= bit_index + 1;
             state <= RX_BITS;
           end
         else
           begin
             bit_index <= 0;
             state<= STOP_BIT;
           end
         end
     STOP_BIT:
      if(etu_full)
       begin
        etu_cnt <= 10'd0;
        state <= START_BIT;
        valid <= din;
      end
    default:
         $display ("UART RX: Invalid state 0x%X", state);
    endcase
  end
end

endmodule