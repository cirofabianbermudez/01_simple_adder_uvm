`ifndef TOP_ENV_SV
`define TOP_ENV_SV

class top_env extends uvm_env;

  `uvm_component_utils(top_env)

  adder_agent    adder_agt;
  adder_config   adder_agt_cfg;
  top_scoreboard scoreboard;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void build_adder_agent();

endclass : top_env


function top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void top_env::build_phase(uvm_phase phase);
  build_adder_agent();
endfunction : build_phase


function void top_env::connect_phase(uvm_phase phase);
  adder_agt.analysis_port.connect(scoreboard.analysis_export);
endfunction : connect_phase


function void top_env::build_adder_agent();

  adder_agt_cfg = adder_config::type_id::create("adder_agt_cfg", this);
  adder_agt_cfg.is_active = UVM_ACTIVE;
  adder_agt_cfg.coverage_enable = 1;

  uvm_config_db #(adder_config)::set(this, "adder_agt", "cfg", adder_agt_cfg);

  adder_agt = adder_agent::type_id::create("adder_agt", this);
  `uvm_info(get_type_name(), "agt created", UVM_MEDIUM)


  scoreboard = top_scoreboard::type_id::create("scoreboard", this);
  `uvm_info(get_type_name(), "scoreboard created", UVM_MEDIUM)

endfunction : build_adder_agent

`endif // TOP_ENV_SV

