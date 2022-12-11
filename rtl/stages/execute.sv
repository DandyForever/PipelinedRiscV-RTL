`default_nettype wire

module execute_stage #(
  parameter ALU_OP_W      = 3,
  parameter IMM_W         = 32,
  parameter DATA_W        = 32,
  parameter ADDR_W        = 5,
  parameter PC_W          = 32,
  parameter ALU_SRC_SEL_W = 2
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
// from DE to support bypass
  input     [ADDR_W-1:0]rf_src0_i,
  input     [ADDR_W-1:0]rf_src1_i,
// from ME to support bypass data
  input     [DATA_W-1:0]rf_data_m_i,
// from WB to support bypass data
  input     [DATA_W-1:0]rf_data_w_i,
// from HU to support bypass control
  input [ALU_SRC_SEL_W-1:0]alu_src0_sel_i,
  input [ALU_SRC_SEL_W-1:0]alu_src1_sel_i,
// latch config
  input latch_en,
  input latch_clear,
// to ME
  output             rf_we_o,
  output             mem_we_o,
  output             mem2rf_o,
  output             branch_o,
  output             check_eq_o,
  output [DATA_W-1:0]mem_wdata_o,
  output [ADDR_W-1:0]rf_waddr_o,
  output [DATA_W-1:0]alu_result_o,
  output   [PC_W-1:0]pc_branch_o,
// to HU to support bypass
  output [ADDR_W-1:0]rf_src0_o,
  output [ADDR_W-1:0]rf_src1_o,
// to HU to support stall
  output [ADDR_W-1:0]rf_dst_o,
  output             mem2rf_hu_o
);

  logic [DATA_W-1:0]alu_src0_rf;
  logic [DATA_W-1:0]alu_src1_rf;

  always_comb begin
    casez(alu_src0_sel_i)
      2'b00:   alu_src0_rf = rf_data0_i;
      2'b01:   alu_src0_rf = rf_data_w_i;
      2'b10:   alu_src0_rf = rf_data_m_i;
      default: alu_src0_rf = 0;
    endcase
  end

  always_comb begin
    casez(alu_src1_sel_i)
      2'b00:   alu_src1_rf = rf_data1_i;
      2'b01:   alu_src1_rf = rf_data_w_i;
      2'b10:   alu_src1_rf = rf_data_m_i;
      default: alu_src1_rf = 0;
    endcase
  end

  wire [PC_W-1:0]pc_branch = pc_plus1_i + imm32_i;

  wire [DATA_W-1:0]alu_src0 = alu_src0_rf;
  wire [DATA_W-1:0]alu_src1 = has_imm_i ? imm32_i : alu_src1_rf;

  wire [DATA_W-1:0]alu_result;

  alu #(
    .DATA_W  (DATA_W  ),
    .ALU_OP_W(ALU_OP_W)
  ) alu (
    .src_a(alu_src0  ),
    .src_b(alu_src1  ),
    .op   (alu_op_i  ),
    .alt  (alu_alt_i ),
    .res  (alu_result)
  );

  latch rf_we_l   (.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(rf_we_i   ), .data_o(rf_we_o   ));
  latch mem_we_l  (.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(mem_we_i  ), .data_o(mem_we_o  ));
  latch mem2rf_l  (.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(mem2rf_i  ), .data_o(mem2rf_o  ));
  latch branch_l  (.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(branch_i  ), .data_o(branch_o  ));
  latch check_eq_l(.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(check_eq_i), .data_o(check_eq_o));
  latch #(.DATA_W(DATA_W)) mem_wdata_l (.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(alu_src1_rf), .data_o(mem_wdata_o ));
  latch #(.DATA_W(ADDR_W)) rf_waddr_l  (.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(rf_waddr_i), .data_o(rf_waddr_o  ));
  latch #(.DATA_W(DATA_W)) alu_result_l(.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(alu_result), .data_o(alu_result_o));
  latch #(.DATA_W(PC_W))   pc_branch_l (.clk(clk), .reset(reset), .en(latch_en), .clear(latch_clear), .data_i(pc_branch), .data_o(pc_branch_o  ));

  assign rf_src0_o = rf_src0_i;
  assign rf_src1_o = rf_src1_i;

  assign rf_dst_o    = rf_waddr_i;
  assign mem2rf_hu_o = mem2rf_i;

endmodule

`default_nettype wire
