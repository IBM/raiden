module top_tb();

reg tb_clk = 1'b1;

always
begin
    #5 tb_clk <= ~tb_clk;
end

wire tb_uart;

top tb_top (
    .clk(tb_clk),
    .ftdi_rx(tb_uart)
);

reg [7:0] tx_data;
reg tx_en = 1'b0;
wire tx_rdy;
wire rst;

uart_tx txi (
    .clk(tb_clk),
    .rst(rst),
    .dout(tb_uart),
    .data_in(tx_data),
    .en(tx_en),
    .rdy(tx_rdy)
);

initial
begin
    #1000;
    @(posedge tb_clk);
    tx_data <= 8'h00;
    tx_en <= 1'b1;
    @(posedge tb_clk);
    tx_en <= 1'b0;
    wait(!tx_rdy);
    @(posedge tb_clk);
    wait(tx_rdy);
    @(posedge tb_clk);
    tx_data <= 8'hff;
    tx_en <= 1'b1;
    $display("RST: %b", rst);
    $finish();
end
endmodule