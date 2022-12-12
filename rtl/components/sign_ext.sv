module sign_ext #(
  parameter BASE_W = 12,
  parameter RES_W  = 32
)(
  input  [BASE_W-1:0]base_i,
  output  [RES_W-1:0]result_o
);

  localparam SIGN_W = RES_W - BASE_W;
  assign result_o = {{SIGN_W{base_i[BASE_W-1]}}, base_i};

endmodule
