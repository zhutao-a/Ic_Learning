module  fifo
#(  
    parameter   AWI         = 5     ,
    parameter   AWO         = 3     ,
    parameter   DWI         = 4     ,
    parameter   DWO         = 16    ,
    parameter   PROG_DEPTH  = 16            //可设置深度
) 
(
    input   wire                rstn    ,   //读写使用一个复位
    input   wire                wclk    ,   //写时钟
    input   wire                winc    ,   //写使能
    input   wire[DWI-1: 0]      wdata   ,   //写数据
    input   wire                rclk    ,   //读时钟
    input   wire                rinc    ,   //读使能
    output  wire[DWO-1 : 0]     rdata   ,   //读数据
    output  wire                wfull   ,   //写满标志
    output  wire                rempty  ,   //读空标志
    output  wire                prog_full   //可编程满标志
 );

//输出位宽大于输入位宽，求取扩大的倍数及对应的位数
parameter       EXTENT       = DWO/DWI ;
parameter       EXTENT_BIT   = AWI-AWO ;
//输出位宽小于输入位宽，求取缩小的倍数及对应的位数
parameter       SHRINK       = DWI/DWO ;
parameter       SHRINK_BIT   = AWO-AWI ;

//==================== push/wr counter ===============
wire [AWI-1:0]      waddr ;
wire                wover_flag ; //多使用一位做写地址拓展
ccnt         
#(
    .W(AWI+1)
)            
u_push_cnt
(
   .rstn (rstn                  ),
   .clk  (wclk                  ),
   .en   (winc && !wfull        ), //full 时禁止写
   .count({wover_flag, waddr}   )
);

//============== pop/rd counter ===================
wire [AWO-1:0]            raddr ;
wire                      rover_flag ;  //多使用一位做读地址拓展
ccnt         
#(
    .W(AWO+1)
)    
u_pop_cnt
(
   .rstn (rstn                  ),
   .clk  (rclk                  ),
   .en   (rinc & !rempty        ), //empyt 时禁止读
   .count({rover_flag, raddr}   )
);

//==============================================
//窄数据进，宽数据出
generate
   if (DWO >= DWI) begin : EXTENT_WIDTH
      //格雷码转换
      wire [AWI:0] wptr    = ({wover_flag, waddr}>>1) ^ ({wover_flag, waddr}) ;
      //将写数据指针同步到读时钟域
      reg [AWI:0]  rq2_wptr_r0 ;
      reg [AWI:0]  rq2_wptr_r1 ;
      always @(posedge rclk or negedge rstn) begin
         if (!rstn) begin
            rq2_wptr_r0     <= 'b0 ;
            rq2_wptr_r1     <= 'b0 ;
         end
         else begin
            rq2_wptr_r0     <= wptr ;
            rq2_wptr_r1     <= rq2_wptr_r0 ;
         end
      end

      //格雷码转换
      wire [AWI-1:0] raddr_ex = raddr << EXTENT_BIT ;
      wire [AWI:0]   rptr     = ({rover_flag, raddr_ex}>>1) ^ ({rover_flag, raddr_ex}) ;
      //将读数据指针同步到写时钟域
      reg [AWI:0]    wq2_rptr_r0 ;
      reg [AWI:0]    wq2_rptr_r1 ;
      always @(posedge wclk or negedge rstn) begin
         if (!rstn) begin
            wq2_rptr_r0     <= 'b0 ;
            wq2_rptr_r1     <= 'b0 ;
         end
         else begin
            wq2_rptr_r0     <= rptr ;
            wq2_rptr_r1     <= wq2_rptr_r0 ;
         end
      end

      //格雷码反解码
      //如果只需要空、满状态信号，则不需要反解码
      //因为可编程满状态信号的存在，地址反解码后便于比较
      reg [AWI:0]       wq2_rptr_decode ;
      reg [AWI:0]       rq2_wptr_decode ;
      integer           i ;
      always @(*) begin
         wq2_rptr_decode[AWI] = wq2_rptr_r1[AWI];
         for (i=AWI-1; i>=0; i=i-1) begin
            wq2_rptr_decode[i] = wq2_rptr_decode[i+1] ^ wq2_rptr_r1[i] ;
         end
      end
      always @(*) begin
         rq2_wptr_decode[AWI] = rq2_wptr_r1[AWI];
         for (i=AWI-1; i>=0; i=i-1) begin
            rq2_wptr_decode[i] = rq2_wptr_decode[i+1] ^ rq2_wptr_r1[i] ;
         end
      end

      //读写地址、拓展位完全相同是，为空状态
      assign rempty    = (rover_flag == rq2_wptr_decode[AWI]) &&
                         (raddr_ex >= rq2_wptr_decode[AWI-1:0]);
      //读写地址相同、拓展位不同，为满状态
      assign wfull     = (wover_flag != wq2_rptr_decode[AWI]) &&
                         (waddr >= wq2_rptr_decode[AWI-1:0]) ;
      //拓展位一样时，写地址必然不小于读地址
      //拓展位不同时，写地址部分比如小于读地址，实际写地址要增加一个FIFO深度
      assign prog_full  = (wover_flag == wq2_rptr_decode[AWI]) ?
                          waddr - wq2_rptr_decode[AWI-1:0] >= PROG_DEPTH-1 :
                          waddr + (1<<AWI) - wq2_rptr_decode[AWI-1:0] >= PROG_DEPTH-1;

      //双口 ram 例化
      ramdp
        #( .AWI     (AWI),
           .AWO     (AWO),
           .DWI     (DWI),
           .DWO     (DWO))
      u_ramdp
        (
         .CLK_WR          (wclk),
         .WR_EN           (winc & !wfull), //写满时禁止写
         .ADDR_WR         (waddr),
         .D               (wdata[DWI-1:0]),
         .CLK_RD          (rclk),
         .RD_EN           (rinc & !rempty), //读空时禁止读
         .ADDR_RD         (raddr),
         .Q               (rdata[DWO-1:0])
         );
   end
endgenerate


endmodule