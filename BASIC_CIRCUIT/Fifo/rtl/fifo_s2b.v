module  fifo_s2b
(
    input   wire            rstn    ,
    input   wire[4-1: 0]    din     ,   //异步写数据
    input   wire            din_clk ,   //异步写时钟
    input   wire            din_en  ,   //异步写使能
    output  wire[16-1 : 0]  dout    ,   //同步后数据
    input   wire            dout_clk,   //同步使用时钟
    input   wire            dout_en 
); //同步数据使能

wire         fifo_empty, fifo_full, prog_full ;
wire         rd_en_wir ;
wire [15:0]  dout_wir ;
//读空状态时禁止读，否则一直读
assign rd_en_wir     = fifo_empty ? 1'b0 : 1'b1 ;
fifo  
#(
   .AWI        (5 ), 
   .AWO        (3 ), 
   .DWI        (4 ), 
   .DWO        (16), 
   .PROG_DEPTH (16)
)
u_buf_s2b
(
   .rstn       (rstn       ),
   .wclk       (din_clk    ),
   .winc       (din_en     ),
   .wdata      (din        ),
   .rclk       (dout_clk   ),
   .rinc       (rd_en_wir  ),
   .rdata      (dout_wir   ),
   .wfull      (fifo_full  ),
   .rempty     (fifo_empty ),
   .prog_full  (prog_full  )
);
//缓存同步后的数据和使能
reg          dout_en_r ;
always @(posedge dout_clk or negedge rstn) begin
   if (!rstn) begin
      dout_en_r       <= 1'b0 ;
   end
   else begin
      dout_en_r       <= rd_en_wir ;
   end
end
assign       dout    = dout_wir ;
assign       dout_en = dout_en_r ;

endmodule