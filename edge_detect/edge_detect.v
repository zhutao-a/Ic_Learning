`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/24 15:46:35
// Design Name: 
// Module Name: detect_an_edge
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


module detect_edge(
    input  wire clk,
    input  wire rstn,
    input  wire in,

    output wire pedge,
    output wire nedge,
    output wire bothedge
);

reg in_dff1;

assign pedge    = ~in_dff1&&in;
assign nedge    = ~in&in_dff1;
assign bothedge = in^in_dff1;


//delay a clk for in
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        in_dff1<=1'b0;
    end
    else begin
        in_dff1<=in;
    end
end

endmodule
