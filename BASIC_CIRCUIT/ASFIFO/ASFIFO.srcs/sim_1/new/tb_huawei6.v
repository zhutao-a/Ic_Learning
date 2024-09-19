module huawei6_tb;

  // Parameters

  // Ports
  reg clk0 = 0;
  reg clk1 = 0;
  reg sel = 0;
  reg rst = 0;
  wire clk_out;

  huawei6 
  huawei6_dut (
    .clk0 (clk0 ),
    .clk1 (clk1 ),
    .sel (sel ),
    .rst (rst ),
    .clk_out  ( clk_out)
  );

  initial begin
    begin
      clk0=1'b0;
      clk1=1'b0;
      rst=1'b0;
      sel=1'b0;
      #13
      rst=1'b1;
      #25
      sel=1'b1;
      #47
      sel=1'b0;
      #105
      sel=1'b1;
      #200
      $finish;
    end
  end

  always
    #10  clk0 = ! clk0 ;
  always
    #5  clk1 = ! clk1 ;

endmodule
