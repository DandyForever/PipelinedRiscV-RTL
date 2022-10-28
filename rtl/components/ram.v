module ram #(
  parameter ADDR_WIDTH = 32,
  parameter WIDTH      = 8,
  parameter DATA_WIDTH = 32
)(
  input                        clk,
  input      [ADDR_WIDTH - 1:0]r_addr,
  input      [ADDR_WIDTH - 1:0]w_addr,
  input      [DATA_WIDTH - 1:0]w_data,
  input                        we,

  output reg [DATA_WIDTH - 1:0]r_data
);

reg [WIDTH - 1:0]mem[4096 - 1:0];

genvar i;
generate
  for (i = 0; i < 2**ADDR_WIDTH; i += 1) begin : ram_init
    initial mem[i] = 0;
  end
endgenerate

assign r_data = {mem[r_addr],     mem[r_addr + 1],
                 mem[r_addr + 2], mem[r_addr + 3]};

always_ff @(posedge clk) begin
  if (we) begin
    {mem[w_addr],     mem[w_addr + 1],
     mem[w_addr + 2], mem[w_addr + 3]} <= w_data;
    $display("RAM write: [%h] <- %h", w_addr, w_data);
  end
end

endmodule

