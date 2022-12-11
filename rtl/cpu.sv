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

wire [ADDR_W-1:0]hu_rf_src0_i;
wire [ADDR_W-1:0]hu_rf_src1_i;
wire [ADDR_W-1:0]hu_rf_dst_m_i;
wire [ADDR_W-1:0]hu_rf_dst_w_i;
wire             hu_rf_we_m_i;
wire             hu_rf_we_w_i;
wire [ALU_SRC_SEL_W-1:0]hu_alu_src0_sel_o;
wire [ALU_SRC_SEL_W-1:0]hu_alu_src1_sel_o;

wire [ADDR_W-1:0]hu_rf_src0_d_i;
wire [ADDR_W-1:0]hu_rf_src1_d_i;
wire             hu_has_imm_d_i;
wire [ADDR_W-1:0]hu_rf_dst_e_i;
wire             hu_mem2rf_e_i;
wire             hu_latch_en_f_o;
wire             hu_latch_clear_d_o;

hazard_unit hu(
  .rf_src0_i      (hu_rf_src0_i      ),
  .rf_src1_i      (hu_rf_src1_i      ),
  .rf_dst_m_i     (hu_rf_dst_m_i     ),
  .rf_dst_w_i     (hu_rf_dst_w_i     ),
  .rf_we_m_i      (hu_rf_we_m_i      ),
  .rf_we_w_i      (hu_rf_we_w_i      ),
  .alu_src0_sel_o (hu_alu_src0_sel_o ),
  .alu_src1_sel_o (hu_alu_src1_sel_o ),
  .rf_src0_d_i    (hu_rf_src0_d_i    ),
  .rf_src1_d_i    (hu_rf_src1_d_i    ),
  .has_imm_d_i    (hu_has_imm_d_i    ),
  .rf_dst_e_i     (hu_rf_dst_e_i     ),
  .mem2rf_e_i     (hu_mem2rf_e_i     ),
  .latch_en_f_o   (hu_latch_en_f_o   ),
  .latch_clear_d_o(hu_latch_clear_d_o)
);

wire              pc_src_f_i;
wire    [PC_W-1:0]pc_branch_f_i;
wire              latch_en_f_i;
wire              latch_clear_f_i;
wire [INSTR_W-1:0]instr_f_o;
wire    [PC_W-1:0]pc_plus1_f_o;

assign latch_en_f_i    = hu_latch_en_f_o;
assign latch_clear_f_i = 1'b0;

fetch_stage fetch(
  .clk          (clk            ),
  .reset        (reset          ),
  .pc_src_i     (pc_src_f_i     ),
  .pc_branch_i  (pc_branch_f_i  ),
  .latch_en_i   (latch_en_f_i   ),
  .latch_clear_i(latch_clear_f_i),
  .instr_o      (instr_f_o      ),
  .pc_plus1_o   (pc_plus1_f_o   )
);

wire [INSTR_W-1:0]instr_d_i    = instr_f_o;
wire    [PC_W-1:0]pc_plus1_d_i = pc_plus1_f_o;

logic [ADDR_W-1:0]rf_waddr_d_i;
logic [DATA_W-1:0]rf_wdata_d_i;
logic             rf_we_d_i;

wire                has_imm_d_o;
wire  [ALU_OP_W-1:0]alu_op_d_o;
wire                alu_alt_d_o;
wire                rf_we_d_o;
wire                mem_we_d_o;
wire                mem2rf_d_o;
wire                branch_d_o;
wire                check_eq_d_o;
wire     [IMM_W-1:0]imm32_d_o;
wire    [DATA_W-1:0]rf_data0_d_o;
wire    [DATA_W-1:0]rf_data1_d_o;
wire    [ADDR_W-1:0]rf_waddr_d_o;
wire      [PC_W-1:0]pc_plus1_d_o;
wire    [ADDR_W-1:0]rf_src0_d_o;
wire    [ADDR_W-1:0]rf_src1_d_o;
wire latch_en_d_i    = 1'b1;
wire latch_clear_d_i = hu_latch_clear_d_o;
wire [ADDR_W-1:0]rf_src0_hu_d_o;
wire [ADDR_W-1:0]rf_src1_hu_d_o;
wire             has_imm_hu_d_o;

assign hu_rf_src0_d_i = rf_src0_hu_d_o;
assign hu_rf_src1_d_i = rf_src1_hu_d_o;
assign hu_has_imm_d_i = has_imm_hu_d_o;

