`ifndef ADDER_CONFIG_SV
`define ADDER_CONFIG_SV

class adder_config extends uvm_object;

  `uvm_object_utils(adder_config)

  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;    

  extern function new(string name = "");

endclass : adder_config

function adder_config::new(string name = "");
  super.new(name);
endfunction : new

`endif // ADDER_CONFIG_SV
