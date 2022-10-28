module memory_stage(
  input        clk,

  input        rf_we_i,
  input        mem_we_i,
  input        mem2rf_i,
  input  [31:0]mem_wdata_i,
  input  [31:0]rf_waddr_i,
  input  [31:0]alu_result_i,

  output       rf_we_o,
  output [31:0]rf_waddr_o,
  output       mem2rf_o,
  output [31:0]mem_rdata_o,
  output [31:0]alu_result_o
);

assign rf_we_o      = rf_we_i;
assign rf_waddr_o   = rf_waddr_i;
assign mem2rf_o     = mem2rf_i;
assign alu_result_o = alu_result_i;

ram ram(
  .clk(clk),
  .r_addr(alu_result_i),
  .w_addr(alu_result_i),
  .w_data(mem_wdata_i),
  .we(mem_we_i),
  .r_data(mem_rdata_o)
);

endmodule

