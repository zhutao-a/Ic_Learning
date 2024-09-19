`timescale 1ns/1ns

// 数据接收模块
module data_receiver(
	input            clk_b,
	input            rst_n,
	input      [3:0] data,
	input            data_req,
	output reg       data_ack
);

reg data_req_1;
reg data_req_2;
reg [3:0] data_in;

// 打两拍消除亚稳态
always @(posedge clk_b or negedge rst_n) begin
  if (~rst_n) begin
    data_req_1 <= 1'b0;
    data_req_2 <= 1'b0;
  end else begin
    data_req_1 <= data_req;
    data_req_2 <= data_req_1;
  end
end

// data_ack信号
always @(posedge clk_b or negedge rst_n) begin
  if (~rst_n) begin
    data_ack <= 1'b0;
  end else if (data_req_1) begin
    data_ack <= 1'b1;
  end else begin
    data_ack <= 1'b0;
  end
end

// 接收data数据到data_in
always @(posedge clk_b or negedge rst_n) begin
  if (~rst_n) begin
    data_in <= 4'b0;
  end else if (data_req_1 && !data_req_2) begin
    data_in <= data;
  end else begin
    data_in <= data_in;
  end
end

endmodule
