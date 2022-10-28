`default_nettype none

module cpu(
  input clk
);

wire [31:0]instr_f_o;

fetch_stage fetch(
  .clk    (clk      ),
  .instr_o(instr_f_o)
);

wire [31:0]instr_d_i;

fd_latch fd_latch(
  .clk    (clk      ),
  .instr_i(instr_f_o),
  .instr_o(instr_d_i)
);

wire [31:0]rf_waddr_w_o;
wire [31:0]rf_wdata_w_o;
wire       rf_we_w_o;

wire       has_imm_d_o;
wire  [2:0]alu_op_d_o;
wire       alu_alt_d_o;
wire       rf_we_d_o;
wire       mem_we_d_o;
wire       mem2rf_d_o;
wire [31:0]imm32_d_o;
wire [31:0]rf_data0_d_o;
wire [31:0]rf_data1_d_o;
wire [31:0]rf_waddr_d_o;

decode_stage decode(
  .clk       (clk         ),
  .instr_i   (instr_d_i   ),
  .rf_waddr_i(rf_waddr_w_o),
  .rf_wdata_i(rf_wdata_w_o),
  .rf_we_i   (rf_we_w_o   ),
  .has_imm_o (has_imm_d_o ),
  .alu_op_o  (alu_op_d_o  ),
  .alu_alt_o (alu_alt_d_o ),
  .rf_we_o   (rf_we_d_o   ),
  .mem_we_o  (mem_we_d_o  ),
  .mem2rf_o  (mem2rf_d_o  ),
  .imm32_o   (imm32_d_o   ),
  .rf_data0_o(rf_data0_d_o),
  .rf_data1_o(rf_data1_d_o),
  .rf_waddr_o(rf_waddr_d_o)
);

wire       has_imm_e_i;
wire  [2:0]alu_op_e_i;
wire       alu_alt_e_i;
wire       rf_we_e_i;
wire       mem_we_e_i;
wire       mem2rf_e_i;
wire [31:0]imm32_e_i;
wire [31:0]rf_data0_e_i;
wire [31:0]rf_data1_e_i;
wire [31:0]rf_waddr_e_i;

de_latch de_latch(
  .clk       (clk         ),
  .has_imm_i (has_imm_d_o ),
  .alu_op_i  (alu_op_d_o  ),
  .alu_alt_i (alu_alt_d_o ),
  .rf_we_i   (rf_we_d_o   ),
  .mem_we_i  (mem_we_d_o  ),
  .mem2rf_i  (mem2rf_d_o  ),
  .imm32_i   (imm32_d_o   ),
  .rf_data0_i(rf_data0_d_o),
  .rf_data1_i(rf_data1_d_o),
  .rf_waddr_i(rf_waddr_d_o),
  .has_imm_o (has_imm_e_i ),
  .alu_op_o  (alu_op_e_i  ),
  .alu_alt_o (alu_alt_e_i ),
  .rf_we_o   (rf_we_e_i   ),
  .mem_we_o  (mem_we_e_i  ),
  .mem2rf_o  (mem2rf_e_i  ),
  .imm32_o   (imm32_e_i   ),
  .rf_data0_o(rf_data0_e_i),
  .rf_data1_o(rf_data1_e_i),
  .rf_waddr_o(rf_waddr_e_i)
);

wire       rf_we_e_o;
wire       mem_we_e_o;
wire       mem2rf_e_o;
wire [31:0]mem_wdata_e_o;
wire [31:0]rf_waddr_e_o;
wire [31:0]alu_result_e_o;

execute_stage execute(
  .clk         (clk           ),
  .has_imm_i   (has_imm_e_i   ),
  .alu_op_i    (alu_op_e_i    ),
  .alu_alt_i   (alu_alt_e_i   ),
  .rf_we_i     (rf_we_e_i     ),
  .mem_we_i    (mem_we_e_i    ),
  .mem2rf_i    (mem2rf_e_i    ),
  .imm32_i     (imm32_e_i     ),
  .rf_data0_i  (rf_data0_e_i  ),
  .rf_data1_i  (rf_data1_e_i  ),
  .rf_waddr_i  (rf_waddr_e_i  ),
  .rf_we_o     (rf_we_e_o     ),
  .mem_we_o    (mem_we_e_o    ),
  .mem2rf_o    (mem2rf_e_o    ),
  .mem_wdata_o (mem_wdata_e_o ),
  .rf_waddr_o  (rf_waddr_e_o  ),
  .alu_result_o(alu_result_e_o)
);

wire       rf_we_m_i;
wire       mem_we_m_i;
wire       mem2rf_m_i;
wire [31:0]mem_wdata_m_i;
wire [31:0]rf_waddr_m_i;
wire [31:0]alu_result_m_i;

em_latch em_latch(
  .clk         (clk           ),
  .rf_we_i     (rf_we_e_o     ),
  .mem_we_i    (mem_we_e_o    ),
  .mem2rf_i    (mem2rf_e_o    ),
  .mem_wdata_i (mem_wdata_e_o ),
  .rf_waddr_i  (rf_waddr_e_o  ),
  .alu_result_i(alu_result_e_o),
  .rf_we_o     (rf_we_m_i     ),
  .mem_we_o    (mem_we_m_i    ),
  .mem2rf_o    (mem2rf_m_i    ),
  .mem_wdata_o (mem_wdata_m_i ),
  .rf_waddr_o  (rf_waddr_m_i  ),
  .alu_result_o(alu_result_m_i)
);

wire       rf_we_m_o;
wire [31:0]rf_waddr_m_o;
wire       mem2rf_m_o;
wire [31:0]mem_rdata_m_o;
wire [31:0]alu_result_m_o;

memory_stage memory(
  .clk         (clk           ),
  .rf_we_i     (rf_we_m_i     ),
  .mem_we_i    (mem_we_m_i    ),
  .mem2rf_i    (mem2rf_m_i    ),
  .mem_wdata_i (mem_wdata_m_i ),
  .rf_waddr_i  (rf_waddr_m_i  ),
  .alu_result_i(alu_result_m_i),
  .rf_we_o     (rf_we_m_o     ),
  .rf_waddr_o  (rf_waddr_m_o  ),
  .mem2rf_o    (mem2rf_m_o    ),
  .mem_rdata_o (mem_rdata_m_o ),
  .alu_result_o(alu_result_m_o)
);

wire       rf_we_w_i;
wire [31:0]rf_waddr_w_i;
wire       mem2rf_w_i;
wire [31:0]mem_rdata_w_i;
wire [31:0]alu_result_w_i;

mw_latch mw_latch(
  .clk         (clk           ),
  .rf_we_i     (rf_we_m_o     ),
  .rf_waddr_i  (rf_waddr_m_o  ),
  .mem2rf_i    (mem2rf_m_o    ),
  .mem_rdata_i (mem_rdata_m_o ),
  .alu_result_i(alu_result_m_o),
  .rf_we_o     (rf_we_w_i     ),
  .rf_waddr_o  (rf_waddr_w_i  ),
  .mem2rf_o    (mem2rf_w_i    ),
  .mem_rdata_o (mem_rdata_w_i ),
  .alu_result_o(alu_result_w_i)
);

writeback_stage writeback(
  .clk         (clk           ),
  .rf_we_i     (rf_we_w_i     ),
  .rf_waddr_i  (rf_waddr_w_i  ),
  .mem2rf_i    (mem2rf_w_i    ),
  .mem_rdata_i (mem_rdata_w_i ),
  .alu_result_i(alu_result_w_i),
  .rf_we_o     (rf_we_w_o     ),
  .rf_waddr_o  (rf_waddr_w_o  ),
  .alu_result_o(rf_wdata_w_o  )
);

endmodule

`default_nettype wire

