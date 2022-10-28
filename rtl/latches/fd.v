module fd_latch(
  input        clk,
  input  [31:0]instr_i,
  output [31:0]instr_o
);

reg [31:0]instr;

assign instr_o = instr;

always_ff @(posedge clk) begin
  instr <= instr_i;
end

endmodule

