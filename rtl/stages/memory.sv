module memory_stage #(
  parameter DATA_W = 32,
  parameter ADDR_W = 32,
  parameter PC_W   = 32
)(
  input clk,
  input reset,

// from ME
  input              rf_we_i,
  input              mem_we_i,
  input              mem2rf_i,
  input              branch_i,
  input              check_eq_i,
  input  [DATA_W-1:0]mem_wdata_i,
  input  [ADDR_W-1:0]rf_waddr_i,
  input  [DATA_W-1:0]alu_result_i,
  input    [PC_W-1:0]pc_branch_i,
// to WB
  output             rf_we_o,
  output [ADDR_W-1:0]rf_waddr_o,
  output             mem2rf_o,
  output [DATA_W-1:0]mem_rdata_o,
  output [DATA_W-1:0]alu_result_o,
// to FE
  output             pc_src_o,
  output   [PC_W-1:0]pc_branch_o
);

  assign pc_src_o    = branch_i ? (check_eq_i ^ |alu_result_i) : 1'b0;
  assign pc_branch_o = pc_branch_i;

  wire [DATA_W-1:0]mem_rdata;

  ram ram(
    .clk   (clk         ),
    .r_addr(alu_result_i),
    .w_addr(alu_result_i),
    .w_data(mem_wdata_i ),
    .we    (mem_we_i    ),
    .r_data(mem_rdata   )
  );

  latch                    rf_we_l     (.clk(clk), .reset(reset), .data_i(rf_we_i      ), .data_o(rf_we_o     ));
  latch #(.DATA_W(ADDR_W)) rf_waddr_l  (.clk(clk), .reset(reset), .data_i(rf_waddr_i   ), .data_o(rf_waddr_o  ));
  latch                    mem2rf_l    (.clk(clk), .reset(reset), .data_i(mem2rf_i     ), .data_o(mem2rf_o    ));
  // latch                    pc_src_l    (.clk(clk), .reset(reset), .data_i(pc_src       ), .data_o(pc_src_o    ));
  latch #(.DATA_W(DATA_W)) mem_rdata_l (.clk(clk), .reset(reset), .data_i(mem_rdata    ), .data_o(mem_rdata_o ));
  latch #(.DATA_W(DATA_W)) alu_result_l(.clk(clk), .reset(reset), .data_i(alu_result_i ), .data_o(alu_result_o));
  // latch #(.DATA_W(PC_W))   pc_branch_l (.clk(clk), .reset(reset), .data_i(pc_branch_i  ), .data_o(pc_branch_o ));

endmodule
