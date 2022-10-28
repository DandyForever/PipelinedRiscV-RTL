module em_latch(
  input        clk,

  input        rf_we_i,
  input        mem_we_i,
  input        mem2rf_i,
  input  [31:0]mem_wdata_i,
  input  [31:0]rf_waddr_i,
  input  [31:0]alu_result_i,

  output       rf_we_o,
  output       mem_we_o,
  output       mem2rf_o,
  output [31:0]mem_wdata_o,
  output [31:0]rf_waddr_o,
  output [31:0]alu_result_o
);

reg       rf_we;
reg       mem_we;
reg       mem2rf;
reg [31:0]mem_wdata;
reg [31:0]rf_waddr;
reg [31:0]alu_result;

assign rf_we_o      = rf_we;
assign mem_we_o     = mem_we;
assign mem2rf_o     = mem2rf;
assign mem_wdata_o  = mem_wdata;
assign rf_waddr_o   = rf_waddr;
assign alu_result_o = alu_result;

always_ff @(posedge clk) begin
  rf_we      <= rf_we_i;
  mem_we     <= mem_we_i;
  mem2rf     <= mem2rf_i;
  mem_wdata  <= mem_wdata_i;
  rf_waddr   <= rf_waddr_i;
  alu_result <= alu_result_i;
end

endmodule

