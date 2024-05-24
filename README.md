# 01_simple_adder_uvm

A simple adder implementation and verification using UVM 1.2

1. Create an interface `adder_if.sv` for the adder in the `rtl` directory
2. Create a `tb.sv` file with the following in the `tb` directory:
	1. Import the UVM-1.2 library with `import uvm_pkg::*`
	2. Instanciate the interface
	3. Intanciate the adder
	4. Connect the adder and interface
	5. Generate the basic clock and reset signals.
	6. In an initial block put the `run_test()` function, this is the UVM entry point.
3. Create a `top_test.sv` file in the `test` directory.
	1. Create a named `top_test` that extends `uvm_test`
	2. Register this class in the factory with the proper macro.
	3. The factory requires a constructor
		1.  Create the proper constructor for a uvm component
	4. Create a `run_phase` task
		1. Inside the task raise and drop an objection
		2. After raising the objection call `uvm_info` to display a messagge		
4. Create a `top_test_pkg.sv` in the `test` directory
	1. Import `uvm_pkg` and include `uvm_macro.svh`
	2. Include `top_test.sv`
5. In `tb.sv` import `top_test_pkg`

This is the bare minimum structure for the UVM testbench, from here the idea is to add the remaining pieces like
environment, driver, monitor, transaction and more. The `run_phase` task in `top_test.sv` is temporal, it is only
used display something in the console and check everything is working fine. From here you can run `make` and see 
the message.


The next step is to create the transaction the transaction
1. Create a `adder_trans.sv` in the `adder_uvc` directory
2. Create the sequence
