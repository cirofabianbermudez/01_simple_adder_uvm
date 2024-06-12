`ifndef ADDER_SEQ_ITEM_SV
`define ADDER_SEQ_ITEM_SV

class adder_sequence_item extends uvm_sequence_item; 

  `uvm_object_utils(adder_sequence_item)

  rand logic [7:0] A;
  rand logic [7:0] B;
       logic [7:0] C;

  rand logic      rst;
  trans_stage_t   trans_stage = TRANS_MIDDLE;
  trans_type_t    trans_type  = TRANS_SYNC;

  extern function new(string name = "");

  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function string convert2string();

  constraint all_values_constraint {
    A inside {[0:255]};
    B inside {[0:255]};
  }

 constraint rst_constraint {
   rst inside {0,1};
   rst dist { 0 := 90, 1 := 10};
 }

endclass : adder_sequence_item 


function adder_sequence_item::new(string name = "");
  super.new(name);
endfunction : new


function void adder_sequence_item::do_copy(uvm_object rhs);
  adder_sequence_item rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  A = rhs_.A;
  B = rhs_.B;
  C = rhs_.C;   
  rst = rhs_.rst;   
endfunction : do_copy


function bit adder_sequence_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  adder_sequence_item rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= (A == rhs_.A);
  result &= (B == rhs_.B);
  result &= (C == rhs_.C);
  result &= (rst == rhs_.rst);
  return result;
endfunction : do_compare


function void adder_sequence_item::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function string adder_sequence_item::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "A = 'h%0h  'd%0d\n", 
    "B = 'h%0h  'd%0d\n", 
    "C = 'h%0h  'd%0d\n",
    "rst = 'h%0h  'd%0d\n"},
    get_full_name(), A, A, B, B, C, C,rst,rst);
  return s;
endfunction : convert2string

`endif // ADDER_SEQ_ITEM_SV

