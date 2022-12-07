module control_unit(
  input      [6:0]opcode,
  input      [2:0]funct3,
  input      [6:0]funct7,

  output reg      has_imm,

  output reg [2:0]alu_op,
  output reg      alu_alt,

  output reg      rf_we,

  output reg      mem_we,
  output reg      mem2rf,

  output reg      branch,
  output reg      check_eq
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
