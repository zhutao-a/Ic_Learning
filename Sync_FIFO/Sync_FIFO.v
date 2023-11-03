//利用计数器来判断full,empty的状态
module Sync_FIFO#(
    parameter   DATA_WIDTH = 4,
    parameter   DATA_DEPTH = 8,
    parameter   PTR_WIDTH  = 3
)
(
    input   wire                    clk     ,
    input   wire                    rst_n   ,
    input   wire                    w_en    ,
    input   wire                    r_en    ,
    input   wire[DATA_WIDTH-1:0]    w_data  ,
                                      
    output  reg[DATA_WIDTH-1:0]     r_data  ,
    output  reg                     full    , 
    output  reg                     empty
);

    //写地址生成
    reg[PTR_WIDTH-1 :0] w_ptr;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            w_ptr <= 'b0;
        else if(w_en && !full)
            w_ptr <= w_ptr + 1;      
    end

    //读地址生成
    reg[PTR_WIDTH-1 :0] r_ptr;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            r_ptr <= 'b0;
        else if(r_en && !empty)
            r_ptr <= r_ptr + 1;
    end

    //利用计数器的方式来判断元素数目
    reg[PTR_WIDTH   :0] elem_cnt;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            elem_cnt <= 'b0;
        else if(w_en && r_en && !full && !empty)
            elem_cnt <= elem_cnt;
        else if(w_en && !full)
            elem_cnt <= elem_cnt + 1;
        else if(!w_en && !empty)
            elem_cnt <= elem_cnt - 1;
    end

    //根据计数器来判断满与空的标志
    always@(*)begin
        if(!rst_n)
            full = 1'b0;
        else if(elem_cnt == 4'd8)
            full = 1'b1;
        else
            full = 1'b0;
    end
    always@(*)begin
        if(!rst_n)
            empty = 1'b0;
        else if(elem_cnt == 4'b0)
            empty = 1'b1;
        else
            empty = 1'b0;
    end

    //利用二维寄存器模拟ram并写入数据
    reg[DATA_WIDTH-1:0] mem_array[0:DATA_DEPTH-1];
    integer i;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < DATA_DEPTH; i = i + 1)begin:init_mem_array
                mem_array[i] <= 4'b0;
            end
        end
        else if(w_en && !full)
            mem_array[w_ptr] <= w_data;
    end

    //读数据
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            r_data <= 4'b0;
        else if(r_en && !empty)
            r_data <= mem_array[r_ptr];
    end

endmodule



//利用地址高位扩展来判断full,empty的状态
module Sync_FIFO2#(
    parameter   DATA_WIDTH = 4,
    parameter   DATA_DEPTH = 8,
    parameter   PTR_WIDTH  = 4      //地址高位扩展
)
(
    input   wire                    clk     ,
    input   wire                    rst_n   ,
    input   wire                    w_en    ,
    input   wire                    r_en    ,
    input   wire[DATA_WIDTH-1:0]    w_data  ,
                                      
    output  reg[DATA_WIDTH-1:0]     r_data  ,
    output  wire                    full    , 
    output  wire                    empty
);

    //高位扩展生成写地址
    reg[PTR_WIDTH-1:0]  w_ptr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_ptr<='b0;
        end
        else if (w_en&&!full) begin
            w_ptr<=w_ptr+1;
        end
    end

    //利用二维寄存器模拟ram并写入数据
    reg[DATA_WIDTH-1:0] mem_array[DATA_DEPTH-1:0];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            for(i=0;i<DATA_DEPTH;i=i+1)begin:init_mem_array
                mem_array[i]<='b0;
            end
        end
        else if(w_en&&!full) begin
            mem_array[w_ptr[PTR_WIDTH-2:0]]<=w_data;
        end
    end

    //利用高位扩展生成读地址
    reg[PTR_WIDTH-1:0]  r_ptr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_ptr<='b0;
        end
        else if (r_en&&!empty) begin
            r_ptr<=r_ptr+1;
        end  
    end

    //读数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_data<='b0;
        end
        else if (r_en&&!empty) begin
            r_data<=mem_array[r_ptr[PTR_WIDTH-2:0]];
        end
    end

    //empty标志位，如果读写地址相同则为空
    assign empty=(w_ptr==r_ptr)?1'b1:1'b0;

    //full标志位，如果读写地址最高位不同，其余相同则为满
    assign full=(w_ptr[PTR_WIDTH-1]!=r_ptr[PTR_WIDTH-1]&&w_ptr[PTR_WIDTH-2:0]==r_ptr[PTR_WIDTH-2:0])?1'b1:1'b0;

endmodule



