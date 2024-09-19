module  ramdp
#(  
    parameter   AWI = 5     ,
    parameter   AWO = 3     ,
    parameter   DWI = 4    ,
    parameter   DWO = 16
)
(
        input   wire            CLK_WR  ,   //写时钟
        input   wire            WR_EN   ,   //写使能
        input   wire[AWI-1:0]   ADDR_WR ,   //写地址
        input   wire[DWI-1:0]   D       ,   //写数据
        input   wire            CLK_RD  ,   //读时钟
        input   wire            RD_EN   ,   //读使能
        input   wire[AWO-1:0]   ADDR_RD ,   //读地址
        output  reg [DWO-1:0]   Q           //读数据
);
//输出位宽大于输入位宽，求取扩大的倍数及对应的位数
parameter       EXTENT       = DWO/DWI ;
parameter       EXTENT_BIT   = AWI-AWO > 0 ? AWI-AWO : 'b1 ;
//输入位宽大于输出位宽，求取缩小的倍数及对应的位数
parameter       SHRINK       = DWI/DWO ;
parameter       SHRINK_BIT   = AWO-AWI > 0 ? AWO-AWI : 'b1;

genvar i ;
generate
   //数据位宽展宽（地址位宽缩小）
   if (DWO >= DWI) begin
      //写逻辑，每时钟写一次
      reg [DWI-1:0]         mem [(1<<AWI)-1 : 0] ;
      always @(posedge CLK_WR) begin
         if (WR_EN) begin
            mem[ADDR_WR]  <= D ;
         end
      end
      //读逻辑，每时钟读 4 次
      for (i=0; i<EXTENT; i=i+1) begin
         always @(posedge CLK_RD) begin
            if (RD_EN) begin
               Q[(i+1)*DWI-1: i*DWI]  <= mem[(ADDR_RD*EXTENT) + i ] ;
            end
         end
      end
   end
   //=================================================
   //数据位宽缩小（地址位宽展宽）
   else begin
      //写逻辑，每时钟写 4 次
      reg [DWO-1:0]         mem [(1<<AWO)-1 : 0] ;
      for (i=0; i<SHRINK; i=i+1) begin
         always @(posedge CLK_WR) begin
            if (WR_EN) begin
               mem[(ADDR_WR*SHRINK)+i]  <= D[(i+1)*DWO -1: i*DWO] ;
            end
         end
      end
      //读逻辑，每时钟读 1 次
      always @(posedge CLK_RD) begin
         if (RD_EN) begin
             Q <= mem[ADDR_RD] ;
         end
      end
   end
endgenerate

endmodule