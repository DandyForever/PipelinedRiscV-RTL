module writeback_stage(
  input        clk,

  input        rf_we_i,
  input  [31:0]rf_waddr_i,
  input        mem2rf_i,
  input  [31:0]mem_rdata_i,
  input  [31:0]alu_result_i,

  output       rf_we_o,
  output [31:0]rf_waddr_o,
  output [31:0]alu_result_o
);

assign rf_we_o      = rf_we_i;
assign rf_waddr_o   = rf_waddr_i;
assign alu_result_o = mem2rf_i
                      ? mem_rdata_i
                      : alu_result_i;

endmodule

