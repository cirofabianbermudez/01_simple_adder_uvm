`ifndef ADDER_DRIVER_SV
`define ADDER_DRIVER_SV

class adder_driver extends uvm_driver #(adder_sequence_item);

  `uvm_component_utils(adder_driver)

  virtual adder_if vif;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task do_drive();

endclass : adder_driver

function adder_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void adder_driver::build_phase(uvm_phase phase);
  if ( !uvm_config_db #(virtual adder_if)::get(get_parent(), "", "vif", vif) ) begin
		  `uvm_fatal(get_name(), "Could not retrieve adder_if from config db")
	end
endfunction : build_phase


task adder_driver::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "start run_phase", UVM_MEDIUM)
  forever begin
    seq_item_port.get_next_item(req);
    `uvm_info(get_type_name(), $sformatf("A = %4d, B = %4d", req.A, req.B), UVM_MEDIUM)
    do_drive();
    seq_item_port.item_done();
    #10;
  end
  `uvm_info(get_type_name(), "end run_phase", UVM_MEDIUM)
endtask : run_phase

task adder_driver::do_drive();
  vif.A <= req.A;
  vif.B <= req.B;
  #10;
endtask : do_drive

`endif // ADDER_DRIVER_SV
