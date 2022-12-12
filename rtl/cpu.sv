`default_nettype wire

module cpu #(
  parameter PC_W          = 32,
  parameter INSTR_W       = 32,
  parameter ADDR_W        = 5,
  parameter DATA_W        = 32,
  parameter ALU_OP_W      = 3,
  parameter IMM_W         = 32,
  parameter ALU_SRC_SEL_W = 2
)(
  input clk,
  input reset
);

  wire        [ADDR_W-1:0]e_rf_src0_hu;
  wire        [ADDR_W-1:0]e_rf_src1_hu;
  wire        [ADDR_W-1:0]m_rf_dst_hu;
  wire        [ADDR_W-1:0]w_rf_dst_hu;
  wire                    m_rf_we_hu;
  wire                    w_rf_we_hu;
  wire [ALU_SRC_SEL_W-1:0]hu_alu_src0_sel_e;
  wire [ALU_SRC_SEL_W-1:0]hu_alu_src1_sel_e;

  wire [ADDR_W-1:0]d_rf_src0_hu;
  wire [ADDR_W-1:0]d_rf_src1_hu;
  wire             d_has_imm_hu;
  wire [ADDR_W-1:0]e_rf_dst_hu;
  wire             e_mem2rf_hu;
  wire             hu_latch_en_f;
  wire             hu_latch_clear_d;

  wire m_pc_src_hu;
  wire hu_latch_clear_f;
  wire hu_latch_clear_e;

  hazard_unit hu(
    .rf_src0_i      (e_rf_src0_hu     ),
    .rf_src1_i      (e_rf_src1_hu     ),
    .rf_dst_m_i     (m_rf_dst_hu      ),
    .rf_dst_w_i     (w_rf_dst_hu      ),
    .rf_we_m_i      (m_rf_we_hu       ),
    .rf_we_w_i      (w_rf_we_hu       ),
    .alu_src0_sel_o (hu_alu_src0_sel_e),
    .alu_src1_sel_o (hu_alu_src1_sel_e),
    .rf_src0_d_i    (d_rf_src0_hu     ),
    .rf_src1_d_i    (d_rf_src1_hu     ),
    .has_imm_d_i    (d_has_imm_hu     ),
    .rf_dst_e_i     (e_rf_dst_hu      ),
    .mem2rf_e_i     (e_mem2rf_hu      ),
    .latch_en_f_o   (hu_latch_en_f    ),
    .latch_clear_d_o(hu_latch_clear_d ),
    .pc_src_i       (m_pc_src_hu      ),
    .latch_clear_f_o(hu_latch_clear_f ),
    .latch_clear_e_o(hu_latch_clear_e )
  );

  wire              m_pc_src_f;
  wire    [PC_W-1:0]m_pc_branch_f;
  wire [INSTR_W-1:0]f_instr_d;
  wire    [PC_W-1:0]f_pc_plus1_d;

  fetch_stage fetch(
    .clk          (clk             ),
    .reset        (reset           ),
    .pc_src_i     (m_pc_src_f      ),
    .pc_branch_i  (m_pc_branch_f   ),
    .latch_en_i   (hu_latch_en_f   ),
    .latch_clear_i(hu_latch_clear_f),
    .instr_o      (f_instr_d       ),
    .pc_plus1_o   (f_pc_plus1_d    )
  );

  wire [ADDR_W-1:0]w_rf_waddr_d;
  wire [DATA_W-1:0]w_rf_wdata_d;
  wire             w_rf_we_d;

  wire               d_has_imm_e;
  wire [ALU_OP_W-1:0]d_alu_op_e;
  wire               d_alu_alt_e;
  wire               d_rf_we_e;
  wire               d_mem_we_e;
  wire               d_mem2rf_e;
  wire               d_branch_e;
  wire               d_check_eq_e;
  wire               d_jump_e;
  wire    [IMM_W-1:0]d_imm32_e;
  wire   [DATA_W-1:0]d_rf_data0_e;
  wire   [DATA_W-1:0]d_rf_data1_e;
  wire   [ADDR_W-1:0]d_rf_waddr_e;
  wire     [PC_W-1:0]d_pc_plus1_e;
  wire   [ADDR_W-1:0]d_rf_src0_e;
  wire   [ADDR_W-1:0]d_rf_src1_e;

  wire latch_en_d    = 1'b1;

  decode_stage decode(
    .clk          (clk             ),
    .reset        (reset           ),
    .instr_i      (f_instr_d       ),
    .pc_plus1_i   (f_pc_plus1_d    ),
    .rf_waddr_i   (w_rf_waddr_d    ),
    .rf_wdata_i   (w_rf_wdata_d    ),
    .rf_we_i      (w_rf_we_d       ),
    .latch_en_i   (latch_en_d      ),
    .latch_clear_i(hu_latch_clear_d),
    .has_imm_o    (d_has_imm_e     ),
    .alu_op_o     (d_alu_op_e      ),
    .alu_alt_o    (d_alu_alt_e     ),
    .rf_we_o      (d_rf_we_e       ),
    .mem_we_o     (d_mem_we_e      ),
    .mem2rf_o     (d_mem2rf_e      ),
    .branch_o     (d_branch_e      ),
    .check_eq_o   (d_check_eq_e    ),
    .jump_o       (d_jump_e        ),
    .imm32_o      (d_imm32_e       ),
    .rf_data0_o   (d_rf_data0_e    ),
    .rf_data1_o   (d_rf_data1_e    ),
    .rf_waddr_o   (d_rf_waddr_e    ),
    .pc_plus1_o   (d_pc_plus1_e    ),
    .rf_src0_o    (d_rf_src0_e     ),
    .rf_src1_o    (d_rf_src1_e     ),
    .rf_src0_hu_o (d_rf_src0_hu    ),
    .rf_src1_hu_o (d_rf_src1_hu    ),
    .has_imm_hu_o (d_has_imm_hu    )
  );

  wire [DATA_W-1:0]m_rf_data_e;
  wire [DATA_W-1:0]w_rf_data_e;

  wire latch_en_e    = 1'b1;

  wire             e_rf_we_m;
  wire             e_mem_we_m;
  wire             e_mem2rf_m;
  wire             e_branch_m;
  wire             e_check_eq_m;
  wire             e_jump_m;
  wire [DATA_W-1:0]e_mem_wdata_m;
  wire [ADDR_W-1:0]e_rf_waddr_m;
  wire [DATA_W-1:0]e_alu_result_m;
  wire   [PC_W-1:0]e_pc_branch_m;

  execute_stage execute(
    .clk           (clk              ),
    .reset         (reset            ),
    .has_imm_i     (d_has_imm_e      ),
    .alu_op_i      (d_alu_op_e       ),
    .alu_alt_i     (d_alu_alt_e      ),
    .rf_we_i       (d_rf_we_e        ),
    .mem_we_i      (d_mem_we_e       ),
    .mem2rf_i      (d_mem2rf_e       ),
    .branch_i      (d_branch_e       ),
    .check_eq_i    (d_check_eq_e     ),
    .jump_i        (d_jump_e         ),
    .imm32_i       (d_imm32_e        ),
    .rf_data0_i    (d_rf_data0_e     ),
    .rf_data1_i    (d_rf_data1_e     ),
    .rf_waddr_i    (d_rf_waddr_e     ),
    .pc_plus1_i    (d_pc_plus1_e     ),
    .rf_src0_i     (d_rf_src0_e      ),
    .rf_src1_i     (d_rf_src1_e      ),
    .rf_data_m_i   (m_rf_data_e      ),
    .rf_data_w_i   (w_rf_data_e      ),
    .alu_src0_sel_i(hu_alu_src0_sel_e),
    .alu_src1_sel_i(hu_alu_src1_sel_e),
    .latch_en_i    (latch_en_e       ),
    .latch_clear_i (hu_latch_clear_e ),
    .rf_we_o       (e_rf_we_m        ),
    .mem_we_o      (e_mem_we_m       ),
    .mem2rf_o      (e_mem2rf_m       ),
    .branch_o      (e_branch_m       ),
    .check_eq_o    (e_check_eq_m     ),
    .jump_o        (e_jump_m         ),
    .mem_wdata_o   (e_mem_wdata_m    ),
    .rf_waddr_o    (e_rf_waddr_m     ),
    .alu_result_o  (e_alu_result_m   ),
    .pc_branch_o   (e_pc_branch_m    ),
    .rf_src0_o     (e_rf_src0_hu     ),
    .rf_src1_o     (e_rf_src1_hu     ),
    .rf_dst_o      (e_rf_dst_hu      ),
    .mem2rf_hu_o   (e_mem2rf_hu      )
  );

  wire latch_en_m    = 1'b1;
  wire latch_clear_m = 1'b0;

  wire             m_rf_we_w;
  wire [ADDR_W-1:0]m_rf_waddr_w;
  wire             m_mem2rf_w;
  wire [DATA_W-1:0]m_mem_rdata_w;
  wire [DATA_W-1:0]m_alu_result_w;

  memory_stage memory(
    .clk          (clk           ),
    .reset        (reset         ),
    .rf_we_i      (e_rf_we_m     ),
    .mem_we_i     (e_mem_we_m    ),
    .mem2rf_i     (e_mem2rf_m    ),
    .branch_i     (e_branch_m    ),
    .check_eq_i   (e_check_eq_m  ),
    .jump_i       (e_jump_m      ),
    .mem_wdata_i  (e_mem_wdata_m ),
    .rf_waddr_i   (e_rf_waddr_m  ),
    .alu_result_i (e_alu_result_m),
    .pc_branch_i  (e_pc_branch_m ),
    .latch_en_i   (latch_en_m    ),
    .latch_clear_i(latch_clear_m ),
    .rf_we_o      (m_rf_we_w     ),
    .rf_waddr_o   (m_rf_waddr_w  ),
    .mem2rf_o     (m_mem2rf_w    ),
    .pc_src_o     (m_pc_src_f    ),
    .mem_rdata_o  (m_mem_rdata_w ),
    .alu_result_o (m_alu_result_w),
    .pc_branch_o  (m_pc_branch_f ),
    .rf_data_o    (m_rf_data_e   ),
    .rf_dst_o     (m_rf_dst_hu   ),
    .rf_we_hu_o   (m_rf_we_hu    ),
    .pc_src_hu_o  (m_pc_src_hu   )
  );

  writeback_stage writeback(
    .clk         (clk           ),
    .rf_we_i     (m_rf_we_w     ),
    .rf_waddr_i  (m_rf_waddr_w  ),
    .mem2rf_i    (m_mem2rf_w    ),
    .mem_rdata_i (m_mem_rdata_w ),
    .alu_result_i(m_alu_result_w),
    .rf_we_o     (w_rf_we_d     ),
    .rf_waddr_o  (w_rf_waddr_d  ),
    .alu_result_o(w_rf_wdata_d  ),
    .rf_data_o   (w_rf_data_e   ),
    .rf_dst_o    (w_rf_dst_hu   ),
    .rf_we_hu_o  (w_rf_we_hu    )
  );

endmodule

`default_nettype wire
