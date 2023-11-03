// question:a:input,b:output,when detect sequence 101101 then b equal 1 else equal 0
// example: 
// a      : 0001100110110110100110
// b      : 0000000000100100000000

//moore three-stage state machine   sequence_detector1
//moore two-stage state machine     sequence_detector2
//mealy state machine               sequence_detector3

//moore three-stage state machine
module sequence_detector1 (
    input  wire clk,
    input  wire rstn,
    input  wire a,

    output reg  b
);

localparam IDLE=3'd0,S_1=3'd1, S_10=3'd2,S_101=3'd3, S_1011=3'd4,S_10110=3'd5, S_101101=3'd6;

reg [2:0] current_state, next_state;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state<='d0;
    end
    else begin
        current_state<=next_state;
    end
end

always @(*) begin
    case (current_state)
        IDLE: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_1: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=S_10;
            end
        end
        S_10: begin
            if (a) begin
                next_state=S_101;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_101: begin
            if (a) begin
                next_state=S_1011;
            end
            else begin
                next_state=S_10;
            end
        end
        S_1011: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=S_10110;
            end
        end
        S_10110: begin
            if (a) begin
                next_state=S_101101;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_101101: begin
            if (a) begin
                next_state=S_1011;
            end
            else begin
                next_state=S_10;
            end
        end     
        default: next_state=IDLE;
    endcase
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        b<=1'b0;
    end
    else if (next_state==S_101101) begin
        b<=1'b1;
    end
    else begin
        b<=1'b0;
    end
end
    
endmodule

//moore two-stage state machine
module sequence_detector2 (
    input  wire clk,
    input  wire rstn,
    input  wire a,

    output wire b
);

localparam IDLE=3'd0,S_1=3'd1, S_10=3'd2,S_101=3'd3, S_1011=3'd4,S_10110=3'd5, S_101101=3'd6;

reg [2:0] current_state, next_state;

assign b = (current_state==S_101101)?1'b1:1'b0;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state<='d0;
    end
    else begin
        current_state<=next_state;
    end
end

always @(*) begin
    case (current_state)
        IDLE: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_1: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=S_10;
            end
        end
        S_10: begin
            if (a) begin
                next_state=S_101;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_101: begin
            if (a) begin
                next_state=S_1011;
            end
            else begin
                next_state=S_10;
            end
        end
        S_1011: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=S_10110;
            end
        end
        S_10110: begin
            if (a) begin
                next_state=S_101101;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_101101: begin
            if (a) begin
                next_state=S_1011;
            end
            else begin
                next_state=S_10;
            end
        end     
        default: next_state=IDLE;
    endcase
end
    
endmodule

//mealy state machine
module sequence_detector3 (
    input  wire clk,
    input  wire rstn,
    input  wire a,

    output wire b
);

localparam IDLE=3'd0,S_1=3'd1, S_10=3'd2,S_101=3'd3, S_1011=3'd4,S_10110=3'd5;

reg [2:0] current_state, next_state;

assign b = ((current_state==S_10110)&&(a==1'b1))?1'b1:1'b0;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state<='d0;
    end
    else begin
        current_state<=next_state;
    end
end

always @(*) begin
    case (current_state)
        IDLE: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_1: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=S_10;
            end
        end
        S_10: begin
            if (a) begin
                next_state=S_101;
            end
            else begin
                next_state=IDLE;
            end
        end
        S_101: begin
            if (a) begin
                next_state=S_1011;
            end
            else begin
                next_state=S_10;
            end
        end
        S_1011: begin
            if (a) begin
                next_state=S_1;
            end
            else begin
                next_state=S_10110;
            end
        end
        S_10110: begin
            if (a) begin
                next_state=S_101;
            end
            else begin
                next_state=IDLE;
            end
        end   
        default: next_state=IDLE;
    endcase
end

    
endmodule