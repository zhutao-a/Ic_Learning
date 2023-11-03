`timescale 1ns / 1ps
module div  
(  
    input   wire    [31:0]  a       ,   
    input   wire    [31:0]  b       ,  
    input   wire            enable  ,
    output  reg     [31:0]  yshang  ,  
    output  reg     [31:0]  yyushu  ,
    output  reg             done 
);  
  
reg[31:0] tempa;  
reg[31:0] tempb;  
reg[63:0] temp_a;  
reg[63:0] temp_b;  

//锁存a和b
always@(a or b)begin  
    tempa <= a;  
    tempb <= b;  
end  

integer i;
always @(tempa or tempb)begin  
    if(enable)begin
        //将a高位添加32个0，b低位添加32个0
        temp_a = {32'h00000000,tempa};  
        temp_b = {tempb,32'h00000000};  
        done = 0; 
        //将temp_a循环向左移动共32次，移位后与temp_b比较，大于则temp_a-temp_b+1，否则不变
        for(i = 0;i < 32;i = i + 1)begin:cal  
                temp_a = {temp_a[62:0],1'b0};  
                if(temp_a[63:32] >= tempb)  
                    temp_a = temp_a - temp_b + 1'b1;  
                else  
                    temp_a = temp_a;  
        end
        //32轮迭代后temp_a的高32位即为余数，低32位即为商  
        yshang = temp_a[31:0];  
        yyushu = temp_a[63:32]; 
        done = 1; 
    end
end  
  
endmodule