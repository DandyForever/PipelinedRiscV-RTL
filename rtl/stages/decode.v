module decode_stage(
  input        clk,

  input  [31:0]instr_i,    // From FE
  input  [31:0]pc_plus1_i, // From FE
  input  [31:0]rf_waddr_i, // From WB
  input  [31:0]rf_wdata_i, // From WB
  input        rf_we_i,    // From WB

  output       has_imm_o,
  output  [2:0]alu_op_o,
  output       alu_alt_o,
  output       rf_we_o,
  output       mem_we_o,
  output       mem2rf_o,
  output       branch_o,
  output       check_eq_o,
  output [31:0]imm32_o,
  output [31:0]rf_data0_o,
  output [31:0]rf_data1_o,
  output [31:0]rf_waddr_o,
  output [31:0]pc_plus1_o,
);

wire  [6:0]opcode = instr_i[6:0];
wire  [2:0]funct3 = instr_i[14:12];
wire  [6:0]funct7 = instr_i[31:25];
wire  [4:0]r_src0 = instr_i[19:15];
wire  [4:0]r_src1 = instr_i[24:20];
wire [11:0]imm12  = mem_we_o
                    ? {instr_i[31:25], instr_i[11:7]}
                    : instr_i[31:20];

assign rf_waddr_o = instr_i[11:7];
assign pc_plus1_o = pc_plus1_i;

control_unit control_unit(
  .opcode  (opcode    ),
  .funct3  (funct3    ),
  .funct7  (funct7    ),
  .has_imm (has_imm_o ),
  .alu_op  (alu_op_o  ),
  .alu_alt (alu_alt_o ),
  .rf_we   (rf_we_o   ),
  .mem_we  (mem_we_o  ),
  .mem2rf  (mem2rf_o  ),
  .branch  (branch_o  ),
  .check_eq(check_eq_o)
);

reg_file register_file(
  .clk   (clk       ),
  .raddr0(r_src0    ),
  .raddr1(r_src1    ),
  .waddr (rf_waddr_i),
  .wdata (rf_wdata_i),
  .we    (rf_we_i   ),
  .rdata0(rf_data0_o),
  .rdata1(rf_data1_o)
);

sign_ext sign_ext(
  .imm12(imm12  ),
  .imm32(imm32_o)
);

endmodule

