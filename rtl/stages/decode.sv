`default_nettype wire

module decode_stage #(
  parameter PC_W       = 32,
  parameter INSTR_W    = 32,
  parameter ADDR_W     = 5,
  parameter DATA_W     = 32,
  parameter ALU_OP_W   = 3,
  parameter IMM_W      = 32
)(
  input clk,
  input reset,

// from FE
  input   [INSTR_W-1:0]instr_i,
  input      [PC_W-1:0]pc_plus1_i,
// from WB
  input    [ADDR_W-1:0]rf_waddr_i,
  input    [DATA_W-1:0]rf_wdata_i,
  input                rf_we_i,
// from HU to support stall
  input                latch_en_i,
  input                latch_clear_i,
// to EXE
  output               has_imm_o,
  output [ALU_OP_W-1:0]alu_op_o,
  output               alu_alt_o,
  output               rf_we_o,
  output               mem_we_o,
  output               mem2rf_o,
  output               branch_o,
  output               check_eq_o,
  output               jump_o,
  output    [IMM_W-1:0]imm32_o,
  output   [DATA_W-1:0]rf_data0_o,
  output   [DATA_W-1:0]rf_data1_o,
  output   [ADDR_W-1:0]rf_waddr_o,
  output     [PC_W-1:0]pc_plus1_o,
// to EXE to support bypass
  output   [ADDR_W-1:0]rf_src0_o,
  output   [ADDR_W-1:0]rf_src1_o,
// to HU to support stall
  output   [ADDR_W-1:0]rf_src0_hu_o,
  output   [ADDR_W-1:0]rf_src1_hu_o,
  output               has_imm_hu_o
);

  // localparam REG_ADDR_W = 5;
  localparam IMM12_W    = 12;
  localparam IMM20_W    = 20;
  localparam F3_W       = 3;
  localparam F7_W       = 7;
  localparam OP_W       = 7;

  wire   [OP_W-1:0]opcode = instr_i[6:0];
  wire   [F3_W-1:0]funct3 = instr_i[14:12];
  wire   [F7_W-1:0]funct7 = instr_i[31:25];
  wire [ADDR_W-1:0]r_src0 = instr_i[19:15];
  wire [ADDR_W-1:0]r_src1 = instr_i[24:20];

  logic [IMM12_W-1:0]imm12_sw;
  logic [IMM12_W-1:0]imm12_branch;
  logic [IMM12_W-1:0]imm12_default;
  logic [IMM12_W-1:0]imm12;
  logic [IMM20_W-1:0]imm20;

  wire [ADDR_W-1:0]rf_waddr = instr_i[11:7];

  wire               has_imm;
  wire [ALU_OP_W-1:0]alu_op;
  wire               alu_alt;
  wire               rf_we;
  wire               mem_we;
  wire               mem2rf;
  wire               branch;
  wire               check_eq;
  wire               jump;
  wire               is_imm20;

  always_comb begin
    imm12_sw      = {instr_i[31:25], instr_i[11:7]};
    imm12_branch  = {instr_i[31], instr_i[31], instr_i[7],
                     instr_i[30:25], instr_i[11:9]};
    imm12_default = instr_i[31:20];
    imm12 = mem_we ? imm12_sw : branch ? imm12_branch : imm12_default;
    imm20 = {instr_i[31], instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:22]};
  end

  control_unit #(
    .OP_W    (OP_W    ),
    .F3_W    (F3_W    ),
    .F7_W    (F7_W    ),
    .ALU_OP_W(ALU_OP_W)
  ) control_unit(
    .opcode  (opcode  ),
    .funct3  (funct3  ),
    .funct7  (funct7  ),
    .has_imm (has_imm ),
    .alu_op  (alu_op  ),
    .alu_alt (alu_alt ),
    .rf_we   (rf_we   ),
    .mem_we  (mem_we  ),
    .mem2rf  (mem2rf  ),
    .branch  (branch  ),
    .check_eq(check_eq),
    .jump    (jump    ),
    .is_imm20(is_imm20)
  );

  wire [DATA_W-1:0]rf_data0;
  wire [DATA_W-1:0]rf_data1;

  reg_file #(
    .ADDR_W(ADDR_W),
    .DATA_W(DATA_W)
  ) register_file(
    .clk   (clk       ),
    .raddr0(r_src0    ),
    .raddr1(r_src1    ),
    .waddr (rf_waddr_i),
    .wdata (rf_wdata_i),
    .we    (rf_we_i   ),
    .rdata0(rf_data0  ),
    .rdata1(rf_data1  )
  );

  wire [IMM_W-1:0]imm32;
  wire [IMM_W-1:0]imm32_12;
  wire [IMM_W-1:0]imm32_20;

  sign_ext #(.BASE_W(IMM12_W), .RES_W(IMM_W)) imm12_sext(.base_i(imm12), .result_o(imm32_12));
  sign_ext #(.BASE_W(IMM20_W), .RES_W(IMM_W)) imm20_sext(.base_i(imm20), .result_o(imm32_20));
  assign imm32 = is_imm20 ? imm32_20 : imm32_12;

  latch                      has_imm_l (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(has_imm   ), .data_o(has_imm_o ));
  latch #(.DATA_W(ALU_OP_W)) alu_op_l  (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(alu_op    ), .data_o(alu_op_o  ));
  latch                      alu_alt_l (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(alu_alt   ), .data_o(alu_alt_o ));
  latch                      rf_we_l   (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(rf_we     ), .data_o(rf_we_o   ));
  latch                      mem_we_l  (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(mem_we    ), .data_o(mem_we_o  ));
  latch                      mem2rf_l  (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(mem2rf    ), .data_o(mem2rf_o  ));
  latch                      branch_l  (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(branch    ), .data_o(branch_o  ));
  latch                      check_eq_l(.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(check_eq  ), .data_o(check_eq_o));
  latch                      jump_l    (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(jump      ), .data_o(jump_o    ));
  latch #(.DATA_W(IMM_W))    imm32_l   (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(imm32     ), .data_o(imm32_o   ));
  latch #(.DATA_W(DATA_W))   rf_data0_l(.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(rf_data0  ), .data_o(rf_data0_o));
  latch #(.DATA_W(DATA_W))   rf_data1_l(.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(rf_data1  ), .data_o(rf_data1_o));
  latch #(.DATA_W(ADDR_W))   rf_waddr_l(.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(rf_waddr  ), .data_o(rf_waddr_o));
  latch #(.DATA_W(PC_W))     pc_plus1_l(.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(pc_plus1_i), .data_o(pc_plus1_o));
  latch #(.DATA_W(ADDR_W))   rf_src0_l (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(r_src0    ), .data_o(rf_src0_o ));
  latch #(.DATA_W(ADDR_W))   rf_src1_l (.clk(clk), .reset(reset), .en(latch_en_i), .clear(latch_clear_i), .data_i(r_src1    ), .data_o(rf_src1_o ));

  assign rf_src0_hu_o = r_src0;
  assign rf_src1_hu_o = r_src1;
  assign has_imm_hu_o = has_imm;

endmodule

`default_nettype wire
