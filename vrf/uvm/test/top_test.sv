`ifndef TOP_TEST_SV
`define TOP_TEST_SV

class top_test extends uvm_test;

  `uvm_component_utils(top_test)

  top_env env;
  //adder_sequence_base seq;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass : top_test


function top_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void top_test::build_phase(uvm_phase phase);
  // Override example but it is better to extend the test and make build_phase virtual can call the super.build_phase
  //set_type_override_by_type( adder_sequence_base::get_type(), adder_sequence_directed::get_type() );
  env = top_env::type_id::create("env", this);
  `uvm_info(get_type_name(), "env created", UVM_MEDIUM)
endfunction : build_phase


function void top_test::end_of_elaboration_phase(uvm_phase phase);
  uvm_root::get().print_topology();
  uvm_factory::get().print();
endfunction : end_of_elaboration_phase


task top_test::run_phase(uvm_phase phase);
  //`uvm_info(get_type_name(), "start run_phase raise objection", UVM_MEDIUM)

  adder_sequence_base seq;
  seq = adder_sequence_base::type_id::create("seq");

  phase.raise_objection(this);
  //begin
    seq.start(env.adder_agt.sqr);

  //end
  phase.drop_objection(this);

  `uvm_info(get_type_name(), "end run_phase drop objection", UVM_MEDIUM)
endtask : run_phase

`endif // TOP_TEST_SV
