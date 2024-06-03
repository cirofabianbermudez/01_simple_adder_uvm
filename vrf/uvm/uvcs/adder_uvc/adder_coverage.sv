`ifndef ADDER_COVERAGE_SV
`define ADDER_COVERAGE_SV

class adder_coverage extends uvm_subscriber #(adder_sequence_item);

  `uvm_component_utils(adder_coverage)

  adder_config         cfg;    
  adder_sequence_item  trans;
  bit                  is_covered;
     
  covergroup adder_cov;
    //option.per_instance = 1;
    cp_A: coverpoint trans.A {
      bins a_bins[] = { [0:255] };
      //option.auto_bin_max = 256;
    }
    cp_B: coverpoint trans.B {
      bins b_bins[] = { [0:255] };
      //option.auto_bin_max = 256;
    }
    cp_cross: cross cp_A, cp_B;
    //cp_C: coverpoint trans.C {option.auto_bin_max = 256;}
  endgroup

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void write(adder_sequence_item t);
  extern function void report_phase(uvm_phase phase);

endclass : adder_coverage


function adder_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  is_covered = 0;
  adder_cov = new();
endfunction : new


function void adder_coverage::build_phase(uvm_phase phase);
  if ( !uvm_config_db #(adder_config)::get(get_parent(), "", "cfg", cfg) ) begin
    `uvm_fatal(get_name(), "Could not retrieve adder_config from config db")
  end
endfunction : build_phase


function void adder_coverage::write(adder_sequence_item t);
  if (cfg.coverage_enable) begin
    trans = t;
    adder_cov.sample();
    if (adder_cov.get_inst_coverage() >= 80) begin
      is_covered = 1;
		  //`uvm_info(get_type_name(), "80% Coverage reached", UVM_MEDIUM)
    end
  end
endfunction : write

function void adder_coverage::report_phase(uvm_phase phase);
  if (cfg.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", adder_cov.get_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase

`endif // ADDER_COVERAGE_SV
