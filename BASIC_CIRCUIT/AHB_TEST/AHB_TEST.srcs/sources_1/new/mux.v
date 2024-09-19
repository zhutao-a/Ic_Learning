module mux(
  input [31:0] hrdata_1,
  input [31:0] hrdata_2,
  input [31:0] hrdata_3,
  input [31:0] hrdata_4,
  input hreadyout_1,
  input hreadyout_2,
  input hreadyout_3,
  input hreadyout_4,
  input [1:0] sel,
  output [31:0] hrdata,
  output hreadyout
);
reg [31:0]hrdata_r;
reg hreadyout_r;

assign hrdata = hrdata_r;
assign hreadyout = hreadyout_r;

always @(*) begin
  case(sel)
    2'b00: begin
      hrdata_r = hrdata_1;
      hreadyout_r = hreadyout_1;

    end
    2'b01: begin
      hrdata_r = hrdata_2;
      hreadyout_r = hreadyout_2;

    end
    2'b10: begin
      hrdata_r = hrdata_3;
      hreadyout_r = hreadyout_3;

    end
    2'b11: begin
      hrdata_r = hrdata_4;
      hreadyout_r = hreadyout_4;

    end
    default: begin
      hrdata_r = 32'h0000_0000;
      hreadyout_r = 1'b0;
    end
  endcase
end
endmodule