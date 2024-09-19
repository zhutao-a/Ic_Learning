`timescale 1ns/1ns

module huawei6(
    input  clk0 ,
    input  clk1 ,
    input  sel ,
    input  rst ,
    output clk_out 
);
//*****************code******************//
    reg out0;
    reg out1;
    
    always@(negedge clk1 or negedge rst) begin
        if (~rst) begin 
            out1 <= 0;
        end 
        else begin 
            out1 <= sel & (~out0);
        end
    end
    
    always@(posedge clk0 or negedge rst) begin
        if (~rst) begin 
            out0 <= 0;
        end 
        else begin 
            out0 <= (~sel) & (~out1);
        end
    end
    
    assign clk_out = (out1 & clk1) | (out0 & clk0);
    
//*****************code******************//    
endmodule