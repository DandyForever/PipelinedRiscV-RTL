module decode_stage #(
  parameter PC_W       = 32,
  parameter INSTR_W    = 32,
  parameter ADDR_W     = 32,
  parameter DATA_W     = 32,
  parameter ALU_OP_W   = 3,
  parameter IMM_W      = 32
)(
  input clk,
  input reset,

// from FE
  input  [INSTR_W-1:0]instr_i,
  input     [PC_W-1:0]pc_plus1_i,
// from WB
  input   [ADDR_W-1:0]rf_waddr_i,
  input     [DATA_W:0]rf_wdata_i,
  input               rf_we_i,
// to EXE
  output                has_imm_o,
  output  [ALU_OP_W-1:0]alu_op_o,
  output                alu_alt_o,
  output                rf_we_o,
  output                mem_we_o,
  output                mem2rf_o,
  output                branch_o,
  output                check_eq_o,
  output     [IMM_W-1:0]imm32_o,
  output    [DATA_W-1:0]rf_data0_o,
  output    [DATA_W-1:0]rf_data1_o,
  output    [ADDR_W-1:0]rf_waddr_o,
  output      [PC_W-1:0]pc_plus1_o
);

  localparam REG_ADDR_W = 5;
  localparam IMM12_W    = 12;
  localparam F3_W       = 3;
  localparam F7_W       = 7;
  localparam OP_W       = 7;

  wire       [OP_W-1:0]opcode = instr_i[6:0];
  wire       [F3_W-1:0]funct3 = instr_i[14:12];
  wire       [F7_W-1:0]funct7 = instr_i[31:25];
  wire [REG_ADDR_W-1:0]r_src0 = instr_i[19:15];
  wire [REG_ADDR_W-1:0]r_src1 = instr_i[24:20];

  logic [IMM12_W-1:0]imm12_sw;
  logic [IMM12_W-1:0]imm12_branch;
  logic [IMM12_W-1:0]imm12_default;
  logic [IMM12_W-1:0]imm12;

  wire [ADDR_W-1:0]rf_waddr = instr_i[11:7];

  wire               has_imm;
  wire [ALU_OP_W-1:0]alu_op;
  wire               alu_alt;
  wire               rf_we;
  wire               mem_we;
  wire               mem2rf;
  wire               branch;
  wire               check_eq;

  always_comb begin
    imm12_sw      = {instr_i[31:25], instr_i[11:7]};
    imm12_branch  = {instr_i[31], instr_i[31], instr_i[7],
                     instr_i[30:25], instr_i[11:9]};
    imm12_default = instr_i[31:20];
    imm12 = mem_we ? imm12_sw : branch ? imm12_branch : imm12_default;
  end

  control_unit control_unit(
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
    .check_eq(check_eq)
  );

  wire [DATA_W-1:0]rf_data0;
  wire [DATA_W-1:0]rf_data1;

  reg_file register_file(
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

  sign_ext sign_ext(
    .imm12(imm12),
    .imm32(imm32)
  );

  latch                      has_imm_l (.clk(clk), .reset(reset), .data_i(has_imm   ), .data_o(has_imm_o ));
  latch #(.DATA_W(ALU_OP_W)) alu_op_l  (.clk(clk), .reset(reset), .data_i(alu_op    ), .data_o(alu_op_o  ));
  latch                      alu_alt_l (.clk(clk), .reset(reset), .data_i(alu_alt   ), .data_o(alu_alt_o ));
  latch                      rf_we_l   (.clk(clk), .reset(reset), .data_i(rf_we     ), .data_o(rf_we_o   ));
  latch                      mem_we_l  (.clk(clk), .reset(reset), .data_i(mem_we    ), .data_o(mem_we_o  ));
  latch                      mem2rf_l  (.clk(clk), .reset(reset), .data_i(mem2rf    ), .data_o(mem2rf_o  ));
  latch                      branch_l  (.clk(clk), .reset(reset), .data_i(branch    ), .data_o(branch_o  ));
  latch                      check_eq_l(.clk(clk), .reset(reset), .data_i(check_eq  ), .data_o(check_eq_o));
  latch #(.DATA_W(IMM_W))    imm32_l   (.clk(clk), .reset(reset), .data_i(imm32     ), .data_o(imm32_o   ));
  latch #(.DATA_W(DATA_W))   rf_data0_l(.clk(clk), .reset(reset), .data_i(rf_data0  ), .data_o(rf_data0_o));
  latch #(.DATA_W(DATA_W))   rf_data1_l(.clk(clk), .reset(reset), .data_i(rf_data1  ), .data_o(rf_data1_o));
  latch #(.DATA_W(ADDR_W))   rf_waddr_l(.clk(clk), .reset(reset), .data_i(rf_waddr  ), .data_o(rf_waddr_o));
  latch #(.DATA_W(PC_W))     pc_plus1_l(.clk(clk), .reset(reset), .data_i(pc_plus1_i), .data_o(pc_plus1_o));

endmodule

