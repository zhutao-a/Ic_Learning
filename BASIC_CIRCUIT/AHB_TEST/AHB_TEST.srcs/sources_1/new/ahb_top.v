module ahb_top(
  input hclk,//总线时钟
  input hresetn,//复位信号
  input enable,//top--->master，使能信号，决定是否进行读写操作
  input [31:0] din,//top--->master，输入数据
  input [31:0] addr,//top--->master，读写地址
  input wr,//top--->master，读写控制信号

  output [31:0] dout//master--->top，master读取到的slave的数据，输出到top方便查看
);

//--------------------------------------------------
// Connect wires
//--------------------------------------------------


wire [1:0] sel;
wire [31:0] haddr;
wire hwrite;
wire hready;
wire [31:0] hwdata;

wire [31:0] hrdata;
wire hreadyout;

wire hreadyout_1;
wire hreadyout_2;
wire hreadyout_3;
wire hreadyout_4;

wire [31:0]hrdata_1;
wire [31:0]hrdata_2;
wire [31:0]hrdata_3;
wire [31:0]hrdata_4;

//--------------------------------------------------
// AHB Master
//--------------------------------------------------

ahb_master master(
  .hclk(hclk),
  .hresetn(hresetn),
  .enable(enable),
  .din(din),
  .addr(addr),
  .wr(wr),
  .hreadyout(hreadyout),
  .hrdata(hrdata),
  .haddr(haddr),
  .hwrite(hwrite),
  .hready(hready),
  .hwdata(hwdata),
  .dout(dout)
);

//--------------------------------------------------
// AHB Slave
//--------------------------------------------------
ahb_slave slave1(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_1),
  .haddr(haddr),
  .hwrite(hwrite),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_1),
  .hrdata(hrdata_1)
);
ahb_slave slave2(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_2),
  .haddr(haddr),
  .hwrite(hwrite),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_2),
  .hrdata(hrdata_2)
);
ahb_slave slave3(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_3),
  .haddr(haddr),
  .hwrite(hwrite),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_3),
  .hrdata(hrdata_3)
);
ahb_slave slave4(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_4),
  .haddr(haddr),
  .hwrite(hwrite),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_4),
  .hrdata(hrdata_4)
);
//--------------------------------------------------
// AHB Decoder
//--------------------------------------------------
decoder  u_decoder (
    .addr (addr[31:0]),

    .hsel_1( hsel_1),
    .hsel_2( hsel_2),
    .hsel_3( hsel_3),
    .hsel_4( hsel_4),

    .sel(sel)
);
//--------------------------------------------------
// AHB Mux
//--------------------------------------------------

mux  u_mux (
    .hrdata_1                ( hrdata_1     [31:0] ),
    .hrdata_2                ( hrdata_2     [31:0] ),
    .hrdata_3                ( hrdata_3     [31:0] ),
    .hrdata_4                ( hrdata_4     [31:0] ),
    .hreadyout_1             ( hreadyout_1         ),
    .hreadyout_2             ( hreadyout_2         ),
    .hreadyout_3             ( hreadyout_3         ),
    .hreadyout_4             ( hreadyout_4         ),
    .sel                     ( sel          [1:0]  ),

    .hrdata                  ( hrdata       [31:0] ),
    .hreadyout               ( hreadyout           )
);
endmodule