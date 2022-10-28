module fetch_stage(
  input        clk,

  output [31:0]instr_o
);

reg  [31:0]pc      = 32'hFFFFFFFF;
wire [31:0]pc_next = pc + 1;

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

