module execute_stage(
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
  
  output       rf_we_o,
  output       mem_we_o,
  output       mem2rf_o,
  output [31:0]mem_wdata_o,
  output [31:0]rf_waddr_o,
  output [31:0]alu_result_o
);

assign rf_waddr_o  = rf_waddr_i;
assign rf_we_o     = rf_we_i;
assign mem_we_o    = mem_we_i;
assign mem2rf_o    = mem2rf_i;
assign mem_wdata_o = rf_data1_i;

wire [31:0]alu_src0 = rf_data0_i;
wire [31:0]alu_src1 = has_imm_i
                      ? imm32_i
                      : rf_data1_i;

alu alu(
  .src_a(alu_src0    ),
  .src_b(alu_src1    ),
  .op   (alu_op_i    ),
  .alt  (alu_alt_i   ),
  .res  (alu_result_o)
);

endmodule

