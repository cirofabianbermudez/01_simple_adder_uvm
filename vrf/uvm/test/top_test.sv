`ifndef TOP_TEST_SV
`define TOP_TEST_SV

class top_test extends uvm_test;

  `uvm_component_utils(top_test)

  //top_env m_env;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);

  extern task run_phase(uvm_phase phase);

endclass : top_test


function top_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

function void top_test::build_phase(uvm_phase phase);
  //m_env = top_env::type_id::create("m_env", this);
endfunction : build_phase

task top_test::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  `uvm_info("TEST", "Hello There", UVM_MEDIUM);
  phase.drop_objection(this);
endtask : run_phase

`endif // TOP_TEST_SV
