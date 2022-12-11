`default_nettype wire

module hazard_unit #(
  parameter ADDR_W        = 5,
  parameter ALU_SRC_SEL_W = 2
)(
// from EXE to support bypass
  input [ADDR_W-1:0]rf_src0_i,
  input [ADDR_W-1:0]rf_src1_i,
// from ME to support bypass
  input [ADDR_W-1:0]rf_dst_m_i,
  input             rf_we_m_i,
// from WB to support bypass
  input [ADDR_W-1:0]rf_dst_w_i,
  input             rf_we_w_i,
// to EXE to support bypass
  output [ALU_SRC_SEL_W-1:0]alu_src0_sel_o,
  output [ALU_SRC_SEL_W-1:0]alu_src1_sel_o,

// from DE to support stall
  input [ADDR_W-1:0]rf_src0_d_i,
  input [ADDR_W-1:0]rf_src1_d_i,
  input             has_imm_d_i,
// from EXE to support stall
  input [ADDR_W-1:0]rf_dst_e_i,
  input             mem2rf_e_i,
// to FE to support stall
  output latch_en_f_o,
// to DE to support stall
  output latch_clear_d_o
);

  wire src0_bypass_m = rf_src0_i && (rf_src0_i == rf_dst_m_i) && rf_we_m_i;
  wire src0_bypass_w = rf_src0_i && (rf_src0_i == rf_dst_w_i) && rf_we_w_i;

  assign alu_src0_sel_o = src0_bypass_m ? 2'b10 : src0_bypass_w ? 2'b01 : 2'b00;

  wire src1_bypass_m = rf_src1_i && (rf_src1_i == rf_dst_m_i) && rf_we_m_i;
  wire src1_bypass_w = rf_src1_i && (rf_src1_i == rf_dst_w_i) && rf_we_w_i;

  assign alu_src1_sel_o = src1_bypass_m ? 2'b10 : src1_bypass_w ? 2'b01 : 2'b00;

  wire src0_stall_e = rf_src0_d_i && (rf_src0_d_i == rf_dst_e_i);
  wire src1_stall_e = ~has_imm_d_i && rf_src1_d_i && (rf_src1_d_i == rf_dst_e_i);
  wire is_stall     = (src0_stall_e || src1_stall_e) && mem2rf_e_i;

  assign latch_en_f_o    = ~is_stall;
  assign latch_clear_d_o =  is_stall;

endmodule

`default_nettype wire
