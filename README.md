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
		3.1. Create the proper constructor for a uvm component
	4. Declare a handler for an environment
	5. Use the `build_phase` function to create the environment using the uvm factory mechanism

