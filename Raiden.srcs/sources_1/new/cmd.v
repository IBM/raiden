`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: X-Force Red
// Engineer: Grzegorz Wypych (h0rac)
// 
// Create Date: 10/22/2019 05:52:18 AM
// Design Name: 
// Module Name: cmd
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

module cmd(
  input clk,
  input din,
  input trigger_in,
  input rst,
  input finished,
  input glitched,
  input glitch_out,
  input gpio_in1,
  input gpio_in2,
  output reg gpio_out,
  output wire dout,
  output reg [1:0] force_state = 2'd2,
  output reg [31:0] glitch_delay,
  output reg [31:0] glitch_width,
  output reg [31:0] glitch_count,
  output reg [31:0] glitch_gap,
  output reg [31:0] glitch_max,
  output reg armed,
  output reg reset_glitcher,
  output reg vstart,
  output reg invert_trigger,
  output reg [31:0] reset_target,
  output reg [31:0] emmc_user_data
  );
  
reg fpga_rst;
parameter AUTO = 2'd2;
parameter CMD_RST_GLITCHER = 8'd65;
parameter CMD_FORCE_GLITCH_OUT_STATE = 8'd66;
parameter CMD_FLAG_STATUS = 8'd68;
parameter CMD_GLITCH_DELAY = 8'd69;
parameter CMD_GLITCH_WIDTH = 8'd70;
parameter CMD_GLITCH_COUNT = 8'd71;
parameter CMD_ARM = 8'd72;
parameter CMD_GLITCH_GAP = 8'd73;
parameter CMD_RST = 8'd74;
parameter CMD_VSTART = 8'd75;
parameter CMD_GLITCH_MAX = 8'd76;
parameter CMD_BUILDTIME = 8'd77;
parameter CMD_INVERT = 8'd78;
parameter CMD_RESET_TARGET = 8'd79;
parameter CMD_GPIO_OUT = 8'd80;
parameter CMD_EMMC_DATA = 8'd81;

parameter IDLE = 5'b00000;
parameter ACK_4BYTE_CMD = 5'b00001;
parameter GLITCH_WIDTH = 5'b00011;
parameter GLITCH_DELAY_LENGTH = 5'b00100;
parameter GLITCH_COUNT = 5'b01000;
parameter ARM = 5'b01001;
parameter GLITCH_GAP = 5'b01100;
parameter FORCE_GLITCH_OUT_STATE = 5'b01110;
parameter RST_GLITCHER = 5'b10000;
parameter GPIO_OUT = 5'b10001;
parameter RST = 5'b10010;
parameter VSTART = 5'b10100;
parameter GLITCH_MAX = 5'b10110;
parameter BUILDTIME = 5'b11000;
parameter FLAG_STATUS = 5'b11010;
parameter INVERT = 5'b11100;
parameter RESET_TARGET = 5'b11110;
parameter EMMC_DATA = 5'b11111;
  
reg [4:0] state = IDLE;
wire bit_out;
wire [7:0] rx_data;
wire rx_valid;
  
uart_rx rxi (
  .clk(clk),
  .rst(rst),
  .din(din),
  .data_out(rx_data),
  .valid(rx_valid)
  );
  
reg  tx_en = 1'b0;
reg [7:0] tx_data;
wire tx_rdy;
wire [8:0] flags; 
  
assign flags[0]= armed;       // API armed
assign flags[1]= glitched;    // glitching has started
assign flags[2]= finished;    // glitching has completed
assign flags[3]= glitch_out;  // current state of glitch out
assign flags[4]= trigger_in;  // current state of trigger in
assign flags[5] = gpio_in1; // GPIO_IN1 status
assign flags[6] = gpio_out; // GPIO_OUT status
assign flags[7] = gpio_in2; // GPIO_IN2 status
  
uart_tx txi (
  .clk(clk),
  .dout(dout),
  .data_in(tx_data),
  .en(tx_en),
  .rdy(tx_rdy)
  );
  
reg u32_rec_enable = 1'd0;
wire u32_rec_valid;
wire [31:0] u32_rec_data;
  
uint32_receiver u32_rec(
  .clk(clk),
  .reset(rst),
  .uart_data(rx_data),
  .uart_valid(rx_valid),
  .data(u32_rec_data),
  .data_valid(u32_rec_valid),
  .enable(u32_rec_enable)
);

wire [31:0] buildtime;     
reg [2:0] count = 3'b0;
always @(posedge clk)
  begin
    if(rst)
      begin
        state <= IDLE;
      end
    if(reset_glitcher)
      begin
        reset_glitcher <= 0;
      end
  else
  begin
    u32_rec_enable <= 1'b0;
    glitch_delay <= glitch_delay;
    glitch_count <= glitch_count;
    glitch_width <= glitch_width;
    glitch_max <= glitch_max;
    glitch_gap <= glitch_gap;
    emmc_user_data <= emmc_user_data;
    state <= state;
    if(state == BUILDTIME || state == ACK_4BYTE_CMD)
      begin
        tx_en <= 1'b1;
      end
    else
      begin
        tx_en <= 1'b0;
      end
    case(state)
      IDLE:
        begin
          if(rx_valid)
            begin
              case(rx_data)
                CMD_FORCE_GLITCH_OUT_STATE:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1; 
                    state <= FORCE_GLITCH_OUT_STATE;
                  end
                CMD_RST_GLITCHER:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1; 
                    state <= RST_GLITCHER;
                  end
                CMD_RST:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1; 
                    state <= RST;
                  end
                CMD_FLAG_STATUS:
                  begin
                    tx_en <= 1'b1;
                    state <= FLAG_STATUS;
                  end
                CMD_GLITCH_DELAY:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;
                    u32_rec_enable <= 1'b1;
                    state <= GLITCH_DELAY_LENGTH;
                  end
                CMD_GLITCH_WIDTH:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;
                    u32_rec_enable <= 1'b1;
                    state <= GLITCH_WIDTH;
                  end
                CMD_GLITCH_COUNT:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;
                    u32_rec_enable <= 1'b1;
                    state <= GLITCH_COUNT;
                  end
                CMD_GLITCH_GAP:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;
                    u32_rec_enable <= 1'b1;
                    state <= GLITCH_GAP;
                  end
                CMD_GLITCH_MAX:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;
                    u32_rec_enable <= 1'b1;
                    state <= GLITCH_MAX;
                  end
                CMD_EMMC_DATA:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;
                    u32_rec_enable <= 1'b1;
                    state <= EMMC_DATA;
                  end
                CMD_RESET_TARGET:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;
                    u32_rec_enable <= 1'b1;
                    state <= RESET_TARGET;
                  end
                CMD_ARM:
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;    
                    state <= ARM;
                  end
                CMD_VSTART: // set glitch line voltage to HIGH or LOW
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;    
                    state <= VSTART;
                  end
                CMD_INVERT: // set trigger to inverted
                  begin
                    tx_data <= rx_data;
                    tx_en <= 1'b1;    
                    state <= INVERT;
                  end
                  CMD_GPIO_OUT: // set GPIO_OUT state
                    begin
                      tx_data <= rx_data;
                      tx_en <= 1'b1;    
                      state <= GPIO_OUT;
                     end
                CMD_BUILDTIME:
                  begin
//                    tx_data <= rx_data;
                    tx_en <= 1'b1;    
                    state <= BUILDTIME;
                  end
//               default:
////                  tx_en <= 1'b0;
              endcase     
            end
        end
     FORCE_GLITCH_OUT_STATE:
      begin
        if(rx_valid)
          begin
            force_state <= rx_data;
            tx_data <= rx_data;
            tx_en <= 1'b1;  
            state <= IDLE;
          end
        end
     RST_GLITCHER:
      begin
        if(rx_valid)
          begin
            reset_glitcher <= rx_data != 32'b0;
            tx_data <= rx_data;
            tx_en <= 1'b1;
            state <= IDLE;
          end
      end
     RST:
     //TODO reset all params and data to defaul raiden state
      begin
        if(rx_valid)
          begin
            fpga_rst <= rx_data != 32'b0;
            tx_data <= rx_data;
            tx_en <= 1'b1;
          end
      end
      GLITCH_DELAY_LENGTH:
        begin
          if(u32_rec_valid)
            begin
              glitch_delay <= u32_rec_data;
              state <= ACK_4BYTE_CMD;
              count <= count -1;
            end
        end
      RESET_TARGET:
        begin
          if(u32_rec_valid)
            begin
              reset_target <= u32_rec_data;
              state <= ACK_4BYTE_CMD;
              count <= count -1;
            end
        end
      ACK_4BYTE_CMD:
        begin
          if(tx_rdy)
            begin
              tx_data <= u32_rec_data[(count *8 ) +:8]; 
              count <= count +1;
              if(count == 3)
                begin
                  state <= IDLE;
                  count <= 0;
               end
             end   
         end       
      GLITCH_WIDTH:
        begin
          if(u32_rec_valid)
            begin
              glitch_width <= u32_rec_data;
              state <= ACK_4BYTE_CMD;
              count <= count -1;
            end
        end
      GLITCH_COUNT:
       begin
        if(u32_rec_valid)
          begin
            glitch_count <= u32_rec_data;
            state <= ACK_4BYTE_CMD;
            count <= count -1;
          end
       end
      GLITCH_GAP:
        begin
          if(u32_rec_valid)
            begin
              glitch_gap <= u32_rec_data;
              state <= ACK_4BYTE_CMD;
              count <= count -1;
            end
        end
      GLITCH_MAX:
        begin
          if(u32_rec_valid)
            begin
              glitch_max <= u32_rec_data;
              state <= ACK_4BYTE_CMD;
              count <= count -1;
            end
        end
      EMMC_DATA:
        begin
          if(u32_rec_valid)
            begin
              emmc_user_data <= u32_rec_data;
              state <= ACK_4BYTE_CMD;
              count <= count -1;
            end
        end
      ARM:
        begin
         if(rx_valid)
           begin
             armed <= rx_data != 8'b0;
             tx_data <= rx_data;
             tx_en <= 1'b1;    
             state <= IDLE;
           end
       end
      VSTART:
        begin
          if(rx_valid)
            begin
              vstart <= rx_data != 8'b0;
              tx_data <= rx_data;
              tx_en <= 1'b1;    
              state <= IDLE;
            end
        end
      INVERT:
        begin
          if(rx_valid)
            begin
              invert_trigger <= rx_data != 8'b0;
              tx_data <= rx_data;
              tx_en <= 1'b1;    
              state <= IDLE;
            end
        end
      GPIO_OUT:
        begin
         if(rx_valid)
           begin
            gpio_out <= rx_data != 8'b0;
            tx_data <= rx_data;
            tx_en <= 1'b1;    
            state <= IDLE;
           end
         end
      FLAG_STATUS:
        begin
          if(tx_rdy)
            begin
             tx_data <= flags;
             state <= IDLE;
            end
        end
      BUILDTIME:
        begin
          if(tx_rdy)
            begin
              tx_data <= buildtime[(count *8 ) +:8]; 
                count <= count +1;
                if(count == 3)
                  begin
                    state <= IDLE;
                    count <= 0;
                  end  
              end
          end
    endcase
   end
 end
 
`ifndef __ICARUS__
    USR_ACCESSE2 U_buildtime (
       .CFGCLK(),
       .DATA(buildtime),
       .DATAVALID()
    );
 `else
    assign buildtime = 0;
 `endif
 endmodule
