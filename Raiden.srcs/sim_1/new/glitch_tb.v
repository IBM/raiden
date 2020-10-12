`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2019 03:36:48 PM
// Design Name: 
// Module Name: glitch_tb
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


module glitch_tb();

reg clk = 1'b0;
reg  rst = 1'b0;
reg enable = 1'b0;
reg [31:0] glitch_width = 0;
reg [31:0] glitch_count = 0;
reg [31:0] glitch_gap = 0;
reg [31:0] glitch_delay = 0;
reg [31:0] glitch_max = 0;
reg vstart = 0;
wire vout;
wire finished;

glitch glitchi
(
  .clk(clk),
  .rst(rst),
  .enable(enable && !finished),
  .glitch_width(glitch_width),
  .glitch_count(glitch_count),
  .glitch_delay(glitch_delay),
  .glitch_gap(glitch_gap),
  .glitch_max(glitch_max),
  .vstart(vstart),
  .finished(finished),
  .vout(vout)
);

always
  begin
    #5 clk <= !clk;
  end

initial
  begin
  @(posedge clk)
    #100;
    $display("Test 1 - 210ns enable signal");
    enable <= 1'b1;
    glitch_width <= 32'd2;
    glitch_count <= 32'd4;
    glitch_gap <= 32'd4;
    glitch_delay <= 32'd1;
  @(posedge clk)
    $display("Testing glitch module with param width:%d", glitch_width);
    $display("Testing glitch module with param count:%d", glitch_count);
    $display("Testing glitch module with param gap:%d", glitch_gap);
    $display("Testing glitch module with param delay:%d", glitch_delay);
    #220;
    enable <= 1'b0;
  @(posedge clk)
    #100;
    $display("Test 2 - 100ns enable signal");
    enable <= 1'b1;
    glitch_width <= 32'd1;
    glitch_count <= 32'd2;
    glitch_gap <= 32'd1;
    glitch_delay <= 32'd5;
  @(posedge clk)
    $display("Testing glitch module with param width:%d", glitch_width);
    $display("Testing glitch module with param count:%d", glitch_count);
    $display("Testing glitch module with param gap:%d", glitch_gap);
    $display("Testing glitch module with param delay:%d", glitch_delay);
    #100;
    enable <= 1'b0; 
  @(posedge clk)
    #100;
    $display("Test 3 - 10ns enable signal");
    enable <= 1'b1;
    glitch_width <= 32'd1;
    glitch_count <= 32'd3;
    glitch_gap <= 32'd1;
    glitch_delay <= 32'd0;
  @(posedge clk)
    $display("Testing glitch module with param width:%d", glitch_width);
    $display("Testing glitch module with param count:%d", glitch_count);
    $display("Testing glitch module with param gap:%d", glitch_gap);
    $display("Testing glitch module with param delay:%d", glitch_delay);
    enable <= 1'b0;
  @(posedge clk)
    #100;
    $display("Test 4 - 500ns enable signal - glitch max 1");
    enable <= 1'b1;
    glitch_width <= 32'd2;
    glitch_count <= 32'd1;
    glitch_gap <= 32'd1;
    glitch_delay <= 32'd0;
    glitch_max <= 31'd1;
  @(posedge clk)
    $display("Testing glitch module with param width:%d", glitch_width);
    $display("Testing glitch module with param count:%d", glitch_count);
    $display("Testing glitch module with param gap:%d", glitch_gap);
    $display("Testing glitch module with param delay:%d", glitch_delay);
    $display("Testing glitch module with param max:%d", glitch_max);
    #500;
    enable <= 1'b0;
    if (finished == 1'b1)
      $display("Test complete - success");
    else
      $display("Test complete -failed");
  @(posedge clk)
    #100;
    $display("Test 5 - 120ns enable signal - glitch max 3");
    enable <= 1'b1;
    glitch_width <= 32'd1;
    glitch_count <= 32'd4;
    glitch_gap <= 32'd2;
    glitch_delay <= 32'd1;
    glitch_max <= 31'd3;
  @(posedge clk)
    $display("Testing glitch module with param width:%d", glitch_width);
    $display("Testing glitch module with param count:%d", glitch_count);
    $display("Testing glitch module with param gap:%d", glitch_gap);
    $display("Testing glitch module with param delay:%d", glitch_delay);
    $display("Testing glitch module with param max:%d", glitch_max);
    #120;
    enable <= 1'b0;
    #100
    enable <= 1'b1;
    #120
    enable <= 1'b0;
    #100
    enable <= 1'b1;
    #120
    enable <= 1'b0;
    #100
    enable <= 1'b1;
    #120
    enable <= 1'b0;
    if (finished == 1'b1)
      $display("Test complete - success");
    else
      $display("Test complete -failed");
    $finish();
  end

endmodule
