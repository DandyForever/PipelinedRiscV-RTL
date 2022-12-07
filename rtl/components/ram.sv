`default_nettype wire

module ram #(
  parameter ADDR_W = 32,
  parameter ELEM_W = 8,
  parameter DATA_W = 32
)(
  input clk,

  input [ADDR_W-1:0]r_addr,
  input [ADDR_W-1:0]w_addr,
  input [DATA_W-1:0]w_data,
  input             we,

  output logic [DATA_W-1:0]r_data
);

  localparam ELEM_NUM = 4096;

  reg [ELEM_W-1:0]mem[ELEM_NUM-1:0];

  genvar i;
  generate
    for (i = 0; i < ELEM_NUM; i++) begin : ram_init
      initial mem[i] = 0;
    end
  endgenerate

  assign r_data = {mem[r_addr],   mem[r_addr+1],
                   mem[r_addr+2], mem[r_addr+3]};

  always_ff @(posedge clk) begin
    if (we) begin
      {mem[w_addr],   mem[w_addr+1],
       mem[w_addr+2], mem[w_addr+3]} <= w_data;
      $display("RAM write: [%h] <- %h", w_addr, w_data);
    end
  end

endmodule

`default_nettype wire
