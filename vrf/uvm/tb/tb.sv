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
  
  adder_if vif(clk, rst);

  adder dut (
    .clk(vif.clk),
    .rst(vif.rst),
    .A(vif.A),
    .B(vif.B),
    .C(vif.C)
  );
  
  initial begin
    $timeformat(-9, 0, "ns", 10);
    $fsdbDumpvars;
    uvm_config_db #(virtual adder_if)::set(null, "uvm_test_top.env.adder_agt", "vif", vif);
    run_test();
  end

endmodule : tb
