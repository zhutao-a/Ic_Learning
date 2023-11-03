`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 16:28:22
// Design Name: 
// Module Name: data_driver
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

//数据发送模块
module data_driver(
    input clk_a,
    input rst_n,
    input data_ack,
    output reg [3:0]data,
    output reg data_req
    );
    
    //打拍，将data_ack同步到clk_a下
    reg [2:0] ack_r;
    always @(posedge clk_a or negedge rst_n) begin
        if(rst_n==1'b0) 
            ack_r <= 3'b000;
        else
            ack_r <= {ack_r[1:0],data_ack};
    end

    //进行双沿检测，每当data_receiver接收到一个数据时，data_ack进行翻转，ack_pos为1表明data_receiver已经接收到数据了
    wire ack_pos;
    assign ack_pos = ack_r[1]^ack_r[2];

    //当确认data_receiver接收到数据后（ack_pos==1）生成新的发送数据
    always @(posedge clk_a or negedge rst_n) begin
        if(rst_n==1'b0) 
            data  <= 4'b0;      
        else if(ack_pos==1'b1) begin
            if(data == 4'd7)
                data  <= 4'b0;
            else 
                data  <= data + 1'b1;
        end        
    end 

    //当确认接收端接收到数据后，延迟5个时钟发送数据
    reg [2:0] cnt;
    always @(posedge clk_a or negedge rst_n) begin
        if(rst_n==1'b0) 
            cnt <= 3'd0;
        else if(ack_pos==1'b1)
            cnt <= 3'd0;
        else if(data_req==1'b0)
            cnt <= cnt + 1'b1;
    end 

    //等待5个时钟后，将req拉高，发送数据
    always @(posedge clk_a or negedge rst_n) begin
        if(rst_n==1'b0) begin
            data_req  <= 1'b0;      
        end 
        else if(ack_pos)
            data_req <= 1'b0;
        else if(cnt == 3'd4)
            data_req <= 1'd1;
    end 

endmodule




//数据接收模块
module data_receiver(
    input clk_b,
    input rst_n,
    output reg data_ack,
    input [3:0]data,
    input data_req
    );

    //打拍，将data_req同步到时钟clk_b下
    reg [2:0] req_r;
    always @(posedge clk_b or negedge rst_n) begin
        if(~rst_n) begin
            req_r <= 3'b0;      
        end 
        else begin
            req_r <= {req_r[1:0],data_req};
        end        
    end   

    //检测data_req的上升沿，表明数据准备完毕
    wire req_pos;
    assign req_pos = req_r[1]&(~req_r[2]);

    //接收数据，并存放在data_reg中
    reg [3:0] data_reg;
    always @(posedge clk_b or negedge rst_n) begin
        if(~rst_n)
           data_reg <= 4'd0;
       else if(req_pos)
           data_reg <= data;
   end

   //接收到数据后，将data_ack翻转产生一个边沿，告诉data_driver接收模块成功接收到数据
    always @(posedge clk_b or negedge rst_n) begin
        if(~rst_n) begin
            data_ack <= 1'b0;      
        end 
        else if(req_pos)
            data_ack <= ~data_ack;
    end 

endmodule           