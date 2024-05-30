# 01_simple_adder_uvm

A simple adder implementation and verification using UVM 1.2

## Basic structure

1. Create an interface `adder_if.sv` for the adder in the `vrf/uvm/rtl` directory.
1. Create a `tb.sv` file with the following in the `tb` directory:
	1. Import the UVM-1.2 library with `import uvm_pkg::*`
	2. Instanciate the interface
	3. Instanciate the adder
	4. Connect the adder and interface
	5. Generate the basic clock and reset signals.
	6. In an initial block put the `run_test()` function, this is the UVM entry point.
2. Create a `top_test.sv` file in the `test` directory.
	1. Create a named `top_test` that extends `uvm_test`
	2. Register this class in the factory with the proper macro, in this case a `uvm_component_utils`.
	3. The factory requires a constructor. Create the proper constructor for a uvm component
	4. Create a `run_phase` task
		1. Inside the task raise and drop an objection
		2. After raising the objection call `uvm_info` to display a messagge		
3. Create a `top_test_pkg.sv` in the `test` directory
	1. Import `uvm_pkg` and include `uvm_macro.svh`, this file already have header guards.
	2. It is a good practice to use header guard with the preprocessor directives `ifndef/define/endif`to avoid importing the package multiple times
	2. Include `top_test.sv`
4. In `tb.sv` import `top_test_pkg`

This is the bare minimum structure for the UVM testbench, you can run this code without errors but it doesnt do anything yet besides displaying a message, from here the idea is to add the remaining pieces like environment, driver, monitor, transaction and more. The `run_phase` task in `top_test.sv` is just displaying a message rigth now but it is in charge of starting the sequence that will stimulate the DUT later keep this in mind. To compile and run the code it is necessary to have a `Makefile` with everything configured, please refer to the `Makefile` provided. 


The structure of a UVM testbench is a top bottom aproach, however to we need define the bottom elements first.

## Sequence item / Transaction

1. Create a `adder_sequence_items.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Create a class `adder_sequence_item` that extends `uvm_sequence_item`
	2. Register this class in the factory with the proper macro, in this case a `uvm_object_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm object
2. Declare all atributes necessary to correctly represent the transaction
3. Create the basic functions to handle the transaction
	1. `do_copy()`, `do_compare()`, `do_print()`, `convert2string()`
	2. UVM Cookbook recommendation, don't use the utility macros to generate the transaction functions.
4. Create some constraints to the signals if necessary.

## Sequencer

1. Create a `adder_sequencer.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory
2. Use a `typedef uvm_sequencer` parameterized with the transaction

## Sequence

1. Create a `adder_sequence_base.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Create a class `adder_sequence_base` that extends `uvm_sequence` parameterized with the transaction
	2. Register this class in the factory with the proper macro, in this case a `uvm_object_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm object
2. Create a task called `body()`, inside this task:
	1. Open a `repeat(10)` loop and inside
	2. Instanciate a `adder_sequence_item` using the uvm mechanism `::type_id::create()` called `req`
	3. Call `start_item(req)`
	4. Randomize the sequence
	5. Call `finish_item(req)`
	
## Driver

1. Create a `adder_driver.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Create a class `adder_driver` that extends `uvm_driver` parameterized with the transaction
	2. Register this class in the factory with the proper macro, in this case a `uvm_component_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm component
2. Create a `run_phase()` task and inside
	1. Create a `forever` loop and inside
	2. Call `seq_item_port.get_next_item(req);`
	3. Call `uvm_info(get_type_name(), {"req item\n",req.sprint}, UVM_HIGH)`, this is temporal because using the monitor is the way to go
	4. Call `seq_item_port.item_done();`

## Agent

1. Create a `adder_agent.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Create a class `adder_sequence_driver` that extends `uvm_driver` parameterized with the transaction
	2. Register this class in the factory with the proper macro, in this case a `uvm_component_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm component
2. Declare two atributes, one to handle the `adder_sequencer` called `drv`and other to handle `adder_driver` called `sqr`
3. Create a `void build_phase` function and inside
	1. Instanciate the driver and the sequencer using the uvm mechanism `::type_id::create()`
4. Create a `void connect_phase` function and connect the driver and the sequencer
	2. `drv.seq_item_port.connect(sqr.seq_item_export);`

## Environment

1. Create a `top_env.sv` in the `vrf/uvm/env` directory
	1. Create a class `top_env` that extends `uvm_env`
	2. Register this class in the factory with the proper macro, in this case a `uvm_component_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm component
