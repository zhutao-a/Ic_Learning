`timescale 1ns/1ns

module width_24to128(
    input   wire        clk     ,   
    input   wire        rstn    ,
    input   wire        validin ,
    input   wire[23:0]  datain  ,

    output  reg         validout,
    output  reg[127:0]  dataout
);

// lcm(24,128)=384=128*3=24*16
// for input 16 is a cycle, for output 3 is a cycle 

reg [119:0] buffer;
reg [3:0] cnt;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt<='d0; 
    end
    else if (validin) begin
        cnt<=cnt+1; 
    end
end

// left shift for buffer
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        buffer<='d0;
    end
    else if (validin) begin
        buffer<={buffer[95:0],datain};
    end
end

// when buffer data num + datain num >=128, assert validout
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        validout<=1'b0;
    end
    else if (validin&&(cnt==5||cnt==11||cnt==15)) begin
        validout<=1'b1;
    end
    else begin
        validout<=1'b0;
    end
end

// because buffer max index is 119, so the buffer depth is 120
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dataout<='d0;
    end
    else if (validin) begin
        if (cnt==5) begin//first data in a cycle
            dataout<={buffer[119:0],datain[23:16]};
        end
        else if (cnt==11) begin//second data in a cycle
            dataout<={buffer[111:0],datain[23:8]};
        end
        else if (cnt==15) begin//third data in a cycle
            dataout<={buffer[103:0],datain};
        end
    end
end
    
endmodule




module width_128to24 (
    input  wire         clk     ,
    input  wire         rstn    ,
    input  wire         validin ,
    input  wire [127:0] datain  ,

    output wire         validout,
    output wire [23:0]  dataout ,
    output wire         ready
);





endmodule



