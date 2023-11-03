`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/24 16:51:34
// Design Name: 
// Module Name: dual_edge_triggered_filp_flop
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


module dual_edge_triggered_filp_flop(
    input  wire clk,
    input  wire d,
    output wire q
    );
    reg q_d1;
    reg q_d2;

    always @(posedge clk) begin
        q_d1<=d^q_d2;        
    end
    always @(negedge clk) begin
        q_d2<=d^q_d1;
    end
    /*
    对于q而言
    当clk上升沿到来的时候，q_d1<=d^q_d2，将此时的值代入q的计算公式得q=d^q_d2^q_d2=d
    当clk下降沿到来的时候，q_d2<=d^q_d1，将此时的值代入q的计算公式得q=q_d1^d^q_d1=d
    于是实现了在上升沿和下降沿的采值
    */
    assign q=q_d1^q_d2;

endmodule
