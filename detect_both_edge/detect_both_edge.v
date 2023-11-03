`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/24 16:13:53
// Design Name: 
// Module Name: detect_both_edge
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


module detect_both_edge(
    input  wire         clk,
    input  wire [7:0]   in,
    output reg  [7:0]   anyedge
    );
    reg [7:0]   in_dff1;

    always @(posedge clk) begin
        in_dff1<=in;
    end

    always @(posedge clk) begin
        anyedge<=in^in_dff1;
    end

endmodule
