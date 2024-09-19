module DPRAM #
	(
		parameter WIDTH = 16 ,					// DPRAM数据总线宽度
		parameter DEPTH = 16 ,					// DPRAM存储深度
		parameter ADDR  = 4 					// DPRAM地址总线宽度
 
	)
	(
		input					wrclk	,		// 写时钟
		input					rdclk	,		// 读时钟
		input					rd_rst_n,		// 读复位
		input					wr_en	,		// 写使能
		input					rd_en	,		// 读使能
		input		[WIDTH-1:0]	wr_data	,		// 写数据
		output	reg [WIDTH-1:0] rd_data	,		// 读数据
		input	    [ADDR-1:0]  wr_addr	,		// 写地址
		input	    [ADDR-1:0]  rd_addr			// 读地址
    );
 
 
	reg [WIDTH-1:0] DPRAM [DEPTH-1:0];
 
 
	// RAM写数据
	always @(posedge wrclk) begin
		if (wr_en)
			DPRAM[wr_addr] <= wr_data;
	end
 
 
	// RAM读数据
	always @(posedge rdclk or negedge rd_rst_n) begin
		if(!rd_rst_n)
			rd_data <= 'b0;
		else if (rd_en)
			rd_data <= DPRAM[rd_addr];
	end
endmodule