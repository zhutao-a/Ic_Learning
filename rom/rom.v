`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 15:00:05
// Design Name: 
// Module Name: rom
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


module rom(
    input  wire         clk,
    input  wire         rst_n,
    input  wire [7:0]   addr,

    output wire [3:0]   data
    );
    reg [3:0]   rom_data[7:0];
    always @(posedge clk or negedge rst_n) begin
        if(rst_n==1'b0) begin
            rom_data[0]<=4'd0;
            rom_data[1]<=4'd2;
            rom_data[2]<=4'd4;
            rom_data[3]<=4'd6;
            rom_data[4]<=4'd8;
            rom_data[5]<=4'd10;
            rom_data[6]<=4'd12;
            rom_data[7]<=4'd14;
        end 
        else begin
            rom_data[0]<=rom_data[0];
            rom_data[1]<=rom_data[1];
            rom_data[2]<=rom_data[2];
            rom_data[3]<=rom_data[3];
            rom_data[4]<=rom_data[4];
            rom_data[5]<=rom_data[5];
            rom_data[6]<=rom_data[6];
            rom_data[7]<=rom_data[7];
        end
    end

    assign data=rom_data[addr];


endmodule
