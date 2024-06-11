`ifndef ADDER_IF_SV
`define ADDER_IF_SV

interface adder_if #(
  parameter Width = 8
)(
  input logic clk,
  input logic rst
);

  logic [Width-1:0] A;
  logic [Width-1:0] B;
  logic [Width-1:0] C;

  clocking cb @(posedge clk);
    default input #1ns output #1ns;
    output A;
    output B;
    input  C;
    input  rst;
  endclocking : cb

endinterface : adder_if

`endif // ADDER_IF_SV
