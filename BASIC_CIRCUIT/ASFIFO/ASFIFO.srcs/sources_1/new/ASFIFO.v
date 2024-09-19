`timescale 1ns / 1ns
//
// Company: Xidian University
// Engineer: Xumingwei
// 
// Create Date: 2020/11/06 20:52:45
// Design Name: 异步FIFO控制器
// Module Name: ASFIFO
// Project Name: ASFIFO
// Target Devices: XC7K325T
// Tool Versions: Vivado 2019.2
// Description: 本模块为异步FIFO控制器，将RAM操作为ASFIFO
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//
 
 
module ASFIFO#
	(
		parameter WIDTH = 16,		// FIFO数据总线位宽
		parameter PTR   = 4			// FIFO存储深度(bit数，深度只能是2^n个)
	)
	(
		// write interface
		input					wrclk	,		// 写时钟
		input					wr_rst_n,		// 写指针复位
		input	[WIDTH-1:0]		wr_data	,		// 写数据总线
		input					wr_en	,		// 写使能
		output  reg				wr_full	,		// 写满标志
 
		//read interface
		input					rdclk	,		// 读时钟
		input					rd_rst_n,		// 读指针复位
		input					rd_en	,		// 读使能
		output	[WIDTH-1:0]		rd_data	,		// 读数据输出
		output	reg				rd_empty		// 读空标志
    );
 
 
	// 写时钟域信号定义
	reg [PTR:0] wr_bin		;					// 二进制写地址
	reg [PTR:0] wr_gray		;					// 格雷码写地址
	reg [PTR:0] rd_gray_ff1 ;					// 格雷码读地址同步寄存器1
	reg [PTR:0] rd_gray_ff2 ;					// 格雷码读地址同步寄存器2
	reg [PTR:0] rd_bin_wr	;					// 同步到写时钟域的二进制读地址
 
 
	// 读时钟域信号定义
	reg [PTR:0] rd_bin		;					// 二进制读地址
	reg [PTR:0] rd_gray		;					// 格雷码读地址
	reg [PTR:0] wr_gray_ff1 ;					// 格雷码写地址同步寄存器1
	reg [PTR:0] wr_gray_ff2 ;					// 格雷码写地址同步寄存器2
	reg [PTR:0] wr_bin_rd	;					// 同步到读时钟域的二进制写地址
 
 
	// 解格雷码电路循环变量
	integer i ;
	integer j ;
 
 
	// DPRAM控制信号
	wire  				dpram_wr_en		 ;		// DPRAM写使能
	wire [PTR-1:0]		dpram_wr_addr    ;		// DPRAM写地址
	wire [WIDTH-1:0] 	dpram_wr_data	 ;		// DPRAM写数据
	wire  				dpram_rd_en		 ;		// DPRAM读使能
	wire [PTR-1:0]		dpram_rd_addr    ;		// DPRAM读地址
	wire [WIDTH-1:0] 	dpram_rd_data	 ;		// DPRAM读数据
 
 
 
	// ******************************** 写时钟域 ******************************** //
	// 二进制写地址递增
	always @(posedge wrclk or posedge wr_rst_n) begin
		if (!wr_rst_n) begin
			wr_bin <= 'b0;
		end
		else if ( wr_en == 1'b1 && wr_full == 1'b0 ) begin
			wr_bin <= wr_bin + 1'b1;
		end
		else begin
			wr_bin <= wr_bin;
		end
	end
 
 
	// 写地址：二进制转格雷码
	always @(posedge wrclk or posedge wr_rst_n) begin
		if (!wr_rst_n) begin
			wr_gray <= 'b0;
		end
		else begin
			wr_gray <= { wr_bin[PTR], wr_bin[PTR:1] ^ wr_bin[PTR-1:0] };
		end
	end
	// 格雷码读地址同步至写时钟域
	always @(posedge wrclk or posedge wr_rst_n) begin
		if(!wr_rst_n) begin
			rd_gray_ff1 <= 'b0;
			rd_gray_ff2 <= 'b0;
		end
		else begin
			rd_gray_ff1 <= rd_gray;
			rd_gray_ff2 <= rd_gray_ff1;
		end
	end
	// 同步后的读地址解格雷
	always @(*) begin
		rd_bin_wr[PTR] = rd_gray_ff2[PTR];
		for ( i=PTR-1; i>=0; i=i-1 )
			rd_bin_wr[i] = rd_bin_wr[i+1] ^ rd_gray_ff2[i];
	end
	// 写时钟域产生写满标志
	always @(*) begin
		if( (wr_bin[PTR] != rd_bin_wr[PTR]) && (wr_bin[PTR-1:0] == rd_bin_wr[PTR-1:0]) ) begin
			wr_full = 1'b1;
		end
		else begin
			wr_full = 1'b0;
		end
	end
	// ******************************** 读时钟域 ******************************** //
	always @(posedge rdclk or posedge rd_rst_n) begin
		if (!rd_rst_n) begin
			rd_bin <= 'b0;
		end
		else if ( rd_en == 1'b1 && rd_empty == 1'b0 ) begin
			rd_bin <= rd_bin + 1'b1;
		end
		else begin
			rd_bin <= rd_bin;
		end
	end
	// 读地址：二进制转格雷码
	always @(posedge rdclk or posedge rd_rst_n) begin
		if (!rd_rst_n) begin
			rd_gray <= 'b0;
		end
		else begin
			rd_gray <= { rd_bin[PTR], rd_bin[PTR:1] ^ rd_bin[PTR-1:0] };
		end
	end
 
 
	// 格雷码写地址同步至读时钟域
	always @(posedge rdclk or posedge rd_rst_n) begin
		if(!rd_rst_n) begin
			wr_gray_ff1 <= 'b0;
			wr_gray_ff2 <= 'b0;
		end
		else begin
			wr_gray_ff1 <= wr_gray;
			wr_gray_ff2 <= wr_gray_ff1;
		end
	end
 
 
	// 同步后的写地址解格雷
	always @(*) begin
		wr_bin_rd[PTR] = wr_gray_ff2[PTR];
		for ( j=PTR-1; j>=0; j=j-1 )
			wr_bin_rd[j] = wr_bin_rd[j+1] ^ wr_gray_ff2[j];
	end
 
 
	// 读时钟域产生读空标志
	always @(*) begin
		if( wr_bin_rd == rd_bin )
			rd_empty = 1'b1;
		else
			rd_empty = 1'b0;
	end
 
 
	// RTL双口RAM例化
	DPRAM
		# ( .WIDTH(16), .DEPTH(16), .ADDR(4) )
		U_DPRAM
		(
			.wrclk		(wrclk		 	),
			.rdclk		(rdclk			),
			.rd_rst_n   (rd_rst_n		),
			.wr_en 		(dpram_wr_en	),
			.rd_en 		(dpram_rd_en	),
			.wr_data 	(dpram_wr_data	),
			.rd_data 	(dpram_rd_data	),
			.wr_addr 	(dpram_wr_addr	),
			.rd_addr 	(dpram_rd_addr	)
		);
 
 
	// 产生DPRAM读写控制信号
	assign dpram_wr_en   = ( wr_en == 1'b1 && wr_full == 1'b0 )? 1'b1 : 1'b0;
	assign dpram_wr_data = wr_data;
	assign dpram_wr_addr = wr_bin[PTR-1:0];
 
	assign dpram_rd_en   = ( rd_en == 1'b1 && rd_empty == 1'b0 )? 1'b1 : 1'b0;
	assign rd_data = dpram_rd_data;
	assign dpram_rd_addr = rd_bin[PTR-1:0];
 
 
endmodule