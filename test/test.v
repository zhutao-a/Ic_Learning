`timescale 1ns / 1ps

module test(
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [4:0] c,

    output wire [5:0] d
);

assign d = a+c+b;

endmodule
