module alu(
  input      [31:0]src_a,
  input      [31:0]src_b,
  input       [2:0]op,
  input            alt,

  output reg [31:0]res
);

wire signed [31:0]a_sign;
wire signed [31:0]b_sign;

assign a_sign = src_a;
assign b_sign = src_b;

wire [4:0]shamt = src_b[4:0];

always_comb begin
  case (op)
    3'b000: res = src_a + (alt ? (~src_b + 1) : src_b);
    3'b001: res = src_a << shamt;
    3'b010: res = a_sign < b_sign;
    3'b011: res = src_a < src_b;
    3'b100: res = src_a ^ src_b;
    3'b101: if (alt) res = a_sign >>> shamt;
            else res = src_a >> shamt;
    3'b110: res = src_a | src_b;
    3'b111: res = src_a & src_b;
    default: res = 0;
  endcase
end

endmodule

