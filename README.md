# Simple adder verification using UVM 1.2

## RTL

1. Create a directory called `rtl` and inside create a file called `adder.sv` with the following specifications:
   1. Two 8-bit inputs called `A` and `B` and one 8-bit output called `C`.
   2. Make it purely combinational.

## Basic structure

1. Create a directory called `vrf/uvm/uvcs/adder_uvc`, vrf stands for "Verification" and uvcs stands for "Universal Verification Components".
2. Create an interface `adder_if.sv` for the adder in the `vrf/uvm/uvcs/adder_uvc` directory.
   1. Add a header guard with the preprocessor directives `` `ifndef ``, `` `define ``, `` `endif ``. ([**Note 01**](#note-01))
   2. The interface must have three 8-bit signal `A`, `B` and `C`.
3. Create a `tb.sv` file in the `vrf/uvm/tb` directory with the following:
   1. Create a module called `tb`.
   2. Import the UVM-1.2 library with `import uvm_pkg::*`.
   3. Instantiate the interface and call it `vif`.
   4. Instantiate the adder and call it `dut`.
   5. Connect the adder and interface using dot notation.
   6. Generate a basic clock using an `always` block.
      1. Name the clock signal `clk` and make it have a period of 10ns with an initial value of zero.
   7. Generate a reset signals using a `initial` block.
      1. Name the reset signal `rst` with an initial value of one and put it to zero after 10ns.
   8. Create another `initial` block and:
      1. Call `$timeformat(-9, 0, "ns", 10);` to configure the simulation time format. ([**Note 03**](#note-03))
      2. Next call the `run_test()` function, this is the UVM entry point.
4. Create a `top_test.sv` file in the `vrf/uvm/test` directory.
   1. Add header guard.
   2. Create a class `top_test` that extends `uvm_test`.
   3. Register this class into the factory using the appropriate macro, which in this case `` `uvm_component_utils(top_test) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_component`. ([**Note 02**](#note-02))
   5. Create a `run_phase()` task and: ([**Note 04**](#note-04))
      1. Raise and objection with `phase.raise_objection(this);`
      2. Call `` `uvm_info(get_type_name(), "Some message", UVM_MEDIUM) `` to display a message. ([**Note 05**](#note-05))
      3. Drop the objection with `phase.drop_objection(this);`
5. Create a `top_test_pkg.sv` in the `vrf/uvm/test` directory.
   1. Add header guard.
   2. Use `` `include "uvm_macro.svh" `` and `import uvm_pkg::*;` to get access to the UVM library and macros. You can open any of this files and see that they both have header guards.
   3. Include `top_test.sv`, use `` `include "top_test.sv" ``.
6. Finally open `tb.sv` which is inside `vrf/uvm/tb` and import `top_test_pkg`, use `import top_test_pkg::*;`.

This is the bare minimum structure for a UVM testbench to work, you can run this code without errors but it does not do anything yet besides displaying a message. From here the goal is to add the remaining pieces like environment, agent, driver, monitor, sequencer, sequence, transaction and more to make a complete UVM testbech.

## Inner workings

The `run_phase()` task in `top_test.sv` seems to be just displaying a message right now but this part of the code is in charge of starting the sequence that will stimulate the DUT later, keep this in mind.

UVM is based in **Phasing and Objections** ([**Note 04**](#note-04)).  A UVM testbench, if is using the standard phasing, has a number of zero time phases to build and connect the testbench, then a number of time consuming phases, and finally a number of zero time cleanup phases. End of test occurs when all of the time consuming phases have ended. Each phase ends when there are no longer any pending objections to that phase. So end-of-test in the UVM is controlled by managing phase objections. This is the reason why the first thing the `run_phase()` does is to raise an objection, it prevents the test to end, then displays a message and at the end drops the objection upon completion.

To start a UVM testbench, the `run_test()` method has to be called from the static part of the testbench. It is usually called from within an `initial` block in the top level module of the testbench. Calling `run_test()` constructs the UVM environment root component and then initiates the UVM phasing.

The `run_test()` method can be passed a string argument to define the default type name of an `uvm_component` derived class which is used as the root node of the testbench hierarchy. However, the `run_test()` method checks for a command line plusarg called `UVM_TESTNAME` and uses that plusarg string to lookup a factory registered `uvm_component`, overriding any default type name.

 To compile and run the code it is necessary to have a `Makefile` with everything configured, please refer to the [Makefile](Makefile) provided to create your own modifying it as necessary, see the [vcs/simv flags documentation](docs/vcs_simv_flags.md) file for more details.

The structure of a UVM testbench is a top bottom abroach, components of a higher hierarchy create and handle components of lower hierarchy, however when writing a new UVC is a good idea to invert this order. Start modeling the transaction, then combine multiple transactions into a sequence, then a sequencer that passes the sequences into the driver and so on. It is better to take this abroach because components as drivers and sequences are parameterized with the transaction.

The basic structure of a UVM testbech is the following:

- Test
  - Environment
    - Scoreboard
    - Agent
      - Driver
      - Monitor
      - Coverage (Optional)
      - Sequencer <- Sequence <- Transaction

UVM has an immense number of classes, however not all of them are used frequently and other are reserve for internal functionality. From the user point of view, it is only necessary to know a reduce number of commonly use classes ([**Note 06**](#note-06)).

Lets make or way through creating a UVC for a simple adder.

## Sequence item (Transaction)

The sequence item or transaction is the the foundation on which sequences are built, some care needs to be taken with their design. Sequence items content is determined by the information that the driver needs in order to execute a pin level transaction.

1. Create a `adder_sequence_items.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory
   1. Add header guard.
   2. Create a class `adder_sequence_item` that extends `uvm_sequence_item`
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_object_utils(adder_sequence_item) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_object`. ([**Note 02**](#note-02))
2. Declare the necessary attributes to correctly model the transaction.
   1. `A` and `B` must be declared as `rand` so that they take advantage of randomization.
   2. For example `rand logic [7:0] A`.
   3. The output `C` does not need to be random.
3. Create the basic functions to handle transactions. ([**Note 07**](#note-07))
   1. `do_copy()`, `do_compare()`, `do_print()`, `convert2string()`.
   2. UVM Cookbook recommends not using UVM filed macros to generate the transaction functions.
   3. For more information go to **UVM Cookbook**, page 515.
4. Create a `constraint` block, this is optional. ([**Note 08**](#note-08))

## Sequencer

A sequencer serves as a router of sequence_items (transactions). The sequencer can receive sequence_items from any number of sequences (stimulus generators) and route these items to the agent’s driver. Sequencers are extended from the `uvm_sequencer` base class, and inherit all necessary routing and arbitration functionality from this base class. The `uvm_sequencer` base class contains a type parameter that defines what type of
sequence_item class the sequencer can route. This parameter must be defined, in order to specialize the sequencer to match the driver to which it will be connected.

Since the `uvm_sequencer` base class functionality does not need to be extended, it is possible to use the base class directly within an agent, by simply defining the sequencer’s type parameter to a specific sequence_item type. Never the less, it is a good idea to have this code separated in its own file.

1. Create a `adder_sequencer.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory.
2. Add header guard.
3. Use a `typedef`  declaration with `uvm_sequencer` parameterized with `adder_sequence_items` and call it `adder_sequencer`.
   - Translated into code: `typedef uvm_sequencer #(adder_sequence_item) adder_sequencer;`


## Sequence

A sequence is an example of what software engineers call a 'functor', in other words it is an object that is used as a method. An UVM sequence contains a task called `body()`. When a sequence is used, it is created, then the `body()` method is executed, and then the sequence can be discarded. Unlike an `uvm_component`, a sequence has a limited simulation life-time and can therefore can be described as a transient object. The sequence `body()` method can be used to create and execute other sequences, or it can be used to generate sequence_item objects which are sent to a driver component, via a sequencer component.

The sequence_item objects are also transient objects, and they contain the information that a driver needs in order to carry out a pin level interaction with a DUT.  The fact that sequences and sequence_items are objects means that they can be easily randomized to generate interesting stimulus.

In the UVM sequence architecture, sequences are responsible for the stimulus generation flow and send sequence_items to a driver via a sequencer component.

1. Create a `adder_sequence_base.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
   1. Add header guard.
   2. Create a class `adder_sequence_base` that extends `uvm_sequence` parameterized with the transaction `adder_sequence_items`.
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_object_utils(adder_sequence_base) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_object`.
2. Create a task called `body()`, inside this task:
   1. Open a `repeat(10)` loop and inside:
   2. Instantiate an `adder_sequence_item` object called `req` using the UVM creation mechanism.
      - Translated into code: `req = adder_sequence_item::type_id::create("req");`
      - It is not necessary to declare an `req` attribute because this is automatically done by `uvm_sequence`.
   3. Call `start_item(req)`.
   4. Randomize the sequence with `req.randomize()`, optionally check for errors and display an error message. ([**Note 09**](#note-09))
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

The UVM test has several responsibilities:

- Get the virtual interface handle(s) from the configuration database.
- Instantiate the UVM environment.
- Use the configuration database to pass the virtual interface handle(s) and other information down to the environment.
- Instantiate and start any sequences necessary for the test case.
- Manage phase objections, to ensure the test successfully completes.

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

Sometimes the agent does not need to have a driver and a sequencer if the only thing you need is to monitor the DUT, when this happens the agent is a pasive agent, otherwise it is active. To acomplish that you can use a configuration object. 

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
	5. Register the configuration object into the `uvm_config_db`,  `uvm_config_db #()::set(this, "adder_agt", "cfg", adder_agt_cfg);`
	6. Move the instantiation code of the adder agent to the `build_adder_agent()` function
	7. Call the function `build_adder_agent()` inside the `build_phase()` function.

3. Open `adder_agent.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Declare an atribute `adder_config` called `cfg`.
	2. In the build phase retrive the configuration `uvm_config_db #(adder_config)::get(this, "", "cfg", cfg) ` and check for errors
	3. Using an if statement check the `cfg.is_active` attribute to decide to instantiate or not the driver and the sequencer
	4. Do the same in the conect phase to connect or not the driver to the sequencer.
4. Include `adder_config.sv` into `adder_pkg.sv`

## Coverage

Another interesting feature we can add to the agent is to know much of the design we have tested. This is called coverage, and it is a way to check how many combinations of different inputs we have passed through out the DUT.

1. Create a `adder_coverage.sv` in the `vrf/uvm/uvcs/adder_uvc` directory
	1. Create a class `adder_coverage` that extends `uvm_suscriber`
	2. Register this class in the factory with the proper macro, in this case a `uvm_component_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm object.
2. Then 
	1. Declare an atribute `adder_config` called `cfg`
	1. Declare an atribute `adder_sequence_item` called `trans`
	1. Declare an atribute `bit` called `is_covered`

The important thing to know about the `uvm_suscriber` class is that it has a built-in analysis export for receiving transactions from a connected analysys port. To be more precise it has a `uvm_analysis_imp #(T, this_type) analysis_export;` that is instantiated `analysis_export = new("analysis_imp", this);` in the constructor. Making such a connection subscribes this component to any transactions emitted by the connected analysis port. The analysis port in the monitor calls a `write()` method to broadcast out a handle to a sequence_item. Each analysis imp export connected to the port must implement this `write()` method. 

The implementation of the `write()` function must copy the sequence_item handle passed from the monitor to the coverage collectors handle and then called the coverage `sample()` method to actually collect coverage information.

3. Create a coverage group that checks all the 256 by 256 combinations of A and B of the adder. 
	1. Instanciate the covergroup using the `new()` keyword inside the constructor of the class.
	2. Create a `build_phase` where you retreive the configuration object from the uvm_config_db and check for errors.
	3. Create a `write()` funciton where the input is an `adder_sequence_item `and inside 
	4. if `cfg.coverage_enable` is true, assign the value to `trans` and call the `sample()` function of the covergroup
4. Optionally you can create a `report_phase` function that check if `cfg.coverage_enable` is true and display the coverage 
	1. Using `uvm_info` and the `adder.cov.get_coverage()` method.

5. Open `adder_agent.sv` and
	1. Declare an atribute `adder_coverage` called `cov` 
	2. In the `build_phase` create an if statement that check `cfg.coverage_enable` to instantiate or not `cov` using the uvm mechanism
	3. In the `connect_phase` create an if statement that check `cfg.coverage_enable` to connect or not the monitor to the coverage
		1. mon.analysis_port.connect(cov.analysis_export);

## Scoreboard

The primary role of a scoreboard in UVM is to verify that actual DUT outputs match predicted output values, we can follow a similar implemetation as the coreverage.

1. Create a `top_scoreboard.sv` in the `vrf/uvm/env` directory
	1. Create a class `top_scoreboard` that extends `uvm_suscriber`
	2. Register this class in the factory with the proper macro, in this case a `uvm_component_utils`.
	3. The factory requires a constructor, create the proper constructor for a uvm object.
	4. Declare an atribute `adder_sequence_item` called `trans`
	5. Declare an atribute `int` called `num_passed` and another called `num_failed` initialize with zero.
2. Create a `write()` method that is called from the monitor with `adder_sequence_item` call `t `as an argument
	1. Copy the content of `t` into `trans`
	2. Using and if statement check if the information of the monitor transaction is correct and increase the `num_passed` and `num_failed` accordingly
3. Create a `report_phase()` function that displays the values of passed and frailed transactions.
4. Open `top_env.sv`
	1. Declare an atribute `top_scoreboard` called `scoreboard`;
	2. Instantiate the scoreboard using the using the uvm mechanism `::type_id::create()` called `scoreboard`
	3. Connect the the scoreboard port to the monitor port, in this step the are two options
		1. Connect directly the scoreboard to the agent monitor port or
		2. Create a pass through port from the monitor to the agent and then conect the agent port to the scoreboard
The advantage of the second option is that it better encapsulate the agent and from the point of view of an environment writer it is easier to undertand, the environment writer does not need to know the inner implementation of the agent, the only think he must worry about is how to connect properly the agent port to the scoreboard.
	4. Inside `top_env.sv`
		1. Create a `connect_phase()` function and connect the agent analysis port to the scoreboard analysis export.   adder_agt.analysis_port.connect(scoreboard.analysis_export);
	5. Open `adder_agent` and 
		1. Declare an atribute `uvm_analysis_port #(adder_sequence_item) analysis_port;`
		2. Instantiate the analysis port in the `build_phase()` function
		3. In the `connect_phase()` function connect the monitor analysis port and the agent analysis port
	6. Add `top_scoreboard.sv` into the `top_env_pkg.sv`



make PLUS=uvm_set_type_override=adder_sequence_base,adder_sequence_rand_no_repeat

In the test `build_phase` of `top_test` or in a extended class, let say `test_feat` of `top_test` you can put this override and select the test in the Makefile
set_type_override_by_type( adder_sequence_base::get_type(), adder_sequence_directed::get_type() );


Note: when using `+ntb_random_seed_automatic` the seed appears in both the simulation log and the coverage report. 


## Notes

### Note 01

([**Basic structure**](#basic-structure)) -

A header guard is a preprocessor directive used in programming languages to prevent a header file from being included more than once. Helps maintain consistency, encapsulation and improve performance. It is recommended to use it in all the `.sv` files with the exception of `tb.sv`.

Example:

```systemverilog
`ifndef TOP_TEST_PKG_SV
`define TOP_TEST_PKG_SV

package top_test_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  `include "top_test.sv"

endpackage : top_test_pkg

`endif // TOP_TEST_PKG_SV
```

This is a simplify version of `top_test_pkg.sv`.

### Note 02

([**Basic structure**](#basic-structure)) - ([**Sequence item**](#sequence-item-transaction))

For more information go to **UVM Cookbook**, pages 9-10.

For an `uvm_component` the **Factory Registration** and **Constructor Defaults** are the following:

```systemverilog
class my_component extends uvm_component;

  // Component factory registration macro
  `uvm_component_utils(my_component)

  // Component constructor defaults
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : my_component
```

For an `uvm_object` the **Factory Registration** and **Constructor Defaults** are the following:

```systemverilog
class my_item extends uvm_sequence_item;

  // Object factory registration macro
  `uvm_object_utils(my_item)

  // Object constructor defaults
  function new(string name);
    super.new(name);
  endfunction : new
  
endclass : my_item
```

It is important to know that `uvm_sequence_item` extends from `uvm_transaction` that extends from `uvm_object`.

## Note 03

([**Basic structure**](#basic-structure)) -

For more information go to **IEEE Std 1800-2017**, page 595.

The `$timeformat` system task performs the following two functions:

- It specifies how the `%t` format specification reports time information for the `$write`, `$display`, `$strobe`, `$monitor`, `$fwrite`, `$fdisplay`, `$fstrobe`, and `$fmonitor` group of system tasks.
- It specifies the time unit for delays entered interactively.

Syntax:

```systemverilog
$timeformat(<unit_number>, <precision_number>, <suffix_string>, <minimum_field_width>);
```

- `<unit_number>`: is the smallest time precision argument of all the `` `timescale ``
compiler directives in the source description. `0`->1s, `-3`->1ms, `-6`->1us, `-9`->1ns
- `<precision_number>`: represents the number of fractional digits for the current timescale.
- `<suffix_string>`: is an option to display the scale alongside the real time values.
- `<minimum_field_width>`: is the amount of character that `%t` will have.
  
Example:

```systemverilog
$timeformat(-9, 0, "ns", 10);
```

### Note 04

([**Basic structure**](#basic-structure)) - ([**Inner workings**](#inner-workings))

For more information go to **UVM Cookbook**, pages 11-14.

In order to have a consistent testbench execution flow, the UVM uses phases to order the major steps that take place during simulation. There are three groups of phases, which are executed in the following order:

1. Build phases - where the testbench is configured and constructed.
2. Run-time phases - where time is consumed in running the testcase on the testbench.
3. Clean up phases - where the results of the testcase are collected and reported.

The `uvm_component` base class contains virtual methods which are called by each of the different phase methods and these are populated by the testbench component creator according to which phases the component participates in. Using the defined phases allows
verification components to be developed in isolation, but still be interoperable since there is a common understanding of what should happen in each phase.

```systemverilog
// Build Phases
extern function void build_phase(uvm_phase phase);                 // <- Essential
extern function void connect_phase(uvm_phase phase);               // <- Essential
extern function void end_of_elaboration_phase(uvm_phase phase);    // <- Good to use

// Run-time Phases
extern function void start_of_simulation_phase(uvm_phase phase);   
extern task run_phase(uvm_phase phase);                            // <- Essential

// Cleanup Phases
extern function void extract_phase(uvm_phase phase);
extern function void check_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);                // <- Good to use
extern function void final_phase(uvm_phase phase);
```

In UVM, the `run_phase()` is the only time-consuming phase of execution. All execution of all components, including the test and environment, should be handled by
`run_phase()`. In order to ensure that all of your desired transactions execute in your test case, you must tell UVM not to exit the `run_phase` until your desired stimuli complete. This is done using objections.

The `raise_objection()` call must be made before the first nonblocking assignment is made in that phase.
The phase method will continue until all raised objections are dropped. Dropping the objection upon
completion of the sequence is usually sufficient to allow the run_phase to complete correctly.

Example:

```systemverilog
task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  ...
  phase.drop_objection(this);
endtask
```

### Note 05

([**Basic structure**](#basic-structure)) -

To displays messages UVM uses the following macros:

```systemverilog
`uvm_info(string id, string message, int verbosity)
`uvm_warning(string id, string message)
`uvm_error(string id, string message)
`uvm_fatal(string id, string message)
```

There are six levels of verbosity:

```systemverilog
UVM_NOME
UVM_LOW
UVM_MEDIUM
UVM_HIGH
UVM_FULL
UVM_DEGUG
```

You can select the verbosity from the command line with:

```bash
+UVM_VERBOSITY=verbosity
```

It is fairly common to use `get_type_name()` as `string id` for `` `uvm_info()`` to track the source of the messages.

When calling `` `uvm_warning() `` or `` `uvm_error() `` an internal counter is increase in each call, and the simulation continues. When calling `` `uvm_fatal() `` an internal counter is increase but simulation ends immediately.

### Note 06

([**Basic structure**](#basic-structure)) - ([**Inner workings**](#inner-workings))

The UVM class hierarchy is very large and if you are interested in learning more please refer to **PLACEHOLDER** where you will find a reduced but useful tree representation of the class hierarchy.

This is a simple subset of commonly used UVM classes.

Basic Classes

- `uvm_object`
- `uvm_component`

Use to create the UVM testbench structure

- `uvm_test`
- `uvm_env`
- `uvm_agent`
- `uvm_driver`
- `uvm_monitor`
- `uvm_sequencer`
- `uvm_scoreboard`
- `uvm_subscriber`

Use for TLM communication

- `uvm_analysis_port`
- `uvm_analysis_imp`

Use for transitions

- `uvm_sequence`
- `uvm_sequence_item`


### Note 07

([**Sequence item**](#sequence-item-transaction))

Example of functions to handle transactions for the `adder_sequence_item.sv` based on **Doulos Easier UVM Code Generator**.

```systemverilog
function void adder_sequence_item::do_copy(uvm_object rhs);
  adder_sequence_item rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  A = rhs_.A;
  B = rhs_.B;
  C = rhs_.C;   
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
    "C = 'h%0h  'd%0d\n"},
    get_full_name(), A, A, B, B, C, C);
  return s;
endfunction : convert2string
```

### Note 08

([**Sequence item**](#sequence-item-transaction))

Examples of constraints:

It is recommended that the name of the constraint have the name of the transaction and an identifier representative of what it does.

```systemverilog
  // Example 1
  constraint adder_seq_item_range_constraint {
    A inside {[0:255]};
    B inside {[0:255]};
  }

  // Example 2
  constraint adder_seq_item_lessthan_constraint {
    A < B;
  }

  // Example 3
  constraint adder_seq_item_spacific_values_constraint {
    A inside {10, 20, 100, 200};
    ! (B inside {10, 20, 100, 200} );
  }

  // Example 4 Total: 320 P(0) = 20/320   P(1) = 50/320  ... P(7) = 10/320
  constraint adder_seq_item_dist_constraint {
    A dist {
      0     := 20, 
      [1:5] := 50, 
      6     := 40,
      7     := 10
    };
  }
```

### Note 09

([**Sequence**](#sequence))

This is a simple example of the `body()` function for a sequence.

```systemverilog
task adder_sequence_base::body();
  repeat(10) begin
    req = adder_sequence_item::type_id::create("req");
    start_item(req);
    if ( !req.randomize() ) begin
      `uvm_error(get_type_name(), "Failed to randomize transaction")
    end
    finish_item(req);
  end
endtask : body
```

## References

- [1] UVM Cookbook | Cookbook | Siemens Verification Academy, Verification Academy. Accessed: Jun. 03, 2024. [Online]. Available: https://verificationacademy.com/cookbook/uvm-universal-verification-methodology/

- [2] S. Sutherland and T. Fitzpatrick, "UVM Rapid Adoption: A Practical Subset of UVM," in Proc. Design and Verification Conference (DVCon), March 2015. Available: https://dvcon-proceedings.org/wp-content/uploads/uvm-rapid-adoption-a-practical-subset-of-uvm-paper.pdf

- [3] (IEEE Std 1800-2017) - IEEE Standard for SystemVerilog--Unified Hardware Design, Specification, and Verification Language. IEEE. doi: 10.1109/IEEESTD.2018.8299595. [Online]. Available: https://ieeexplore.ieee.org/document/8299595

- [4] ClueLogic - Providing the clues to solve your verification problems. Accessed: Jun. 03, 2024. [Online]. Available: https://cluelogic.com/

- [5] “Easier UVM.” Accessed: Jun. 04, 2024. [Online]. Available: https://www.doulos.com/knowhow/systemverilog/uvm/easier-uvm/

- [6] “UVM (Universal Verification Methodology).” Accessed: Jun. 04, 2024. [Online]. Available: https://www.accellera.org/downloads/standards/uvm
