`ifndef ADDER_PKG_SV
`define ADDER_PKG_SV

package adder_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "adder_sequence_item.sv"
  `include "adder_config.sv"
  `include "adder_sequencer.sv"
  `include "adder_sequence_base.sv"
  `include "adder_driver.sv"
  `include "adder_monitor.sv"
  `include "adder_agent.sv"

endpackage : adder_pkg

`endif // ADDER_PKG_SV
