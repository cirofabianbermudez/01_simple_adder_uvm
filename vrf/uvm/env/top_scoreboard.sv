`ifndef TOP_SCOREBOARD_SV
`define TOP_SCOREBOARD_SV

class top_scoreboard extends uvm_subscriber #(adder_sequence_item);

  `uvm_component_utils(top_scoreboard)

  adder_sequence_item trans;
  int num_passed = 0;
  int num_failed = 0;

  int At, Bt, Ct;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void write(adder_sequence_item t);
  extern function void report_phase(uvm_phase phase);

endclass : top_scoreboard


function top_scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void top_scoreboard::build_phase(uvm_phase phase);
  // If multiple uvm_analysis_imp instantiate the analysis exports here.
endfunction : build_phase


function void top_scoreboard::write(adder_sequence_item t);
  trans = t;

  if (trans.A + trans.B == trans.C) begin
    num_passed++;
  end else begin
    num_failed++;
  end

endfunction : write

function void top_scoreboard::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("passed = %3d, failed: %3d", num_passed, num_failed), UVM_MEDIUM);
endfunction : report_phase

`endif // TOP_SCOREBOARD_SV
