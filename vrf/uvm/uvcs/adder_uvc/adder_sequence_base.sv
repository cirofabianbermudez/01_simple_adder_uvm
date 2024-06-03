`ifndef ADDER_SEQ_BASE_SV
`define ADDER_SEQ_BASE_SV

class adder_sequence_base extends uvm_sequence #(adder_sequence_item);

  `uvm_object_utils(adder_sequence_base)

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_base


function adder_sequence_base::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_base::body();
  repeat(10) begin
    req = adder_sequence_item::type_id::create("req");
    //`uvm_info(get_type_name(), "New transaction generated", UVM_MEDIUM);
    start_item(req);
    if ( !req.randomize() ) begin
      `uvm_error(get_type_name(), "Failed to randomize transaction")
    end
    finish_item(req);
  end

endtask : body

// ===============================================================================
// ===============================================================================
// ===============================================================================
// ===============================================================================

class adder_sequence_all_combinations extends adder_sequence_base;

  `uvm_object_utils(adder_sequence_all_combinations)

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_all_combinations 


function adder_sequence_all_combinations::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_all_combinations::body();
  for (int i = 0; i < 256; i++) begin
    for (int j = 0; j < 256; j++) begin
      req = adder_sequence_item::type_id::create("req");
      start_item(req);
      req.A = i;
      req.B = j;
      finish_item(req);
    end
  end
endtask : body


// ===============================================================================
// ===============================================================================
// ===============================================================================
// ===============================================================================

class adder_sequence_rand_no_repeat extends adder_sequence_base;

  `uvm_object_utils(adder_sequence_rand_no_repeat)

  bit [7:0] A_values[256];
  bit [7:0] B_values[256];

  extern function new(string name = "");
  extern virtual task body();
  extern function init_array();
  extern function shuffle();
  extern function review();

endclass : adder_sequence_rand_no_repeat 


function adder_sequence_rand_no_repeat::new(string name = "");
  super.new(name);
  init_array();
  shuffle();
  review();
endfunction : new

function adder_sequence_rand_no_repeat::init_array();
  for (int i = 0; i < 256; i++) begin
    A_values[i] = i;
    B_values[i] = i;
  end
endfunction : init_array


function adder_sequence_rand_no_repeat::shuffle();
  bit [7:0] auxA, auxB;
  int idxA, idxB;
  for (int i = 0; i < 256; i++) begin
    idxA = $urandom_range(255,0);
    idxB = $urandom_range(255,0);

    auxA = A_values[i];
    auxB = B_values[i];

    A_values[i] = A_values[idxA];
    B_values[i] = B_values[idxB];

    A_values[idxA] = auxA;
    B_values[idxB] = auxB;
  end
endfunction : shuffle


function adder_sequence_rand_no_repeat::review();
  for (int i = 0; i < 256; i++) begin
    `uvm_info(get_type_name(), $sformatf("A = %3d, B = %3d", A_values[i], B_values[i]), UVM_MEDIUM)
  end
endfunction : review

task adder_sequence_rand_no_repeat::body();
  for (int i = 0; i < 256; i++) begin
    for (int j = 0; j < 256; j++) begin
      req = adder_sequence_item::type_id::create("req");
      start_item(req);
      req.A = A_values[i];
      req.B = B_values[j];
      finish_item(req);
    end
  end
endtask : body

// ===============================================================================
// ===============================================================================
// ===============================================================================
// ===============================================================================

class adder_sequence_directed extends adder_sequence_base;

  `uvm_object_utils(adder_sequence_directed)

  bit [7:0] A_input = 8'd8;
  bit [7:0] B_input = 8'd8;

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_directed 


function adder_sequence_directed::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_directed::body();
    req = adder_sequence_item::type_id::create("req");
    start_item(req);
    req.A = A_input;
    req.B = B_input;
    finish_item(req);
endtask : body

`endif // ADDER_SEQ_BASE_SV
