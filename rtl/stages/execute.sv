module execute_stage #(
  parameter ALU_OP_W = 3,
  parameter IMM_W    = 32,
  parameter DATA_W   = 32,
  parameter ADDR_W   = 32,
  parameter PC_W     = 32
)(
  input clk,
  input reset,

//from DE
  input                 has_imm_i,
  input   [ALU_OP_W-1:0]alu_op_i,
  input                 alu_alt_i,
  input                 rf_we_i,
  input                 mem_we_i,
  input                 mem2rf_i,
  input                 branch_i,
  input                 check_eq_i,
  input      [IMM_W-1:0]imm32_i,
  input     [DATA_W-1:0]rf_data0_i,
  input     [DATA_W-1:0]rf_data1_i,
  input     [ADDR_W-1:0]rf_waddr_i,
  input       [PC_W-1:0]pc_plus1_i,
// to ME
  output             rf_we_o,
  output             mem_we_o,
  output             mem2rf_o,
  output             branch_o,
  output             check_eq_o,
  output [DATA_W-1:0]mem_wdata_o,
  output [ADDR_W-1:0]rf_waddr_o,
  output [DATA_W-1:0]alu_result_o,
  output   [PC_W-1:0]pc_branch_o
);

  wire [PC_W-1:0]pc_branch = pc_plus1_i + imm32_i;

  wire [DATA_W-1:0]alu_src0 = rf_data0_i;
  wire [DATA_W-1:0]alu_src1 = has_imm_i ? imm32_i : rf_data1_i;

  wire [DATA_W-1:0]alu_result;

  alu alu(
    .src_a(alu_src0  ),
    .src_b(alu_src1  ),
    .op   (alu_op_i  ),
    .alt  (alu_alt_i ),
    .res  (alu_result)
  );

  latch rf_we_l   (.clk(clk), .reset(reset), .data_i(rf_we_i   ), .data_o(rf_we_o   ));
  latch mem_we_l  (.clk(clk), .reset(reset), .data_i(mem_we_i  ), .data_o(mem_we_o  ));
  latch mem2rf_l  (.clk(clk), .reset(reset), .data_i(mem2rf_i  ), .data_o(mem2rf_o  ));
  latch branch_l  (.clk(clk), .reset(reset), .data_i(branch_i  ), .data_o(branch_o  ));
  latch check_eq_l(.clk(clk), .reset(reset), .data_i(check_eq_i), .data_o(check_eq_o));
  latch #(.DATA_W(DATA_W)) mem_wdata_l (.clk(clk), .reset(reset), .data_i(rf_data1_i), .data_o(mem_wdata_o ));
  latch #(.DATA_W(ADDR_W)) rf_waddr_l  (.clk(clk), .reset(reset), .data_i(rf_waddr_i), .data_o(rf_waddr_o  ));
  latch #(.DATA_W(DATA_W)) alu_result_l(.clk(clk), .reset(reset), .data_i(alu_result), .data_o(alu_result_o));
  latch #(.DATA_W(PC_W))   pc_branch_l (.clk(clk), .reset(reset), .data_i(pc_branch), .data_o(pc_branch_o  ));

endmodule

