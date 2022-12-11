`default_nettype wire

module latch #(
  parameter DATA_W = 1
)(
  input clk,
  input reset,

  input en,
  input clear,

  input  [DATA_W-1:0]data_i,
  output [DATA_W-1:0]data_o
);

  reg [DATA_W-1:0]data_ff;

  assign data_o = data_ff;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      data_ff <= 0;
    end else begin
      data_ff <= clear ? 0 : en ? data_i : data_ff;
    end
  end

endmodule

`default_nettype wire
