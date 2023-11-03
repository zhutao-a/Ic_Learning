module decoder(
  input [31:0] addr,
  output hsel_1,
  output hsel_2,
  output hsel_3,
  output hsel_4,

  output [1:0]sel 
);

reg hsel_1_r;
reg hsel_2_r;
reg hsel_3_r;
reg hsel_4_r;

assign hsel_1 = hsel_1_r;
assign hsel_2 = hsel_2_r;
assign hsel_3 = hsel_3_r;
assign hsel_4 = hsel_4_r;

assign sel = addr[31:30];

always @(*) begin
  case(sel)
    2'b00: begin
      hsel_1_r = 1'b1;
      hsel_2_r = 1'b0;
      hsel_3_r = 1'b0;
      hsel_4_r = 1'b0;
    end
    2'b01: begin
      hsel_1_r = 1'b0;
      hsel_2_r = 1'b1;
      hsel_3_r = 1'b0;
      hsel_4_r = 1'b0;
    end
    2'b10: begin
      hsel_1_r = 1'b0;
      hsel_2_r = 1'b0;
      hsel_3_r = 1'b1;
      hsel_4_r = 1'b0;
    end
    2'b11: begin
      hsel_1_r = 1'b0;
      hsel_2_r = 1'b0;
      hsel_3_r = 1'b0;
      hsel_4_r = 1'b1;
    end
    default: begin
      hsel_1_r = 1'b0;
      hsel_2_r = 1'b0;
      hsel_3_r = 1'b0;
      hsel_4_r = 1'b0;
    end
  endcase
end
endmodule