module tb;
  import uvm_pkg::*;
  import top_test_pkg::*;

  // Clock generator
  logic clk;
  always #5 clk = ~clk;

  // Reset sequence
  logic rst;
  initial begin
    clk = 0; rst = 1; #10;
             rst = 0;
  end
  
  adder_if adder_if_0();

  adder dut (
    .A(adder_if_0.A),
    .B(adder_if_0.B),
    .C(adder_if_0.C)
  );

  initial begin
    run_test();
  end

endmodule : tb
