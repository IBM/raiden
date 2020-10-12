`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2019 10:58:32 AM
// Design Name: 
// Module Name: resetter_tb
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


module resetter_tb();

reg clk = 1'b0;
reg  rst = 1'b0;
wire rst_out;
reg [31:0] delay;
resetter rsti
(
  .clk(clk),
  .rst(rst),
  .en_rst(rst_out),
  .reset_delay(delay)
);

always
  begin
    #5 clk <= !clk;
  end
initial
  begin
    @(posedge clk);
      #1000
      delay <= 32'd80;
      rst <= 1'b1;
      $display("RST DELAY: %h", delay);
      $display("RST OUT with RST singal ON: %b", rst_out);
    @(posedge clk);
       #1000      
       rst <= 1'b0;
       $display("RST OUT with RST singal OFF: %b", rst_out);
    $finish();
  end

endmodule
