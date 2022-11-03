module fetch_stage(
  input        clk,
  input        pc_src,
  input        pc_branch,

  output [31:0]instr_o,
  output [31:0]pc_plus1_o
);

reg  [31:0]pc       = 32'hFFFFFFFF;
wire [31:0]pc_plus1 = pc + 1;
wire [31:0]pc_next  = pc_src ? pc_branch : pc_plus1;

assign pc_plus1_o = pc_plus1;

always @(posedge clk) begin
  pc <= pc_next;
  $strobe("F[%h]: %h", pc, instr_o);
end

rom instr_memory(
  .clk (clk    ),
  .addr(pc     ),
  .q   (instr_o)
);

endmodule

