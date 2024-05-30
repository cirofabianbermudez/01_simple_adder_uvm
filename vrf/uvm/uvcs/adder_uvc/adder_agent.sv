`ifndef ADDER_AGENT_SV
`define ADDER_AGENT_SV

class adder_agent extends uvm_agent;

  `uvm_component_utils(adder_agent)

  adder_sequencer sqr;
  adder_driver    drv;
  adder_monitor   mon;
  adder_config    cfg;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : adder_agent


function  adder_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void adder_agent::build_phase(uvm_phase phase);

  if ( !uvm_config_db #(adder_config)::get(this, "", "cfg", cfg) ) begin
		  `uvm_fatal(get_name(), "Could not retrieve adder_config from config db")
	end

  if (cfg.is_active == UVM_ACTIVE) begin
    sqr = adder_sequencer::type_id::create("sqr", this);
    drv = adder_driver   ::type_id::create("drv", this);
    `uvm_info(get_type_name(), "sqr created", UVM_MEDIUM)
    `uvm_info(get_type_name(), "drv created", UVM_MEDIUM)
  end

  mon = adder_monitor::type_id::create("mon", this);
  `uvm_info(get_type_name(), "mon created", UVM_MEDIUM)

endfunction : build_phase


function void adder_agent::connect_phase(uvm_phase phase);

  if (cfg.is_active == UVM_ACTIVE) begin
    drv.seq_item_port.connect(sqr.seq_item_export);
    `uvm_info(get_type_name(), "drv and sqr connected", UVM_MEDIUM)
  end

endfunction : connect_phase

`endif // ADDER_AGENT_SV

