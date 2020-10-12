module cmd_tb();

reg tb_clk = 1'b1;

always
begin
    #5 tb_clk <= ~tb_clk;
end

wire tb_uart;
wire [31:0] reset_delay;

cmd tb_cmd (
    .clk(tb_clk),
    .din(tb_uart),
    .reset_delay(reset_delay)
);

reg [7:0] tx_data;
reg tx_en = 1'b0;
wire tx_rdy;

uart_tx txi (
    .clk(tb_clk),
    .rst(1'b0),
    .dout(tb_uart),
    .data_in(tx_data),
    .en(tx_en),
    .rdy(tx_rdy)
);

initial
begin
   #1000;
   @(posedge tb_clk);
    tx_data <= 8'd67;
    tx_en <= 1'b1;
   @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
      wait(tx_rdy);
      @(posedge tb_clk);
     tx_en <= 1'b1;
     tx_data <= 8'h0;
    @(posedge tb_clk);
     tx_en <= 1'b0;
     wait(!tx_rdy);
     @(posedge tb_clk);
     wait(tx_rdy);
     @(posedge tb_clk); 
      tx_data <= 8'h2;
      tx_en <= 1'b1;
      @(posedge tb_clk);
       tx_en <= 1'b0;
       wait(!tx_rdy);
       @(posedge tb_clk);
       wait(tx_rdy);
       @(posedge tb_clk);
        tx_data <= 8'h80;
        tx_en <= 1'b1;
        @(posedge tb_clk);
        tx_en <= 1'b0;
        wait(!tx_rdy);
        @(posedge tb_clk);
        wait(tx_rdy);
        @(posedge tb_clk);
    // Set pattern ok
end

endmodule