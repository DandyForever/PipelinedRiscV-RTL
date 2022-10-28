module mw_latch(
  input clk,

  input       rf_we_i,
  input [31:0]rf_waddr_i,
  input       mem2rf_i,
  input [31:0]mem_rdata_i,
  input [31:0]alu_result_i,

  output       rf_we_o,
  output [31:0]rf_waddr_o,
  output       mem2rf_o,
  output [31:0]mem_rdata_o,
  output [31:0]alu_result_o
);

reg       rf_we;
reg [31:0]rf_waddr;
reg       mem2rf;
reg [31:0]mem_rdata;
reg [31:0]alu_result;

assign rf_we_o      = rf_we;
assign rf_waddr_o   = rf_waddr;
assign mem2rf_o     = mem2rf;
assign mem_rdata_o  = mem_rdata;
assign alu_result_o = alu_result;

always_ff @(posedge clk) begin
  rf_we      <= rf_we_i;
  rf_waddr   <= rf_waddr_i;
  mem2rf     <= mem2rf_i;
  mem_rdata  <= mem_rdata_i;
  alu_result <= alu_result_i;
end

endmodule

