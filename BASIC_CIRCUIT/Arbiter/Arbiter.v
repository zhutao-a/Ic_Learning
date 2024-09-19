`timescale 1ns/1ps
//the priority of one in base is highest,and decrease from right to left
module fixed_priority_arbiter 
#(      
    parameter NUM_REQ = 4
)
(
    input   wire [NUM_REQ-1:0] request   ,
    input   wire [NUM_REQ-1:0] base      ,

    output  wire [NUM_REQ-1:0] grant   
);

wire[2*NUM_REQ-1:0] extend_request;
wire[2*NUM_REQ-1:0] extend_grant;

assign extend_request = {request,request};
assign extend_grant   = extend_request& (~(extend_request-base));
assign grant          = extend_grant[NUM_REQ-1:0]|extend_grant[2*NUM_REQ-1:NUM_REQ];

endmodule

module round_robin_arbiter 
#(
    parameter NUM_REQ = 4
)
(
    input   wire                 clk     ,
    input   wire                 rstn    ,
    input   wire [NUM_REQ-1:0]   request ,

    output  wire [NUM_REQ-1:0]   grant
);

reg [NUM_REQ-1:0]   base;

//make the granted to be least priority in next grant
always@(posedge clk or negedge rstn) begin
    if (!rstn) 
        base<={{(NUM_REQ-1){1'b0}},1'b1};
    else if(grant=='b0)
        base<={{(NUM_REQ-1){1'b0}},1'b1};
    else
        base<={grant[NUM_REQ-2:0],grant[NUM_REQ-1]};
end

fixed_priority_arbiter 
#(      
    .NUM_REQ (NUM_REQ)
)
fixed_priority_arbiter_u
(
    .request(request    ),
    .base   (base       ),
                       
    .grant  (grant      )
);

endmodule

