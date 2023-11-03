`timescale 1ns/1ns
`define         SMALL2BIG
module tb_fifo_s2b ;

`ifdef SMALL2BIG
   reg          rstn ;
   reg          clk_slow, clk_fast ;
   reg [3:0]    din ;
   reg          din_en ;
   wire [15:0]  dout ;
   wire         dout_en ;

   //reset
   initial begin
      clk_slow  = 0 ;
      clk_fast  = 0 ;
      rstn      = 0 ;
      #50 rstn  = 1 ;
   end

   //读时钟 clock_slow 较快于写时钟 clk_fast 的 1/4
   //保证读数据稍快于写数据
   parameter CYCLE_WR = 40 ;
   always #(CYCLE_WR/2/4) clk_fast = ~clk_fast ;
   always #(CYCLE_WR/2-1) clk_slow = ~clk_slow ;

   //data generate
   initial begin
      din       = 16'h4321 ;
      din_en    = 0 ;
      wait (rstn) ;
      //(1) 测试 full、prog_full、empyt 信号
      force tb_fifo_s2b.u_data_buf2.u_buf_s2b.rinc = 1'b0 ;
      repeat(32) begin
         @(negedge clk_fast) ;
         din_en = 1'b1 ;
         din    = {$random()} % 16;
      end
      @(negedge clk_fast) din_en = 1'b0 ;

      //(2) 测试数据读写
      #500 ;
      rstn = 0 ;
      #10 rstn = 1 ;
      release tb_fifo_s2b.u_data_buf2.u_buf_s2b.rinc;
      repeat(100) begin
         @(negedge clk_fast) ;
         din_en = 1'b1 ;
         din    = {$random()} % 16;
      end

      //(3) 停止读取再一次测试 empyt、full、prog_full 信号
      force tb_fifo_s2b.u_data_buf2.u_buf_s2b.rinc = 1'b0 ;
      repeat(18) begin
         @(negedge clk_fast) ;
         din_en = 1'b1 ;
         din    = {$random()} % 16;
      end
   end

   fifo_s2b u_data_buf2
   (
        .rstn           (rstn),
        .din            (din),
        .din_clk        (clk_fast),
        .din_en         (din_en),

        .dout           (dout),
        .dout_clk       (clk_slow),
        .dout_en        (dout_en)
    );

`else
`endif

   //stop sim
   initial begin
      forever begin
         #100;
         if ($time >= 5000)  $finish ;
      end
   end
   
   initial	begin
      $fsdbDumpfile("tb.fsdb");	    
      $fsdbDumpvars;
   end


endmodule