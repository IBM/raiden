`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2020 06:10:28 AM
// Design Name: 
// Module Name: pwm
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


module pwm(
 input clk,
 input [7:0] duty,
 input  signal,
 output reg state = 1'b0
 );

 reg [7:0] counter = 0;

 always @ (posedge clk)
  begin
    state <= 1'b0;
    if(counter == duty)
      begin
        state <= signal;
        counter <= 8'd0;
      end
    else
      begin
        counter <= counter + 1;
      end
  end
endmodule
