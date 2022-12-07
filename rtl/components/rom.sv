`default_nettype wire

module rom #(
  parameter ADDR_W  = 5,
  parameter INSTR_W = 32
)(
  input clk,

  input   [ADDR_W - 1:0]addr,
  output [INSTR_W - 1:0]q
);

  reg [INSTR_W - 1:0]mem[2**ADDR_W - 1:0];

  initial begin
    $readmemh("../../samples/test.txt", mem);
  end

  assign q = mem[addr];

  always @(q)
    if (q === {INSTR_W{1'bx}}) begin
      #20; $finish;
    end

endmodule

`default_nettype wire
