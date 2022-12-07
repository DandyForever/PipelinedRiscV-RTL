module sign_ext(
  input  [11:0]imm12,
  output [31:0]imm32
);

assign imm32 = {{20{imm12[11]}}, imm12};

endmodule
