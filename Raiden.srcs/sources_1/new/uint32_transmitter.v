`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2020 05:16:43 AM
// Design Name: 
// Module Name: uin32_transmitter
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


module uint32_transmitter(
  input clk,
  input rst,
  input enable,
  input [31:0] u32_data,
  input tx_valid,
  output reg [7:0] data_out,
  output reg data_valid = 1'b0
);

  parameter IDLE = 4'd0;
  parameter TRANSMIT = 4'd1;
  
  reg [3:0] state = IDLE;
  
  reg [2:0] count;

always @(posedge clk)
begin
   // default assignments
   if(rst)
   begin
       count <= 8'd0;
       state <= IDLE;
   end
   else
   begin
     count <= count;
     state <= state;
     data_valid <= 1'b0;
     data_out <= data_out;
     case(state)
       IDLE:
         begin
           if(enable)
           begin
             count <= 3'd0;
             data_valid <= 4'd0;
             state <= TRANSMIT;
           end
         end
       TRANSMIT:
         begin
           if(tx_valid)
              begin
                 data_out <= u32_data[(count *8 ) +:8];
                 count <= count + 1;
                 if(count == 3)
                  begin
                    count <= 0;
                    state <= IDLE;
                    data_valid <= 1'b1;
                  end
              end
          end                    
     endcase        
   end
end
endmodule
