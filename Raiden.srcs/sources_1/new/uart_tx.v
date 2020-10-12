//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
`define UART_FULL_ETU	(`SYSTEM_CLOCK/115200)
`define UART_HALF_ETU	((`SYSTEM_CLOCK/115200)/2)

module  uart_tx (
  input wire       clk,
  output reg       dout = 1'b1,
  input wire [7:0] data_in,
  input wire       en,
  output reg       rdy = 1'b1
);

parameter UART_START  = 3'b000;
parameter UART_DATA   = 3'b001;
parameter UART_STOP   = 3'b010;
parameter UART_IDLE   = 3'b011;

reg [2:0] state = UART_START;
reg [9:0] etu_cnt = 10'd0;
reg [2:0] bit_index = 3'd0;

wire etu_full;
assign etu_full = (etu_cnt == `UART_FULL_ETU);

always  @ (posedge clk)
//begin
//  if (rst)
//    begin
//      state <= UART_START;
//      dout <= 1'b1;
//      rdy <= 1'b1;
//    end
//  else
    begin
        // Default assignments
      etu_cnt <= (etu_cnt + 1'b1);
      dout <= dout;
      rdy <= rdy;
      state <= state;
      case(state)
            // Idle, waiting for enable
        UART_START:
          begin
            if(en)
              begin
                    // Start bit
                dout <= 1'b0;
                state <= UART_DATA;
                etu_cnt <= 9'd0;
                rdy <= 1'b0;
              end
            end
            // Data Bits
        UART_DATA:
          if(etu_full)
            begin
              dout  <= data_in[bit_index];
              etu_cnt <= 0;    
                 // Check if we have sent out all bits
              if (bit_index < 7)
                begin
                  bit_index <= bit_index + 1;
                  state <= UART_DATA;
                end
              else
                begin
                  bit_index <= 0;
                  state <= UART_STOP;
                end
            end
            // Stop Bit(s)
       UART_STOP:
        if(etu_full)
          begin
            etu_cnt <= 9'd0;
            dout <= 1'b1;
            state <= UART_IDLE;
          end
            // Idle time before restarting
       UART_IDLE:
        if(etu_full)
          begin
            rdy <= 1'b1;
            state <= UART_START;
          end
       default:
        $display ("UART TX: Invalid state 0x%X", state);
     endcase
   end
//end

endmodule