2. Declare an atribute, `adder_agent` called `agt`
3. Create a `void build_phase` function and inside
	1. Instanciate the agent using the uvm mechanism `::type_id::create()`

## Test

1. Open `top_test.sv` and declare an atribute, `top_env` called `env`
2. Create a `void build_phase` function and inside
	1. Instanciate the environment using the uvm mechanism `::type_id::create()`
3. Instanciate a sequence `adder_sequence_base` using the uvm mechanism `::type_id::create()` inside the `run_phase` called `seq` after the `raise_objection` 
4. Call `seq.start(env.agt.sqr)`, IMPORTANT both the instantiation and the call must be inside a `begin end` block. 
	1. Alternatively you can declare and atribute `adder_sequence_base ` called `seq`, 
	2. Instanciate it using the uvm mechanism and call `seq.start(env.agt.sqr)`, in this way you do not need the `begin end` block

## Package for Adder UVC

1. Create a `adder_pkg.sv` file and include  `adder_sequence_item.sv`, `adder_sequencer.sv`, `adder_sequence_base.sv`, `adder_driver.sv`,  `adder_agent.sv`. 
2. It is a good practice to use header guard with the preprocessor directives `ifndef/define/endif`to avoid importing the package multiple times
3. Also it's a good practice to first include uvm_macros.svh and import uvm_pkg::*;, both of these already come with header guards. Some times you dont know the order in which the import and includes are read, for this reason you can include uvm_macros.svh and import uvm_pkg::* at the beggining of each package and be sure that this files are going to be called first and just one because of header guards.


## Package for environment

1. Create a `top_env_pkg.sv` file and import `adder_pkg.sv` and include `top_env.sv`. 
2. It is a good practice to use header guard with the preprocessor directives `ifndef/define/endif`to avoid importing the package multiple times
3. Also it's a good practice to first include uvm_macros.svh and import uvm_pkg::*;, both of these already come with header guards.


## The UVM Test/Driver/Sequence synchronization

1. The test class raises and objection flag `phase.raise_objection(this)` and call `seq.start()` method, which invokes the sequence `body()` task. The `seq.start()` method blocks (waits at that point) until the `body()` task exits.

2. The sequence `body()` task calls a `start_item()` method. `start_item()` blocks (waits) until the driver asks for a transaction (a sequence_item object handle).

3. The driver calls the `seq_item_port.get_next_item()` method and request (pull) a transaction. The driver then blocks (waits) until a transaction is received.

4. The sequence generates the transaction values and calls `finish_item()`, which sends the transaction to the driver. The sequence then blocks (waits) until the driver is finished with that transaction.

5. The driver assigns the transaction values to the interface variables, and then calls the `seq_item_port.item_done()` method to unblock the sequence. The sequence can then repeat steps 2 through 5 to generate additionl stimulus.

6. After the sequence has completed generating stimulus, the sequence `body` exits, which unblocks the test's `start()` method. The test will then continue with its next statements, which includes dropping its objection flag and allowing the `run_phase` to end.



The `Makefile` needs to be changed, 
1. Use `+incdir+` to point to each directory that contains a file that was used in an include directive, update `INCL_FILES` variable
2. Add the package in order of apperance, use a bottom to top aproach, update `PKG_FILES` variable


At this point the testbench is capable of generating the UVM testbench hireachy, create and start sequences from the `test_top`, pass the transactions inside the sequence throgh the driver, the sequencer handles that, and display the transction in the console. I know, a lot of work just to acomplish that, but later you will learn how to take advantage of randomization, overrides to make your job easier. Let say this structure is dificult to create and understand at the begginig, then you can reuse most of the code for many other projects. 

## Connect to the DUT

1. Move `adder_if.sv` into `vrf/uvm/uvcs/adder_uvc` directory.
	1. Do not include the interface in `adder_pkg.sv`, this is ilegal in SystemVerilog
	2. It a good idea to keep all the files refer to the agent in one place
