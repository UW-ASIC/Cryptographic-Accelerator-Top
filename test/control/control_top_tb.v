`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("control_top.vcd");
    $dumpvars(0, tb);
    #1;
  end


  wire clk;
  wire rst_n;
  wire spi_clk;
  wire cs_n;
  wire mosi, miso;
  wire [2:0] ack_in;

  wire bus_ready;
  wire [7:0] data_bus_out;
  wire data_bus_valid;

  localparam ADDRW = 24;
  localparam OPCODEW = 2;
  localparam REQ_QDEPTH = 4;
  localparam COMP_QDEPTH = 4;

  control_top #(.ADDRW(ADDRW), .OPCODEW(OPCODEW), .REQ_QDEPTH(REQ_QDEPTH), .COMP_QDEPTH(COMP_QDEPTH)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .cs_n(cs_n),
    .spi_clk(spi_clk),
    .miso(miso),
    .mosi(mosi),
    .ack_in(ack_in),
    .bus_ready(bus_ready),
    .data_bus_out(data_bus_out),
    .data_bus_valid(data_bus_valid));

  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock
  end

endmodule
