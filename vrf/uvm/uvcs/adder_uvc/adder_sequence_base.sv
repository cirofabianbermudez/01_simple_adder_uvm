`ifndef ADDER_SEQ_BASE_SV
`define ADDER_SEQ_BASE_SV

class adder_sequence_base extends uvm_sequence #(adder_sequence_item);

  `uvm_object_utils(adder_sequence_base)

  extern function new(string name = "");
  extern task body();

endclass : adder_sequence_base


function adder_sequence_base::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_base::body();
  repeat(10) begin
    req = adder_sequence_item::type_id::create("req");
    `uvm_info(get_type_name(), "New transaction generated", UVM_MEDIUM);
    start_item(req);
    if ( !req.randomize() ) begin
      `uvm_error(get_type_name(), "Failed to randomize transaction")
    end
    finish_item(req);
  end

endtask : body

`endif // ADDER_SEQ_BASE_SV
