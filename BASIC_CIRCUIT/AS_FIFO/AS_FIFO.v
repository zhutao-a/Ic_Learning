`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/28 16:25:53
// Design Name: 
// Module Name: AS_FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AS_FIFO
#(
    parameter WIDTH = 16,		// FIFO数据总线位宽
    parameter PTR   = 4			// FIFO存储深度(bit数，深度只能是2^n个)
)
(
    // write interface
    input   wire 			w_clk	,		// 写时钟
    input	wire			w_rst_n,		// 写指针复位
    input   wire[WIDTH-1:0] wr_data	,		// 写数据总线
    input	wire			w_en	,		// 写使能
    output  reg				full	,		// 写满标志
    //read interface
    input	wire			r_clk	,		// 读时钟
    input	wire			r_rst_n,		// 读指针复位
    input	wire			r_en	,		// 读使能
    output	wire[WIDTH-1:0] rd_data	,		// 读数据输出
    output	reg				empty		// 读空标志
);
 
	// 写时钟域信号定义
	reg [PTR:0] w_addr_bin		;					// 二进制写地址
	reg [PTR:0] w_addr_gray		;					// 格雷码写地址
	reg [PTR:0] r_addr_gray_ff1 ;					// 格雷码读地址同步寄存器1
	reg [PTR:0] r_addr_gray_ff2 ;					// 格雷码读地址同步寄存器2
	reg [PTR:0] rd_bin_wr	;					// 同步到写时钟域的二进制读地址
 
 
	// 读时钟域信号定义
	reg [PTR:0] r_addr_bin		;					// 二进制读地址
	reg [PTR:0] r_addr_gray		;					// 格雷码读地址
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
	always @(posedge w_clk or posedge w_rst_n) begin
		if (!w_rst_n) begin
			w_addr_bin <= 'b0;
		end
		else if( w_en == 1'b1 && full == 1'b0 ) begin
			w_addr_bin <= w_addr_bin + 1'b1;
		end
		else begin
			w_addr_bin <= w_addr_bin;
		end
	end
 
	// 写地址：二进制转格雷码
	always @(posedge w_clk or posedge w_rst_n) begin
		if (!w_rst_n) begin
			w_addr_gray <= 'b0;
		end
		else begin
			w_addr_gray <= { w_addr_bin[PTR], w_addr_bin[PTR:1] ^ w_addr_bin[PTR-1:0] };
		end
	end

	// 格雷码读地址同步至写时钟域
	always @(posedge w_clk or posedge w_rst_n) begin
		if(!w_rst_n) begin
			r_addr_gray_ff1 <= 'b0;
			r_addr_gray_ff2 <= 'b0;
		end
		else begin
			r_addr_gray_ff1 <= r_addr_gray;
			r_addr_gray_ff2 <= r_addr_gray_ff1;
		end
	end

	// 同步后的读地址解格雷
	always @(*) begin
		rd_bin_wr[PTR] = r_addr_gray_ff2[PTR];
		for ( i=PTR-1; i>=0; i=i-1 )
			rd_bin_wr[i] = rd_bin_wr[i+1] ^ r_addr_gray_ff2[i];
	end

	// 写时钟域产生写满标志
	always @(*) begin
		if( (w_addr_bin[PTR] != rd_bin_wr[PTR]) && (w_addr_bin[PTR-1:0] == rd_bin_wr[PTR-1:0]) ) begin
			full = 1'b1;
		end
		else begin
			full = 1'b0;
		end
	end

	// ******************************** 读时钟域 ******************************** //
	always @(posedge r_clk or posedge r_rst_n) begin
		if (!r_rst_n) begin
			r_addr_bin <= 'b0;
		end
		else if ( r_en == 1'b1 && empty == 1'b0 ) begin
			r_addr_bin <= r_addr_bin + 1'b1;
		end
		else begin
			r_addr_bin <= r_addr_bin;
		end
	end

	// 读地址：二进制转格雷码
	always @(posedge r_clk or posedge r_rst_n) begin
		if (!r_rst_n) begin
			r_addr_gray <= 'b0;
		end
		else begin
			r_addr_gray <= { r_addr_bin[PTR], r_addr_bin[PTR:1] ^ r_addr_bin[PTR-1:0] };
		end
	end
 
	// 格雷码写地址同步至读时钟域
	always @(posedge r_clk or posedge r_rst_n) begin
		if(!r_rst_n) begin
			wr_gray_ff1 <= 'b0;
			wr_gray_ff2 <= 'b0;
		end
		else begin
			wr_gray_ff1 <= w_addr_gray;
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
		if( wr_bin_rd == r_addr_bin )
			empty = 1'b1;
		else
			empty = 1'b0;
	end
 
 
	// RTL双口RAM例化
	DPRAM
	#( 
        .WIDTH(16)  , 
        .DEPTH(16)  , 
        .ADDR(4) 
    )
	U_DPRAM
	(
		.w_clk		(w_clk		 	),
		.r_clk		(r_clk			),
		.r_rst_n   (r_rst_n		),
		.w_en 		(dpram_wr_en	),
		.r_en 		(dpram_rd_en	),
		.wr_data 	(dpram_wr_data	),
		.rd_data 	(dpram_rd_data	),
		.wr_addr 	(dpram_wr_addr	),
		.rd_addr 	(dpram_rd_addr	)
	);
 
 
	// 产生DPRAM读写控制信号
	assign dpram_wr_en   = ( w_en == 1'b1 && full == 1'b0 )? 1'b1 : 1'b0;
	assign dpram_wr_data = wr_data;
	assign dpram_wr_addr = w_addr_bin[PTR-1:0];
 
	assign dpram_rd_en   = ( r_en == 1'b1 && empty == 1'b0 )? 1'b1 : 1'b0;
	assign rd_data = dpram_rd_data;
	assign dpram_rd_addr = r_addr_bin[PTR-1:0];

endmodule



//DRAM模块
module DPRAM 
#(
	parameter WIDTH = 16 ,					// DPRAM数据总线宽度
	parameter DEPTH = 16 ,					// DPRAM存储深度
	parameter ADDR  = 4 					// DPRAM地址总线宽度
)
(
	input	wire			w_clk	,		// 写时钟
    input	wire			w_en	,		// 写使能
    input	wire[ADDR-1:0]  wr_addr	,		// 写地址
    input	wire[WIDTH-1:0]	wr_data	,		// 写数据

	input	wire			r_clk	,		// 读时钟
	input	wire			r_rst_n,		// 读复位
	input	wire			r_en	,		// 读使能
	input	wire[ADDR-1:0]  rd_addr	,		// 读地址
	output	reg[WIDTH-1:0]  rd_data			// 读数据
	
	
);

    reg [WIDTH-1:0] DPRAM [DEPTH-1:0];

    // RAM写数据
    always @(posedge w_clk) begin
        if(w_en)begin
            DPRAM[wr_addr] <= wr_data;
        end    
    end

    // RAM读数据
    always @(posedge r_clk or negedge r_rst_n) begin
        if(!r_rst_n)begin
            rd_data <= 'b0;
        end
        else if(r_en)begin
            rd_data <= DPRAM[rd_addr];
        end   
    end

endmodule