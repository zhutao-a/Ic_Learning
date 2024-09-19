module ahb_master(
  /*

    输入信号

  */
  input hclk,//总线时钟
  input hresetn,//总线复位
  input enable,//top--->master，使能信号
  input [31:0] din,//top--->master，输入数据
  input [31:0] addr,//top--->master，32位总线地址，实际上最后还是要传给slave
  input wr,//top--->master，控制此时是要进行读还是写，会影响hwrite的值

  //slave--->mux--->master，1：Slave指出传输结束，0：Slave需延长传输周期
  input hreadyout,
  input [31:0] hrdata,//slave--->mux--->master，从slave读来的32位数据

  /*
    输出信号
  */
  //master--->slave的32位总线地址，该信号也会传输到decoder，解析出选择了哪个从机
  output reg [31:0] haddr,
  output reg hwrite,//master--->slave 1：表示写传输  0：表示读传输
  //master--->slave 非标准端口信号，表示master这边已经将控制信号和地址放到总线上了，从机可以采集了
  output reg hready,
  output reg [31:0] hwdata,//master--->slave 传给slave的32位写数据


  output reg [31:0] dout//master--->top 将从slave读入的数据输出 
);

//----------------------------------------------------
// The definitions for state machine
//----------------------------------------------------

reg [2:0] state, next_state;
/*
  idle:空闲状态
  control：准备状态，将地址和控制信号发送到总线上
  write：写状态
  read：读状态
*/
parameter idle = 0,control = 1,  write = 2, read = 3;


//----------------------------------------------------
// The state machine
//----------------------------------------------------
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
      if(enable == 1'b1) 
        next_state = control;
      else 
        next_state = idle;
    end
    control:
      if(wr == 1'b1)
        next_state = write;
      else 
        next_state = read; 
    write: begin
     if(hreadyout == 1'b1) begin
        next_state = idle;
      end
      else begin
        next_state = write;
      end
    end
    read: begin
      if(hreadyout == 1'b1) begin
        next_state = idle;
      end
      else begin
        next_state = read;
      end
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
    haddr <= 32'h0000_0000;
    hwrite <= 1'b0;
    hready <= 1'b0;
    hwdata <= 32'h0000_0000;
    dout <= 32'h0000_0000;
  end
  else begin
    case(state)
      idle:begin
        haddr <= 32'h0000_0000;
        hwrite <= 1'b0;
        hready <= 1'b0;
        hwdata <= 32'h0000_0000;
        dout <= 32'h0000_0000;
      end
      //读写开始之前向总线发送控制信号的准备阶段
      //地址haddr、读写控制信号hwrite给送到了总线上
      control:begin 
        haddr <= addr;
        hwrite <= wr;
        hready <= 1'b1;
        hwdata <= 32'h0000_0000;
        dout <=  32'h0000_0000;
      end
      //将数据放到数据线上
      write: begin 
        haddr <= 32'h0000_0000;
        hwrite <= 1'b0;
        hready <= 1'b0;
        hwdata <= din;
        dout <=  32'h0000_0000;
      end
      read: begin 
        haddr <= 32'h0000_0000;
        hwrite <= 1'b0;
        hready <= 1'b0;
        hwdata <=  32'h0000_0000;
        dout <= hrdata;
      end
      default: begin 
        haddr <= 32'h0000_0000;
        hwrite <= 1'b0;
        hready <= 1'b0;
        hwdata <= 32'h0000_0000;
        dout <= 32'h0000_0000;
      end
    endcase
  end
end
endmodule