module fd_latch(
  input        clk,
  input  [31:0]instr_i,
  input  [31:0]pc_plus1_i,

  output [31:0]instr_o,
  output [31:0]pc_plus1_o
);

reg [31:0]instr;
reg [31:0]pc_plus1;

assign instr_o    = instr;
assign pc_plus1_o = pc_plus1;

always_ff @(posedge clk) begin
  instr    <= instr_i;
  pc_plus1 <= pc_plus1_i;
end

endmodule

