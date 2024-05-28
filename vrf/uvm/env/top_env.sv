`ifndef TOP_ENV_SV
`define TOP_ENV_SV

class top_env extends uvm_env;

  `uvm_component_utils(top_env)

  adder_agent agt;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);

endclass : top_env


function top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void top_env::build_phase(uvm_phase phase);
  agt = adder_agent::type_id::create("agt", this);
  `uvm_info(get_type_name(), "agt created", UVM_MEDIUM)
endfunction

`endif // TOP_ENV_SV

