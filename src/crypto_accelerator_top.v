/*
 * Copyright (c) 2025 UW ASIC
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_uwasic_crypto_accelerator_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  wire [1:0] read_ack_bus_id;
  wire read_ack_bus_valid;

  wire control_data_bus_ready; //control input wires

  wire control_data_bus_valid; //control output wires
  wire [7:0] control_data_bus_data;

  wire sclk = ui_in[0];
  wire n_cs = ui_in[1];
  wire mosi = ui_in[2];
  wire miso = uo_out[0];

  control_top#(
    .ADDRW(24),
    .OPCODEW(2),
    .REQ_QDEPTH(2),
    .COMP_QDEPTH(4)
  ) control_top_inst(
    .clk(clk),
    .rst_n(rst_n),
    .cs_n(n_cs),
    .spi_clk(sclk),
    .miso(miso),
    .mosi(mosi),
    .ack_in({read_ack_bus_valid, read_ack_bus_id}),
    .bus_ready(control_data_bus_ready),
    .data_bus_out(control_data_bus_data),
    .data_bus_valid(control_data_bus_valid)
  );

  wire [7:0] mem_data_in; //mem input wires
  wire mem_data_in_valid;
  wire mem_data_out_ready;
  wire mem_ack_ready;

  wire [7:0] mem_data_out; //mem output wires
  wire mem_data_out_valid;
  wire mem_data_in_ready;
  wire mem_ack_valid;
  wire mem_ack_id;

  wire sclk_mem = uo_out[1]; //qspi interface
  wire n_cs_mem = uo_out[2];
  wire [3:0] mem_qspi_out = uio_out[3:0];
  wire [3:0] mem_qspi_in  = uio_in[3:0];
  wire [3:0] mem_qspi_output_enable = uio_oe[3:0];

  //okay this top file in nonsensical I am ignoring it for now thx
  mem_toplevel mem_top_inst(
    .in_bus_ready(),
    .in_bus_valid(),
    .in_bus_data(),
    .out_bus_ready(),
    .out_bus_valid(),
    .out_bus_data(),
    .mem_qspi_output_enable(),
    .mem_qspi_out(),
    .sclk_mem(),
    .n_cs_mem(),
    .mem_qspi_in(),
    .clk(clk),
    .rst_n(rst_n),
    .ena(1'b1)
  );

  wire [7:0] aes_data_in; //aes input wires
  wire aes_data_in_valid;
  wire aes_data_out_ready;
  wire aes_ack_ready;

  wire [7:0] aes_data_out; //aes output wires
  wire aes_data_out_valid;
  wire aes_data_in_ready;
  wire aes_ack_valid;
  wire aes_ack_id;

  aes aes_inst(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(aes_data_in),
    .ready_in(aes_data_in_ready),
    .valid_in(aes_data_in_valid),
    .data_out(aes_data_out),
    .data_ready(aes_data_out_ready),
    .data_valid(aes_data_out_valid),
    .ack_ready(aes_ack_ready),
    .ack_valid(aes_ack_valid),
    .module_source_id(aes_ack_id)
  );

  ack_bus_top ack_bus_inst(
    .req_mem(),
    .req_sha(),
    .req_aes(aes_ack_valid),
    .req_ctrl(),//unused
    .ack_ready_to_mem(),
    .ack_ready_to_sha(),
    .ack_ready_to_aes(aes_ack_ready),
    .ack_ready_to_ctrl(),//unsused
    .winner_source_id(read_ack_bus_id),
    .ack_event(read_ack_bus_id)
  );

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