2. In `tb.sv` make the instance of the interface, referred to as a `virtual interface`, available to the environment.
	1. This is done using the UVM configuration database
	2. Before the `run_test()` method call `uvm_config_db #(virtual adder_if)::set(null, "uvm_test_top.env.agt", "vif", vif);`
	3. The instance name of `adder_if` if `vif`, could be any name
	4. "uvm_test_top.env.agt" is the path where this configuration is available to be retrive using the `get` version of the `uvm_config_db` method, also module below the agt have access to this configuration.
3. Declare an atribute, `virtual adder_if` called `vif`
	1. Create a `build_phase` and inside
	2. Retrive the configuration for the virsual interface and check for errors
     ```
		 if (!uvm_config_db#(virtual adder_if)::get(get_parent(), "", "vif", vif)) begin
		  `uvm_fatal(get_name(), "Could not retrieve adder_if from config db")
		end
	```

## Monitor
1. Create a `adder_monitor.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Create a class `adder_monitor` that extends `uvm_monitor`
	2. Register this class in the factory with the proper macro, in this case a `uvm_component_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm component
2. Declare an atribute, `virtual adder_if` called `vif`
	1. Create a `build_phase` and inside
	2. Retrive the configuration for the virtual interface and check for errors
     ```
		 if (!uvm_config_db#(virtual adder_if)::get(get_parent(), "", "vif", vif)) begin
		  `uvm_fatal(get_name(), "Could not retrieve adder_if from config db")
		end
	```
3. Declare an atribute `adder_sequence_item` called`trans`
4. Declare an atribute  `uvm_analysis_port #(adder_sequence_item)` called `analysis_port`
	1. Inside the `build_phase` after the error check instanciate the analysis port using a normal `new()` construct
	2. `analysis_port = new("analysis_port", this);`
5. Create a `run_phase` and inside instantiate `trans` using the uvm mechanism `::type_id::create()` called `trans`
6. After the instantiation capture the values and write to the analysis port, here is an example code
	```
	  forever @(vif.C) begin
		trans.A = vif.A;
		trans.B = vif.B;
		trans.C = vif.C;
		analysis_port.write(trans);
		`uvm_info(get_type_name(), $sformatf("%4d + %4d = %4d", vif.A, vif.B, vif.C), UVM_MEDIUM)
	  end
	```
7. In `adder_agent.sv`
	1. Declare an atribute `adder_monitor` called `mon`
	2. Instanciate the monitor using the uvm mechanism `::type_id::create()`
8. In `adder_driver.sv`
	1. Delete the uvm_info line inside the forever loop
9. Do not forget to include `adder_monitor.sv` in `adder_pkg.sv`


## Verdi support

1. Add put `$fsdbDumpvars;` as the first line inside the `initial` block in the `tb.sv`
2. Make sure you have `-lca -debug_access+all+reverse -kdb +vcs+vcdpluson` in your flags


## Advanced Agent

Sometimes the agent does not need to have a driver and a sequencer the only thing you need is to monitor, when this happens the agent is a pasive agent, otherwise it is active. to acomplish that you can use a configuration object. 

1. Create a `adder_config.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Create a class `adder_config` that extends `uvm_object`
	2. Register this class in the factory with the proper macro, in this case a `uvm_object_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm object
	4. Declare an atribute  `uvm_active_passive_enum` called `is_active` and assign a value of `UVM_ACTIVE`
	5. Declare an atribute  `bit` called `coverage_enable`.
2. Open `top_env.sv`
	1. Declare an atribute  `adder_config` called `adder_agt_cfg`.
	2. Create a void function called `build_adder_agent()` and inside
	3. Instanciate the `adder_config` using the uvm mechanism `::type_id::create()` called `adder_agt_cfg`
	4. Configure the parameters of `adder_agt_cfg` to make the agent active and enable the coverage.
	5. Register the configuration object into the `uvm_config_db`,  `uvm_config_db #()::set(null, "uvm_test_top.env.agt", "vif", vif);`
	6. Move the instantiation code of the adder agent to he function
	7. Call the function `build_adder_agent` inside the `build_phase` function.

3. Open `adder_agent.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Declare an atribute `adder_config` called `cfg`.
	2. In the build phase retrive the configuration `uvm_config_db #(adder_config)::get(this, "", "cfg", cfg) ` and check for errors
	3. Using an if statement check the `cfg.is_active` attribute to decide to instantiate or not the driver and the sequencer
	4. Do the same in the conect phase.
4. Include `adder_config.sv` into `adder_pkg.sv`





