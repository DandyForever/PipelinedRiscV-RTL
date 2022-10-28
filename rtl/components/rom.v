module rom #(
  parameter ADDR_WIDTH = 5,
  parameter WIDTH      = 32
)(
  input                   clk,
  input [ADDR_WIDTH - 1:0]addr,
  output reg [WIDTH - 1:0]q
);

reg [WIDTH - 1:0]mem[2**ADDR_WIDTH - 1:0];

initial begin
  $readmemh("../../samples/test.txt", mem);
end

always @(posedge clk) begin
  q <= mem[addr];
end

always @(q)
  if (q === 32'bx) begin
    #20; $finish;
  end

endmodule

