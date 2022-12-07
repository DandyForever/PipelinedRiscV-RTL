`default_nettype wire

module fetch_stage #(
  parameter PC_W    = 32,
  parameter INSTR_W = 32
)(
  input clk,
  input reset,

// from ME
  input               pc_src_i,
  input     [PC_W-1:0]pc_branch_i,

// to DE
  output [INSTR_W-1:0]instr_o,
  output    [PC_W-1:0]pc_plus1_o
);

  reg  [PC_W-1:0]pc       = {PC_W{1'b1}};
  wire [PC_W-1:0]pc_plus1 = pc + 1;
  wire [PC_W-1:0]pc_next  = pc_src_i ? pc_branch_i : pc_plus1;

  wire [INSTR_W-1:0]instr;

  always @(posedge clk) begin
    pc <= pc_next;
    $strobe("F[%h]: %h", pc, instr);
  end

  localparam ADDR_W = 5;

  wire [ADDR_W-1:0]addr = pc[ADDR_W-1:0];

  rom #(
    .ADDR_W (ADDR_W ),
    .INSTR_W(INSTR_W)
  ) instr_memory(
    .clk (clk  ),
    .addr(addr ),
    .q   (instr)
  );

  latch #(.DATA_W(INSTR_W)) instr_l (.clk(clk), .reset(reset), .data_i(instr), .data_o(instr_o   ));
  latch #(.DATA_W(INSTR_W)) pc_l    (.clk(clk), .reset(reset), .data_i(pc   ), .data_o(pc_plus1_o));

endmodule

`default_nettype wire