decode_stage decode(
  .clk          (clk            ),
  .reset        (reset          ),
  .instr_i      (instr_d_i      ),
  .pc_plus1_i   (pc_plus1_d_i   ),
  .rf_waddr_i   (rf_waddr_d_i   ),
  .rf_wdata_i   (rf_wdata_d_i   ),
  .rf_we_i      (rf_we_d_i      ),
  .latch_en_i   (latch_en_d_i   ),
  .latch_clear_i(latch_clear_d_i),
  .has_imm_o    (has_imm_d_o    ),
  .alu_op_o     (alu_op_d_o     ),
  .alu_alt_o    (alu_alt_d_o    ),
  .rf_we_o      (rf_we_d_o      ),
  .mem_we_o     (mem_we_d_o     ),
  .mem2rf_o     (mem2rf_d_o     ),
  .branch_o     (branch_d_o     ),
  .check_eq_o   (check_eq_d_o   ),
  .imm32_o      (imm32_d_o      ),
  .rf_data0_o   (rf_data0_d_o   ),
  .rf_data1_o   (rf_data1_d_o   ),
  .rf_waddr_o   (rf_waddr_d_o   ),
  .pc_plus1_o   (pc_plus1_d_o   ),
  .rf_src0_o    (rf_src0_d_o    ),
  .rf_src1_o    (rf_src1_d_o    ),
  .rf_src0_hu_o (rf_src0_hu_d_o ),
  .rf_src1_hu_o (rf_src1_hu_d_o ),
  .has_imm_hu_o (has_imm_hu_d_o )
);

wire                has_imm_e_i  = has_imm_d_o;
wire  [ALU_OP_W-1:0]alu_op_e_i   = alu_op_d_o;
wire                alu_alt_e_i  = alu_alt_d_o;
wire                rf_we_e_i    = rf_we_d_o;
wire                mem_we_e_i   = mem_we_d_o;
wire                mem2rf_e_i   = mem2rf_d_o;
wire                branch_e_i   = branch_d_o;
wire                check_eq_e_i = check_eq_d_o;
wire     [IMM_W-1:0]imm32_e_i    = imm32_d_o;
wire    [DATA_W-1:0]rf_data0_e_i = rf_data0_d_o;
wire    [DATA_W-1:0]rf_data1_e_i = rf_data1_d_o;
wire    [ADDR_W-1:0]rf_waddr_e_i = rf_waddr_d_o;
wire      [PC_W-1:0]pc_plus1_e_i = pc_plus1_d_o;
wire    [ADDR_W-1:0]rf_src0_e_i  = rf_src0_d_o;
wire    [ADDR_W-1:0]rf_src1_e_i  = rf_src1_d_o;

wire [DATA_W-1:0]rf_data_m_fw_e_i;
wire [DATA_W-1:0]rf_data_w_fw_e_i;
wire [ALU_SRC_SEL_W-1:0]alu_src0_sel_e_i = hu_alu_src0_sel_o;
wire [ALU_SRC_SEL_W-1:0]alu_src1_sel_e_i = hu_alu_src1_sel_o;
wire latch_en_e_i    = 1'b1;
wire latch_clear_e_i = 1'b0;

wire             rf_we_e_o;
wire             mem_we_e_o;
wire             mem2rf_e_o;
wire             branch_e_o;
wire             check_eq_e_o;
wire [DATA_W-1:0]mem_wdata_e_o;
wire [ADDR_W-1:0]rf_waddr_e_o;
wire [DATA_W-1:0]alu_result_e_o;
wire   [PC_W-1:0]pc_branch_e_o;

wire [ADDR_W-1:0]rf_src0_e_o;
wire [ADDR_W-1:0]rf_src1_e_o;

assign hu_rf_src0_i = rf_src0_e_o;
assign hu_rf_src1_i = rf_src1_e_o;

wire [ADDR_W-1:0]rf_dst_e_o;
wire             mem2rf_hu_e_o;

assign hu_rf_dst_e_i = rf_dst_e_o;
assign hu_mem2rf_e_i = mem2rf_hu_e_o;

