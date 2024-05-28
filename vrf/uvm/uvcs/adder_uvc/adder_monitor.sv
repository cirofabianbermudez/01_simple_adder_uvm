`ifndef ADDER_MONITOR_SV
`define ADDER_MONITOR_SV

class adder_monitor extends uvm_monitor;

  `uvm_component_utils(adder_monitor)

  virtual adder_if vif;
  uvm_analysis_port #(adder_sequence_item) analysis_port;
  adder_sequence_item trans;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task do_mon();

endclass : adder_monitor

function adder_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void adder_monitor::build_phase(uvm_phase phase);
  if ( !uvm_config_db #(virtual adder_if)::get(get_parent(), "", "vif", vif) ) begin
		  `uvm_fatal(get_name(), "Could not retrieve adder_if from config db")
	end

  analysis_port = new("analysis_port", this);

endfunction : build_phase


task adder_monitor::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "run_phase", UVM_MEDIUM)
  trans = adder_sequence_item::type_id::create("trans");
  do_mon();
endtask : run_phase


task adder_monitor::do_mon();
  forever @(vif.C) begin
    trans.A = vif.A;
    trans.B = vif.B;
    trans.C = vif.C;
    analysis_port.write(trans);
    `uvm_info(get_type_name(), $sformatf("A = %4d, B = %4d, C = A + B =  %4d", vif.A, vif.B, vif.C), UVM_MEDIUM)
  end
endtask : do_mon

`endif // ADDER_MONITOR_SV
