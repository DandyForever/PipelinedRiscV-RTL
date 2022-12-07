`default_nettype wire

module control_unit #(
  parameter OP_W     = 7,
  parameter F3_W     = 3,
  parameter F7_W     = 7,
  parameter ALU_OP_W = 3
)(
  input      [OP_W-1:0]opcode,
  input      [F3_W-1:0]funct3,
  input      [F7_W-1:0]funct7,

  output logic               has_imm,

  output logic [ALU_OP_W-1:0]alu_op,
  output logic               alu_alt,

  output logic               rf_we,

  output logic               mem_we,
  output logic               mem2rf,

  output logic               branch,
  output logic               check_eq
);

  always_comb begin
    has_imm  = 1'b0;
    alu_op   = 3'b000;
    alu_alt  = 1'b0;
    rf_we    = 1'b0;
    mem_we   = 1'b0;
    mem2rf   = 1'b0;
    branch   = 1'b0;
    check_eq = 1'b0;

    casez (opcode)
      7'b0010011: begin /* I-type */
        rf_we   = 1'b1;
        alu_op  = funct3;
        has_imm = 1'b1;
        alu_alt = (funct3 == 3'b101) && funct7[5];
      end
      7'b0110011: begin /* R-type */
        rf_we   = 1'b1;
        alu_op  = funct3;
        alu_alt = funct7[5];
      end
      7'b0100011: begin /* SW */
        has_imm = 1'b1;
        mem_we  = (funct3 == 3'b010);
      end
      7'b0000011: begin /* LW */
        has_imm = 1'b1;
        rf_we   = 1'b1;
        mem2rf  = 1'b1;
      end
      7'b1100011: begin /* B-type */
        alu_alt  = ~funct3[2];
        alu_op   = {1'b0, funct3[2:1]};
        branch   = 1'b1;
        check_eq = funct3[0] ^ ~funct3[2];
      end
      default: ;
    endcase
  end

endmodule

`default_nettype wire
