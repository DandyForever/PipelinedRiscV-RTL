`timescale 1 ns / 100 ps

module testbench;

reg clk   = 1'b0;
reg reset = 1'b0;

always begin
  #1 clk = ~clk;
end

cpu cpu(
  .clk  (clk  ),
  .reset(reset)
);

initial begin
  #0.2; reset = 1'b1; #0.2; reset = 1'b0;
  $dumpvars;
  #500; $finish;
end

endmodule
