`timescale 1ns/1ns

module tb_ahb_top();

reg hclk;
reg hresetn;
reg enable;
reg [31:0] din;
reg [31:0] addr;
reg wr;
wire [31:0] dout;

initial begin
  hclk = 0;
  hresetn = 0;
  enable = 1'b0;
  din = 32'd0;
  addr = 32'd0;
  wr = 1'b0;
  #20 hresetn = 1;

  write(32'h0000_0000,32'd1);
  read(32'h0000_0000);
  write(32'h4000_0004,32'd2);
  read(32'h4000_0004);
  write(32'h8000_0008,32'd3);
  read(32'h8000_0008);
  write(32'hc000_000c,32'd4);
  read(32'hc000_000c);

  read(32'h0000_0000);
  read(32'h4000_0004);
  read(32'h8000_0008);
  read(32'hc000_000c);

end



task write( input [31:0] address, input [31:0] a);
begin
  @(posedge hclk)
  enable = 1'b1;
  addr = address;
  wr = 1'b1;
  @(posedge hclk)
  din = a;
  @(posedge hclk)

  @(posedge hclk)

  @(posedge hclk)
  enable = 1'b0;
  wr = 1'b0;
end
endtask

task read(input [31:0] address);
begin
  @(posedge hclk)
  enable = 1'b1;
  addr = address;
  wr = 1'b0;
  @(posedge hclk)

  @(posedge hclk)

  @(posedge hclk)

  @(posedge hclk)
  enable = 1'b0;
  wr = 1'b0;
end
endtask

ahb_top dut(
  .hclk(hclk),
  .hresetn(hresetn),
  .enable(enable),
  .din(din),
  .addr(addr),
  .wr(wr),
  .dout(dout)
);

always #2 hclk <= ~hclk;

endmodule