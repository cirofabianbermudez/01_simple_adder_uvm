`ifndef ADDER_SEQ_BASE_SV
`define ADDER_SEQ_BASE_SV

class adder_sequence_base extends uvm_sequence #(adder_sequence_item);

  `uvm_object_utils(adder_sequence_base)

  int n = 100;

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_base


function adder_sequence_base::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_base::body();
  repeat(n) begin
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

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_directed 


function adder_sequence_directed::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_directed::body();

    req = adder_sequence_item::type_id::create("req");
    start_item(req);
    req.A = 8'd8;
    req.B = 8'd8;
    req.rst = 8'd0;
    finish_item(req);

endtask : body

// ===============================================================================
// ===============================================================================
// ===============================================================================
// ===============================================================================

class adder_sequence_manual extends adder_sequence_base;

  `uvm_object_utils(adder_sequence_manual)

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_manual


function adder_sequence_manual::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_manual::body();

    req = adder_sequence_item::type_id::create("req");
    start_item(req);
    req.A = 8'd10;
    req.B = 8'd20;
    req.rst = 1'd0;
    finish_item(req);

    req = adder_sequence_item::type_id::create("req");
    start_item(req);
    req.A = 8'd1;
    req.B = 8'd2;
    req.rst = 1'd0;
    finish_item(req);

endtask : body

// ===============================================================================
// ===============================================================================
// ===============================================================================
// ===============================================================================

class adder_sequence_of_sequences extends adder_sequence_base;

  `uvm_object_utils(adder_sequence_of_sequences)

  adder_sequence_manual   seq_man;
  adder_sequence_directed seq_dir;

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_of_sequences


function adder_sequence_of_sequences::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_of_sequences::body();
  seq_man = adder_sequence_manual::type_id::create("seq_man");
  seq_dir = adder_sequence_directed::type_id::create("seq_dir");
  seq_man.start(m_sequencer, this);
  seq_dir.start(m_sequencer, this);
endtask : body


// ===============================================================================
// ===============================================================================
// ===============================================================================
// ===============================================================================

class adder_sequence_rst extends adder_sequence_base;

  `uvm_object_utils(adder_sequence_rst)

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_rst


function adder_sequence_rst::new(string name = "");
  super.new(name);
endfunction : new

task adder_sequence_rst::body();

  req = adder_sequence_item::type_id::create("req");
  start_item(req);
  req.A   = 8'd2;
  req.B   = 8'd2;
  req.rst = 1'd1;
  req.trans_stage = TRANS_FISRT;
  req.trans_type  = TRANS_ASYNC;
  finish_item(req);

  req = adder_sequence_item::type_id::create("req");
  start_item(req);
  req.A   = 8'd1;
  req.B   = 8'd1;
  req.rst = 1'd0;
  finish_item(req);

  req = adder_sequence_item::type_id::create("req");
  start_item(req);
  req.A   = 8'd3;
  req.B   = 8'd3;
  req.rst = 1'd0;
  finish_item(req);

  req = adder_sequence_item::type_id::create("req");
  start_item(req);
  req.A   = 8'd4;
  req.B   = 8'd4;
  req.rst = 1'd0;
  req.trans_stage = TRANS_LAST;
  finish_item(req);

endtask : body


// ===============================================================================
// ===============================================================================
// ===============================================================================
// ===============================================================================

class adder_sequence_with_rst extends adder_sequence_base;

  `uvm_object_utils(adder_sequence_with_rst)

  adder_sequence_rst   seq_rst;
  adder_sequence_base  seq_base;

  extern function new(string name = "");
  extern virtual task body();

endclass : adder_sequence_with_rst


function adder_sequence_with_rst::new(string name = "");
  super.new(name);
endfunction : new


task adder_sequence_with_rst::body();
  seq_rst  = adder_sequence_rst::type_id::create("seq_rst");
  seq_base = adder_sequence_base::type_id::create("seq_base");
  seq_rst.start(m_sequencer, this);
  seq_base.start(m_sequencer, this);
endtask : body

`endif // ADDER_SEQ_BASE_SV
