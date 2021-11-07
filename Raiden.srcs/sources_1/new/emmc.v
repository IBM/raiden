`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: PWNSec
// Engineer: Grzegorz Wypych (h0rac)
// 
// Create Date: 10/11/2021 10:55:49 PM
// Design Name: 
// Module Name: emmc
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


module emmc(
 input emmc_clk,
 input rst,
 input emmc_dat0,
 input wire [31:0] emmc_user_data,
 output reg emmc_trigger
 );
 
 reg [31:0] capture = 32'b0;
 reg [31:0] counter = 32'b0;
 
 always @(posedge emmc_clk or negedge rst) begin
     capture <= capture;
     counter <= counter;
     emmc_trigger <= 1'b0;
     if (!rst) begin
         emmc_trigger <= 1'b0;
         counter <= 24'b1000000000;
         capture <= 32'b0;
     end else if (counter > 0) begin
         counter <= counter - 1;
         capture <= 32'b0;
     end else if (capture == emmc_user_data) begin
         emmc_trigger <= 1'b1;
         counter <= 24'b1000000000;
     end else begin
         emmc_trigger <= 1'b0;
         capture <= {capture[31:0], emmc_dat0};
     end
 end
    
endmodule
