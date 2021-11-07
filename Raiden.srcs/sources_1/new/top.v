`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: X-Force Red
// Engineer: Grzegorz Wypych (h0rac)
// 
// Create Date: 10/21/2019 01:53:37 AM
// Design Name: 
// Module Name: top
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

module top(
  input clk,
  input rst,
  input ftdi_rx,
  input target_rx,
  input trigger_in,
  input gpio_in1,
  input gpio_in2,
  output gpio_out,
  output ftdi_tx,
  output led0_g,
  output led0_r,
  output led0_b,
  output led1_b,
  output led2_g,
  output led2_r,
  output led2_b,
  output led_blink,
  output led5_debug,
  output led6_debug,
  output debug_io0_14_p30,
  output led_glitch_out,
  output wire glitch_out,
  output invert_glitch_out,
  output wire reset_out
    );
 
//  assign target_tx = ftdi_rx;
//  assign target_rx = ftdi_tx;


parameter AUTO = 2'd2;

wire bit_out;
wire active;

wire [31:0] glitch_delay;
wire [31:0] glitch_width;
wire [31:0] glitch_count;
wire [31:0] glitch_gap;
wire [31:0] glitch_max;
wire [31:0] reset_target;
wire [31:0] uart_trigger_baud;
wire [7:0] uart_trigger_data;
wire armed;
wire glitched;
wire finished;
wire vstart; // glitch_out startup value
wire invert_trigger;
wire [1:0] force_state;
wire reset_glitcher;

// counter for main loop
reg [31:0] counter;

cmd cmd_inst
(
  .clk(clk),
  .rst(rst),
  .din(ftdi_rx),
  .dout(bit_out),
  .trigger_in(trigger_in),
  .glitch_delay(glitch_delay),
  .glitch_width(glitch_width),
  .glitch_count(glitch_count),
  .glitch_gap(glitch_gap),
  .glitch_max(glitch_max),
  .armed(armed),
  .finished(finished),
  .glitched(glitched),
  .glitch_out(glitch_out),
  .force_state(force_state),
  .reset_glitcher(reset_glitcher),
  .vstart(vstart),
  .invert_trigger(invert_trigger),
  .reset_target(reset_target),
  .gpio_in1(gpio_in1),
  .gpio_in2(gpio_in2),
  .gpio_out(gpio_out),
  .uart_trigger_data(uart_trigger_data),
  .uart_trigger_baud(uart_trigger_baud)
  );   
  assign ftdi_tx =  bit_out;
  assign gpio_out = gpio_out;
 

wire [7:0] rx_data;
wire rx_valid;

//handle data byte for UART trigger
uart_rx rxi_uart_trigger (
  .clk(clk),
  .rst(rst),
  .baud(uart_trigger_baud),
  .din(target_rx),
  .data_out(rx_data),
  .valid(rx_valid)
  );

wire uart_trigger;
assign uart_trigger = rx_valid && (uart_trigger_data == rx_data) ? 1: 0;

 
 // reset target feature
// assign rst_out = reset_target ? 1'b0 : 1'b1;
wire glitch;
wire trigger;
assign trigger = invert_trigger ^ trigger_in ^ uart_trigger;
assign glitch_out = force_state != AUTO ? force_state : glitch;
assign invert_glitch_out = !glitch_out;
wire enable =  (force_state == AUTO && (((armed && !finished) && trigger) || (glitch_max && glitched && !finished)));
 
 glitch glitchi
 (
  .clk(clk),
  .rst(rst || reset_glitcher),
  .enable(enable),
  .vout(glitch),
  .glitch_delay(glitch_delay),
  .glitch_width(glitch_width),
  .glitch_count(glitch_count),
  .glitch_gap(glitch_gap),
  .glitch_max(glitch_max),
  .glitched(glitched),
  .vstart(vstart),
  .finished(finished),
  .reset_target(reset_target),
  .reset_out(reset_out)
 );
 
  // LD0 - BLUE armed, GREEN glitching started, RED finished
  
   pwm pwm_led0_r (
    .clk(clk),
    .duty(64),
    .signal(finished),
    .state(led0_r)
   );
   
   pwm pwm_led0_g (
    .clk(clk),
    .duty(16),
    .signal(glitched && !finished),
    .state(led0_g)
   );
   
   pwm pwm_led0_b (
    .clk(clk),
    .duty(64),
    .signal(!glitched && armed),
    .state(led0_b)
   );

    //LD1 - UART trigger
   
//   pwm pwm_led1_r (
//    .clk(clk),
//    .duty(64),
//    .signal(armed),
//    .state(led1_r)
//   );
   
//   pwm pwm_led1_g (
//    .clk(clk),
//    .duty(64),
//    .signal(armed),
//    .state(led1_g)
//   );
             
   pwm pwm_led1_b (
    .clk(clk),
    .duty(16),
    .signal(uart_trigger),
    .state(led1_b)
   );
   
   // LD2 - trigger
          
   pwm pwm_led2_r (
    .clk(clk),
    .duty(32),
    .signal(trigger_in),
    .state(led2_r)
   );
   
   pwm pwm_led2_g (
    .clk(clk),
    .duty(4),
    .signal(trigger_in),
    .state(led2_g)
   );
                      
   pwm pwm_led2_b (
    .clk(clk),
    .duty(48),
    .signal(trigger_in),
    .state(led2_b)
   );

  //assign debug_enable = (armed && trigger_in) || (armed && !trigger_in_pullup);
  assign debug_io0_14_p30 = uart_trigger;
  assign led5_debug = reset_out;
  assign led6_debug = reset_target;
  assign led_blink = counter[26];
  assign led_glitch_out = glitch_out;
  
  always @(posedge clk)
  begin
    counter <= counter + 1;
  end
 
endmodule
