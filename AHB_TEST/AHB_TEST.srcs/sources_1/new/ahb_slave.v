module ahb_slave(
  /*
    输入数据
  */
  input hclk,//总线时钟
  input hresetn,//总线复位
  input hsel,//master--->slave，从机选择信号
  input [31:0] haddr,//master--->slave的32位总线地址
  input hwrite,//master--->slave 1：表示写传输  0：表示读传输
  //master--->slave 非标准端口信号，表示master那边已经将地址和控制信号放到总线上了，从机可以开始采集了
  input hready,
  input [31:0] hwdata,//master--->slave 传给slave的32位写数据

  /*
    输出数据
  */
  //slave--->mux，1：Slave指出传输结束，0：Slave需延长传输周期
  output reg hreadyout,
  output reg [31:0] hrdata//slave--->mux，从slave读来的32位数据
);

//----------------------------------------------------------------------
// The definitions for intern registers for data storge
//----------------------------------------------------------------------
reg [31:0] mem [31:0];
reg [4:0] waddr;
reg [4:0] raddr;

//----------------------------------------------------------------------
// The definition for state machine
//----------------------------------------------------------------------
reg [1:0] state;
reg [1:0] next_state;
/*
  idle：空闲状态，此时主机发送地址和控制信号
  sample_addr_ctr：采集地址和控制信号
  sample_data：采集数据,也即进行的是写操作
  send_data:发送数据,也即主机进行的是读操作
*/
localparam idle = 2'b00,  sample_addr_ctr = 2'b01, sample_data = 2'b10, send_data = 2'b11;

//----------------------------------------------------------------------
// The state machine
//----------------------------------------------------------------------

/*
  状态机第一段
*/
always @(posedge hclk, negedge hresetn) begin
  if(!hresetn) begin
    state <= idle;
  end
  else begin
    state <= next_state;
  end
end
/*
  状态机第二段
*/
always @(*) begin
  case(state)
    idle: begin
      //如果该slave被选中，则进入采集地址和控制信号的状态，否则不工作直接保持idle状态
      if(hsel == 1'b1) begin
        next_state = sample_addr_ctr;
      end
      else begin
        next_state = idle;
      end
    end
    //此时可以采集如hwrite、hready这些控制信号以及地址了，
    sample_addr_ctr: begin

      //如果是写操作，那么下一状态进入write
      if((hwrite == 1'b1) && (hready == 1'b1)) begin
        next_state = sample_data;
      end
      //否则如果是读操作，下一状态进入read
      else if((hwrite == 1'b0) && (hready == 1'b1)) begin
        next_state = send_data;
      end
      else begin
        next_state = sample_addr_ctr;
      end
    end
    /*
      采集数据状态，该状态结束后，因为单次传输模式下从机选择信号hsel一个周期就可以改变一次，
      所以下面再判断一下是否被选中，如果选中，那么直接再次进入control，开启下一次读写判断，如此循环往复。
    */

    sample_data: begin
            next_state = idle;

    end
    /*
      发送数据状态，该状态结束后，因为单次传输模式下从机选择信号hsel一个周期就可以改变一次，
      所以下面再判断一下是否被选中，如果选中，那么直接再次进入control，开启下一次读写判断，如此循环往复。
    */
    send_data: begin

            next_state = idle;

    end
    default: begin
      next_state = idle;
    end
  endcase
end
/*
  状态机第三段
*/
always @(posedge hclk, negedge hresetn) begin
  if(!hresetn) begin
    hreadyout <= 1'b0;
    hrdata <= 32'h0000_0000;
    waddr <= 5'b0000_0;
    raddr <= 5'b0000_0;
  end
  else begin
    case(state)
      idle: begin
        hreadyout <= 1'b0;
        hrdata <= 32'h0000_0000;
        waddr <= 5'b0000_0;
        raddr <= 5'b0000_0;
      end
      sample_addr_ctr: begin
        hreadyout <= 1'b0;
        hrdata <= 32'h0000_0000;
        waddr <= haddr;
        raddr <= haddr;
      end
      /*
        从机获取主机的写数据，并将hreadyout信号置1
      */
      sample_data: begin
            hreadyout <= 1'b1;
            mem[waddr[4:0]] <= hwdata;          
      end
      /*
        从机发送给主机的读数据，并将hreadyout信号置1
      */
      send_data: begin
            hreadyout <= 1'b1;
            hrdata <= mem[raddr[4:0]];
      end
      default: begin
        hreadyout <= 1'b0;
        hrdata <= 32'h0000_0000;
        waddr <= 5'b0000_0;
        raddr <= 5'b0000_0;
      end
    endcase
  end
end
endmodule