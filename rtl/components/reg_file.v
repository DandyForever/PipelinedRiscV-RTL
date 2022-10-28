module reg_file(
    input        clk,
    input   [4:0]raddr0,
    input   [4:0]raddr1,
    input   [4:0]waddr,
    input  [31:0]wdata,
    input        we,

    output [31:0]rdata0,
    output [31:0]rdata1
);

reg [31:0]x[31:0];

genvar i;
generate
for (i = 0; i < 32; i = i + 1) begin : reg_init
  initial x[i] = 32'b0;
end
endgenerate

assign rdata0 = (raddr0 == 0) ? 0 : x[raddr0];
assign rdata1 = (raddr1 == 0) ? 0 : x[raddr1];

always @(posedge clk) begin
  if (we) begin
    x[waddr] <= wdata;
  end
  $strobe("\
  \CPUv1: x0: %h x8 : %h x16: %h x24: %h\n\
  \CPUv1: x1: %h x9 : %h x17: %h x25: %h\n\
  \CPUv1: x2: %h x10: %h x18: %h x26: %h\n\
  \CPUv1: x3: %h x11: %h x19: %h x27: %h\n\
  \CPUv1: x4: %h x12: %h x20: %h x28: %h\n\
  \CPUv1: x5: %h x13: %h x21: %h x29: %h\n\
  \CPUv1: x6: %h x14: %h x22: %h x30: %h\n\
  \CPUv1: x7: %h x15: %h x23: %h x31: %h\n",
  32'b0, x[8], x[16], x[24],
  x[1],  x[9], x[17], x[25],
  x[2], x[10], x[18], x[26],
  x[3], x[11], x[19], x[27],
  x[4], x[12], x[20], x[28],
  x[5], x[13], x[21], x[29],
  x[6], x[14], x[22], x[30],
  x[7], x[15], x[23], x[31]
  );
end

endmodule

