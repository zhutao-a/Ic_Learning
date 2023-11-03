`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/13 16:04:51
// Design Name: 
// Module Name: data_driver
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


module data_driver(
	input            clk_a,
	input            rst_n,
	input            data_ack,
	output reg [3:0] data,
	output reg       data_req
    );


reg data_ack_1;
reg data_ack_2;
//打两拍，消除亚稳态
always@(posedge clk_a or negedge rst_n) begin
	if(rst_n==1'b0) begin
		data_ack_1<=1'b0;
		data_ack_2<=1'b0;
	end
	else begin
		data_ack_1<=data_ack;
		data_ack_2<=data_ack_1;
	end
end

reg[2:0] count;
// count计数模块
always @(posedge clk_a or negedge rst_n) begin
	if (rst_n==1'b0)
	  count <= 3'b0;
	else if (data_ack_1 && !data_ack_2)
	  count <= 3'b0;
	else if (data_req)
	  count <= count;
	else
	  count <= count + 1;
end

// 输出数据data
always @(posedge clk_a or negedge rst_n) begin
	if (rst_n==1'b0)
	  data <= 4'b0;
	else if (data_ack_1 && !data_ack_2)
		if (data == 4'd7)
			data <= 4'd0;
		else
			data <= data + 1;
	else
	  data <= data;
end

// data_req信号
always @(posedge clk_a or negedge rst_n) begin
	if (rst_n==1'b0)
	  data_req <= 1'b0;
	else if (count == 3'd4)
	  data_req <= 1'b1;
	else if (data_ack_1 && !data_ack_2)
	  data_req <= 1'b0;
	else
	  data_req <= data_req;
end


    
endmodule
