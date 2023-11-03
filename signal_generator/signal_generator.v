`timescale 1ns/1ns
module signal_generator(
    input clk,
    input rst_n,
    input [1:0] wave_choise,
    output reg [4:0]wave
    );
     reg cnt_type;   reg [5:0]cnt;
     always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt <= 0;
        else case(wave_choise) 
            0: cnt <= cnt<31 ? cnt+1 : 0;
            1: cnt <= cnt<30 ? cnt+2 : 0;
            2: cnt <= cnt<63 ? cnt+2 : 0;
            3: cnt <=0;
        endcase
     end 
     always@(posedge clk or negedge rst_n)begin
        if(!rst_n) 
            wave <= 5'd0;
        else case(wave_choise) 
            0: wave <= cnt<16 ? 5'd0 : 5'd31;
            1: wave <= cnt;
            2: wave <= (cnt>=31) ? (63-cnt) : cnt;
            3: wave <= 0;
        endcase
     end 
endmodule 
