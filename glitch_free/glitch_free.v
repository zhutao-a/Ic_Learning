`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/28 20:57:48
// Design Name: 
// Module Name: glitch_free
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


module glitch_free(
    input   wire    clk0    ,
    input   wire    clk1    ,
    input   wire    select  ,
    input   wire    rst_n   ,

    output  wire    outclk
    );

    reg     out1;
    reg     out0;
    always @(negedge clk1 or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            out1 <= 0;
        end
        else begin
            out1 <= ~out0 & select;
        end
    end
    always @(negedge clk0 or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            out0 <= 0;
        end
        else begin
            out0 <= ~select & ~out1;
        end
    end
    
    assign outclk = (out1 & clk1) | (out0 & clk0);

endmodule




module glitch_free1 (
    input   wire    clk0    ,
    input   wire    clk1    ,
    input   wire    select  ,
    input   wire    rst_n   ,

    output  wire    outclk
);
 
    reg     out_r1;
    reg     out1;
    reg     out_r0;
    reg     out0;
 
 always @(posedge clk1 or negedge rst_n)begin
     if(rst_n == 1'b0)begin
         out_r1 <= 0;
     end
     else begin
         out_r1 <= ~out0 & select;
     end
 end
 
 always @(negedge clk1 or negedge rst_n)begin
     if(rst_n == 1'b0)begin
         out1 <= 0;
     end
     else begin
         out1 <= out_r1;
     end
 end
 
 always @(posedge clk0 or negedge rst_n)begin
     if(rst_n == 1'b0)begin
         out_r0 <= 0;
     end
     else begin
         out_r0 <= ~select & ~out1;
     end
 end
 
 always @(negedge clk0 or negedge rst_n)begin
     if(rst_n == 1'b0)begin
         out0 <= 0;
     end
     else begin
         out0 <= out_r0;
     end
 end
 
 assign outclk = (out1 & clk1) | (out0 & clk0);






endmodule