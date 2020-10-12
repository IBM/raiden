`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2019 03:23:20 PM
// Design Name: 
// Module Name: uart_rx_tb
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
// 115200 8N1

module uart_rx_tb();

parameter c_CLOCK_PERIOD_NS = 10;
parameter c_CLKS_PER_BIT    = 868;
parameter c_BIT_PERIOD      = 8600;

reg clk = 1'b0;
parameter UART_FULL_ETU = 100_000_000/115200;

always
begin
    #(c_CLOCK_PERIOD_NS/2) clk <= !clk;
end

reg   rst = 0;
reg   din = 0;
reg  [7:0] tx_byte_out = 0;
wire [7:0] rx_byte_in;
wire  valid;

task UART_WRITE_BYTE;
  input [7:0] i_Data;
  integer     i;
  begin   
    // Send Start Bit
    din <= 1'b0;
    #(c_BIT_PERIOD);
    #1000;
    // Send Data Byte
    for (i=0; i<8; i=i+1)
      begin
        din <= i_Data[i];
        #(c_BIT_PERIOD);
      end 
    // Send Stop Bit
    din <= 1'b1;
    #(c_BIT_PERIOD);
   end
endtask // UART_WRITE_BYTE
 
  uart_rx  uart_rxi
  (.clk(clk),
   .din(din),
   .data_out(rx_byte_in),
   .valid(valid)
   );
   
   wire tx_rdy;
   wire dout;
   
   reg tx_en = 1'b0;
   uart_tx uart_txi
   (.clk(clk),
    .data_in(tx_byte_out),
    .dout(dout),
    .en(tx_en),
    .rdy(tx_rdy)
    );

initial
  begin
  @(posedge clk);
  @(posedge clk);
  tx_en <= 1'b1;
  tx_byte_out <= 8'd67;
  @(posedge clk);
  tx_en <= 1'b0;
  @(posedge clk);
    UART_WRITE_BYTE(8'd67);
    if (rx_byte_in == 8'd67)
      $display("Test Passed - Correct Byte Received");
    else
      $display("Test Failed - Incorrect Byte Received");
    $finish();
  end

endmodule
