module de_latch(
  input        clk,

  input        has_imm_i,
  input   [2:0]alu_op_i,
  input        alu_alt_i,
  input        rf_we_i,
  input        mem_we_i,
  input        mem2rf_i,
  input  [31:0]imm32_i,
  input  [31:0]rf_data0_i,
  input  [31:0]rf_data1_i,
  input  [31:0]rf_waddr_i,

  output       has_imm_o,
  output  [2:0]alu_op_o,
  output       alu_alt_o,
  output       rf_we_o,
  output       mem_we_o,
  output       mem2rf_o,
  output [31:0]imm32_o,
  output [31:0]rf_data0_o,
  output [31:0]rf_data1_o,
  output [31:0]rf_waddr_o 
);

reg       has_imm;
reg  [2:0]alu_op;
reg       alu_alt;
reg       rf_we;
reg       mem_we;
reg       mem2rf;
reg [31:0]imm32;
reg [31:0]rf_data0;
reg [31:0]rf_data1;
reg [31:0]rf_waddr;

assign has_imm_o  = has_imm;
assign alu_op_o   = alu_op;
assign alu_alt_o  = alu_alt;
assign rf_we_o    = rf_we;
assign mem_we_o   = mem_we;
assign mem2rf_o   = mem2rf;
assign imm32_o    = imm32;
assign rf_data0_o = rf_data0;
assign rf_data1_o = rf_data1;
assign rf_waddr_o = rf_waddr;

always_ff @(posedge clk) begin
  has_imm  <= has_imm_i;
  alu_op   <= alu_op_i;
  alu_alt  <= alu_alt_i;
  rf_we    <= rf_we_i;
  mem_we   <= mem_we_i;
  mem2rf   <= mem2rf_i;
  imm32    <= imm32_i;
  rf_data0 <= rf_data0_i;
  rf_data1 <= rf_data1_i;
  rf_waddr <= rf_waddr_i;
end

endmodule

