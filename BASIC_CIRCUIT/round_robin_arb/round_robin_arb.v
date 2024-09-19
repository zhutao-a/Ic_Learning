`timescale 1ns/1ps

// 利用二进制补码相与的方式完成固定优先级仲裁器
module arbiter_base 
#(      
    parameter NUM_REQ = 4
)
(
    input   wire[NUM_REQ-1:0] request   ,
    input   wire[NUM_REQ-1:0] base      ,// base是onehot码，1的那位优先级最高，从左开始优先级循环降低

    output  wire[NUM_REQ-1:0] grant   
);

wire[2*NUM_REQ-1:0] extend_request;
wire[2*NUM_REQ-1:0] extend_grant;

// 将request扩展从而使得能够减去base
assign extend_request={request,request};
// 求出扩展后的grant
assign extend_grant=extend_request& ~(extend_request-base);
// 高位的extend_grant或上低位的extend_grant即为最终的grant
assign grant = extend_grant[NUM_REQ-1:0] | extend_grant[2*NUM_REQ-1:NUM_REQ];

endmodule


module round_robin_arbiter 
#(
    parameter NUM_REQ = 4
)
(
    input   wire                clk     ,
    input   wire                rstn    ,
    input   wire[NUM_REQ-1:0]   request ,

    output  wire[NUM_REQ-1:0]   grant
);

reg [NUM_REQ-1:0]   base;

// 将原先的grant向左循环移位得到新的优先级
always@(posedge clk or negedge rstn) begin
    if (!rstn) 
        base<={{NUM_REQ-1{1'b0}},1'b1};
    else if(grant=='b0)
        base<={{NUM_REQ-1{1'b0}},1'b1};
    else
        base<={grant[NUM_REQ-2:0],grant[NUM_REQ-1]};
end

// 例化根据base决定优先级的固定优先级仲裁器
arbiter_base 
#(      
    .NUM_REQ (NUM_REQ)
)
u_arbiter_base
(
    .request(request    )  ,
    .base   (base       )  ,// base是onehot码，1的那位优先级最高，从左开始优先级循环降低
                       
    .grant  (grant      )
);

endmodule

