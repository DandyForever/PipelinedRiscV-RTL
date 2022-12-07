module writeback_stage #(
  parameter ADDR_W = 32,
  parameter DATA_W = 32
)(
  input clk,

// from ME
  input              rf_we_i,
  input  [ADDR_W-1:0]rf_waddr_i,
  input              mem2rf_i,
  input  [DATA_W-1:0]mem_rdata_i,
  input  [DATA_W-1:0]alu_result_i,
// to DE
  output logic             rf_we_o,
  output logic [ADDR_W-1:0]rf_waddr_o,
  output logic [DATA_W-1:0]alu_result_o
);

  always_comb begin
    rf_we_o = rf_we_i;
    rf_waddr_o = rf_waddr_i;
    alu_result_o = mem2rf_i ? mem_rdata_i : alu_result_i;
  end

endmodule