execute_stage execute(
  .clk           (clk             ),
  .reset         (reset           ),
  .has_imm_i     (has_imm_e_i     ),
  .alu_op_i      (alu_op_e_i      ),
  .alu_alt_i     (alu_alt_e_i     ),
  .rf_we_i       (rf_we_e_i       ),
  .mem_we_i      (mem_we_e_i      ),
  .mem2rf_i      (mem2rf_e_i      ),
  .branch_i      (branch_e_i      ),
  .check_eq_i    (check_eq_e_i    ),
  .imm32_i       (imm32_e_i       ),
  .rf_data0_i    (rf_data0_e_i    ),
  .rf_data1_i    (rf_data1_e_i    ),
  .rf_waddr_i    (rf_waddr_e_i    ),
  .pc_plus1_i    (pc_plus1_e_i    ),
  .rf_src0_i     (rf_src0_e_i     ),
  .rf_src1_i     (rf_src1_e_i     ),
  .rf_data_m_i   (rf_data_m_fw_e_i),
  .rf_data_w_i   (rf_data_w_fw_e_i),
  .alu_src0_sel_i(alu_src0_sel_e_i),
  .alu_src1_sel_i(alu_src1_sel_e_i),
  .latch_en      (latch_en_e_i    ),
  .latch_clear   (latch_clear_e_i ),
  .rf_we_o       (rf_we_e_o       ),
  .mem_we_o      (mem_we_e_o      ),
  .mem2rf_o      (mem2rf_e_o      ),
  .branch_o      (branch_e_o      ),
  .check_eq_o    (check_eq_e_o    ),
  .mem_wdata_o   (mem_wdata_e_o   ),
  .rf_waddr_o    (rf_waddr_e_o    ),
  .alu_result_o  (alu_result_e_o  ),
  .pc_branch_o   (pc_branch_e_o   ),
  .rf_src0_o     (rf_src0_e_o     ),
  .rf_src1_o     (rf_src1_e_o     ),
  .rf_dst_o      (rf_dst_e_o      ),
  .mem2rf_hu_o   (mem2rf_hu_e_o   )
);

  wire             rf_we_m_i      = rf_we_e_o;
  wire             mem_we_m_i     = mem_we_e_o;
  wire             mem2rf_m_i     = mem2rf_e_o;
  wire             branch_m_i     = branch_e_o;
  wire             check_eq_m_i   = check_eq_e_o;
  wire [DATA_W-1:0]mem_wdata_m_i  = mem_wdata_e_o;
  wire [ADDR_W-1:0]rf_waddr_m_i   = rf_waddr_e_o;
  wire [DATA_W-1:0]alu_result_m_i = alu_result_e_o;
  wire   [PC_W-1:0]pc_branch_m_i  = pc_branch_e_o;

  wire latch_en_m_i    = 1'b1;
  wire latch_clear_m_i = 1'b0;

  wire             pc_src_m_o;
  wire             rf_we_m_o;
  wire [ADDR_W-1:0]rf_waddr_m_o;
  wire             mem2rf_m_o;
  wire [DATA_W-1:0]mem_rdata_m_o;
  wire [DATA_W-1:0]alu_result_m_o;
  wire   [PC_W-1:0]pc_branch_m_o;

  wire [DATA_W-1:0]rf_data_m_o;
  wire [ADDR_W-1:0]rf_dst_m_o;
  wire             rf_we_hu_m_o;

  assign rf_data_m_fw_e_i = rf_data_m_o;
  assign hu_rf_dst_m_i    = rf_dst_m_o;
  assign hu_rf_we_m_i     = rf_we_hu_m_o;

  memory_stage memory(
    .clk         (clk            ),
    .reset       (reset          ),
    .rf_we_i     (rf_we_m_i      ),
    .mem_we_i    (mem_we_m_i     ),
    .mem2rf_i    (mem2rf_m_i     ),
    .branch_i    (branch_m_i     ),
    .check_eq_i  (check_eq_m_i   ),
    .mem_wdata_i (mem_wdata_m_i  ),
    .rf_waddr_i  (rf_waddr_m_i   ),
    .alu_result_i(alu_result_m_i ),
    .pc_branch_i (pc_branch_m_i  ),
    .latch_en    (latch_en_m_i   ),
    .latch_clear (latch_clear_m_i),
    .rf_we_o     (rf_we_m_o      ),
    .rf_waddr_o  (rf_waddr_m_o   ),
    .mem2rf_o    (mem2rf_m_o     ),
    .pc_src_o    (pc_src_m_o     ),
    .mem_rdata_o (mem_rdata_m_o  ),
    .alu_result_o(alu_result_m_o ),
    .pc_branch_o (pc_branch_m_o  ),
    .rf_data_o   (rf_data_m_o    ),
    .rf_dst_o    (rf_dst_m_o     ),
    .rf_we_hu_o  (rf_we_hu_m_o   )
  );

  assign pc_src_f_i    = pc_src_m_o;
  assign pc_branch_f_i = pc_branch_m_o;

  wire             rf_we_w_i      = rf_we_m_o;
  wire [ADDR_W-1:0]rf_waddr_w_i   = rf_waddr_m_o;
  wire             mem2rf_w_i     = mem2rf_m_o;
  wire [DATA_W-1:0]mem_rdata_w_i  = mem_rdata_m_o;
  wire [DATA_W-1:0]alu_result_w_i = alu_result_m_o;


  wire [ADDR_W-1:0]rf_waddr_w_o;
  wire [DATA_W-1:0]rf_wdata_w_o;
  wire             rf_we_w_o;

  wire [DATA_W-1:0]rf_data_w_o;
  wire [ADDR_W-1:0]rf_dst_w_o;
  wire             rf_we_hu_w_o;

  assign rf_data_w_fw_e_i = rf_data_w_o;
  assign hu_rf_dst_w_i    = rf_dst_w_o;
  assign hu_rf_we_w_i     = rf_we_hu_w_o;

  writeback_stage writeback(
    .clk         (clk           ),
    .rf_we_i     (rf_we_w_i     ),
    .rf_waddr_i  (rf_waddr_w_i  ),
    .mem2rf_i    (mem2rf_w_i    ),
    .mem_rdata_i (mem_rdata_w_i ),
    .alu_result_i(alu_result_w_i),
    .rf_we_o     (rf_we_w_o     ),
    .rf_waddr_o  (rf_waddr_w_o  ),
    .alu_result_o(rf_wdata_w_o  ),
    .rf_data_o   (rf_data_w_o   ),
    .rf_dst_o    (rf_dst_w_o    ),
    .rf_we_hu_o  (rf_we_hu_w_o  )
  );

  always_comb begin
    rf_waddr_d_i = rf_waddr_w_o;
    rf_wdata_d_i = rf_wdata_w_o;
    rf_we_d_i    = rf_we_w_o;
  end

endmodule

`default_nettype wire
