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
5. Create a `top_test_pkg.sv` file in the `vrf/uvm/test` directory.
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

1. Create a `adder_sequence_base.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory
   1. Add header guard.
   2. Create a class `adder_sequence_base` that extends `uvm_sequence` parameterized with the transaction `adder_sequence_items`.
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_object_utils(adder_sequence_base) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_object`.
   5. Declare an `int` attribute called  `n` and initialize it with 10, this is a knob to control the how many transactions are going to be send.
2. Create a task called `body()`, inside this task:
   1. Open a `repeat(n)` loop and inside:
   2. Instantiate an `adder_sequence_item` object called `req` using the UVM creation mechanism.
      - Translated into code: `req = adder_sequence_item::type_id::create("req");`
      - It is not necessary to declare an `req` attribute because this is automatically done by `uvm_sequence`.
   3. Call `start_item(req)`.
   4. Randomize the sequence with `req.randomize()`, optionally check for errors and display an error message. ([**Note 09**](#note-09))
   5. Call `finish_item(req)`.

## Driver

The UVM driver is responsible for communicating at the transaction level with the sequence via TLM communication with the sequencer and converting between the sequence_item on the transaction side and pin-level activity in communicating with the DUT via a virtual interface.

Stimulus generation in the UVM relies on a coupling between sequences and drivers. A sequence can only be written when the characteristics of a driver are known, otherwise there is a potential for the sequence or the driver to get into a deadlock waiting for the other to provide an item.

1. Create a `adder_driver.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory
   1. Add header guard.
   2. Create a class `adder_driver` that extends `uvm_driver` parameterized with the transaction `adder_sequence_items`.
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_component_utils(adder_driver) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_component`.
2. Create a `run_phase()` task and inside
   1. Create a `forever` loop
   2. Call `seq_item_port.get_next_item(req);` to request (pull) a transaction.
   3. Call `` `uvm_info(get_type_name(), {"req item\n",req.sprint}, UVM_HIGH) ``
      - This is temporal, later the proper code will be added.
   4. Call `seq_item_port.item_done();` to unblock the sequence.

## Agent

A UVM agent is a low-level building block that is associated with a specific set of DUT I/O pins and the communication protocol for those pins. For example, the SPI bus to a DUT will have an agent for that set of ports.

An agent contains three required components: a sequencer, driver and monitor. In addition, agents may contain an optional coverage collector component.

Agents need to be configurable to meet the requirements for a specific test. The controls for configuring UVM components are often referred to as **knobs**. These knobs might have simple on/off values or the knobs might be set to a value, such as the number of transactions a sequence should generate. In the [Advanced Agent](#advanced-agent)  we will talk more about passive and active agents and configuration objects, but in the meantime we will focus on creating an agent as basic as possible.

1. Create a `adder_agent.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory
   1. Add header guard.
   2. Create a class `adder_sequence_driver` that extends `uvm_driver` parameterized with the transaction `adder_sequence_items`.
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_component_utils(adder_driver)``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_component`.
   5. Declare two attributes
      - one to handle the `adder_sequencer` called `sqr`.
      - and other to handle the `adder_driver` called `drv`.
2. Create a `build_phase()` function and inside:
   1. Instantiate an `adder_sequencer` object called `sqr`using the UVM creation mechanism.
      - Translated into code: `sqr = adder_sequencer::type_id::create("sqr", this);`
   2. Instantiate an `adder_driver` object called `drv`using the UVM creation mechanism.
      - Translated into code: `drv = adder_driver   ::type_id::create("drv", this);`
3. Create a `connect_phase()` function and connect the driver and the sequencer.
   - Translated into code: `drv.seq_item_port.connect(sqr.seq_item_export);`
   - `seq_item_port` and `seq_item_export` are built-in into the `uvm_driver` and `uvm_sequencer` classes.

## Environment

A UVM environment encapsulates the structural aspects of a UVM testbench. A UVM environment contains:

- One or more agents, each of which handles driving DUT inputs and  monitoring DUT input and output activity on a specific DUT interface.
- A scoreboard, which handles verifying DUT responses to stimulus
- Optionally, a coverage collector, which records transaction information for coverage analysis, it can also be inside the agent.
- A configuration component, which allows the test to set up the environment and agent for specific test requirements.

1. Create a `top_env.sv` file in the `vrf/uvm/env` directory.
   1. Add header guard.
   2. Create a class `top_env` that extends `uvm_env`
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_component_utils(top_env) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a uvm_component.
2. Declare an attribute `adder_agent` called `adder_agt`
3. Create a `build_phase()` function and inside
   1. Instantiate an `adder_agent` object called `adder_agt` using the UVM creation mechanism.
      - Translated into code: `adder_agt = adder_agent::type_id::create("adder_agt", this):`

## Test

The UVM test has several responsibilities:

- Get the virtual interface handle(s) from the configuration database.
- Instantiate the UVM environment.
- Use the configuration database to pass the virtual interface handle(s) and other information down to the environment.
- Instantiate and start any sequences necessary for the test case.
- Manage phase objections, to ensure the test successfully completes.

1. Open `top_test.sv` and declare an attribute `top_env` called `env`.
2. Create a `build_phase()` function and inside
   1. Instantiate and `top_env` object called `env` using the UVM creation mechanism.
      - Translated to code: `env = top_env::type_id::create("env", this);`
3. Inside the `run_phase()` task after `phase.raise_objection(this)`:
   1. Open a `begin` block. ([**Note 10**](#note-10))
   2. Declare a local attribute `adder_sequence_base` called `seq`.
   3. Instantiate an `adder_sequence_base` called `seq` using the UVM creation mechanism.
      - Translated to code: `seq = adder_sequence_base::type_id::create("seq");`
   4. Call `seq.start(env.agt.sqr)`.
   5. Close the block with `end`.
4. Create a `end_of_elaboration_phase()` function and print the topology and the factory overrides. ([**Note 11**](#note-11))

## Package for Adder UVC

It is important to have all the files related to a single UVC inside a package.

1. Create a `adder_pkg.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory.
   1. Add header guard.
   2. Use `` `include "uvm_macro.svh" `` and `import uvm_pkg::*;`.
   3. Include:
      - `adder_sequence_item.sv`
      - `adder_sequencer.sv`
      - `adder_sequence_base.sv`
      - `adder_driver.sv`
      - `adder_agent.sv`

Sometimes, you may not know the order in which imports and includes are read. For this reason, you can include `uvm_macros.svh` and import `uvm_pkg::*` at the beginning of each package to ensure these files are called first and only once, thanks to header guards.

Do not include the interface in `adder_pkg.sv`, this is illegal in SystemVerilog.

## Package for Environment

1. Create a `top_env_pkg.sv` file `vrf/uvm/env` directory.
   1. Add header guard.
   2. Use `` `include "uvm_macro.svh" `` and `import uvm_pkg::*;`.
2. Import `adder_pkg::*` and include `"top_env.sv"`.

## The UVM Test/Driver/Sequence synchronization

This is the core of how it works, read carefully and try to understand each part. This is the key to understanding how transaction synchronization works.

1. The test class raises and objection flag `phase.raise_objection(this)` and call `seq.start()` method, which invokes the sequence `body()` task. The `seq.start()` method blocks (waits at that point) until the `body()` task exits.

2. The sequence `body()` task calls a `start_item()` method. `start_item()` blocks (waits) until the driver asks for a transaction (a sequence_item object handle).

3. The driver calls the `seq_item_port.get_next_item()` method and request (pull) a transaction. The driver then blocks (waits) until a transaction is received.

4. The sequence generates the transaction values and calls `finish_item()`, which sends the transaction to the driver. The sequence then blocks (waits) until the driver is finished with that transaction.

5. The driver assigns the transaction values to the interface variables, and then calls the `seq_item_port.item_done()` method to unblock the sequence. The sequence can then repeat steps 2 through 5 to generate additional stimulus.

6. After the sequence has completed generating stimulus, the sequence `body` exits, which unblocks the test's `start()` method. The test will then continue with its next statements, which includes dropping its objection flag and allowing the `run_phase` to end.

## Makefile configuration

The `Makefile` needs to be changed.

1. Use `+incdir+` to point to each directory that contains a file that was used in an include directive, update `INCL_FILES` variable.
2. Add the package in order of appearance, use a bottom to top approach, put first the files of lower hierarchy, update `PKG_FILES` variable.

## Last steps

At this point, the testbench can generate the UVM testbench hierarchy, create and start sequences from the `test_top`, pass transactions inside the sequence through the driver (handled by the sequencer), and display the transactions in the console. It may seem like a lot of work just to achieve this, but later you will learn how to leverage randomization and overrides to make your job easier. While this structure is difficult to create and understand initially, you can reuse most of the code for many other projects.

## Connect to the DUT

The final step is to connect the driver and the DUT. This is done using the SystemVerilog interface construct. You must make the
instance of the interface, referred to as a **virtual interface**, available to the environment. This is done by using the UVM configuration database.

1. Open `tb.sv`.
   1. Before the `run_test()` method use the UVM configuration database `set` method to define the virtual interface that the agent will use.
      1. Translated into code: `uvm_config_db #(virtual adder_if)::set(null, "uvm_test_top.env.adder_agt", "vif", vif);`. (**[Note 12](#note-12)**)
      2. `"uvm_test_top.env.adder_agt"` is the path where this configuration is available to be retrieve using the `get` version of the `uvm_config_db` method, also module below `adder_agt` have access to this configuration.
2. Open `adder_driver.sv`.
   1. Declare a `virtual adder_if` attribute called `vif`.
   2. Create a `build_phase()` function and inside:
   3. Use the UVM configuration database `get` method to retrieve the configuration for the virtual interface into `vif` and check for errors. (**[Note 12](#note-12)**)
   4. Inside the `run_phase()` before `seq_item_port.get_next_item(req);`.
   5. Assign the values of the `req` into the `vif` and add a small delay. It is a good practice to put this code into a separate task. (**[Note 13](#note-13)**)

The testbench is now capable of communicating with the DUT and sending stimuli correctly. However, a UVM testbench should do more than just send stimuli and display the generated waveforms for manual analysis. It must automatically analyze whether the DUT responses are correct. To achieve this, we first need to observe the output using a monitor. Then, we must determine how many possible combinations of inputs have been exercised in the DUT, which is done using coverage. Finally, we check if the output is correct using a scoreboard.

## Monitor

A UVM monitor observes the DUT inputs and outputs for a specific interface, captures the observed values into one or more sequence_items, and broadcasts handles to those sequence_items to other UVM components (such as a scoreboard and a coverage collector).

1. Create a `adder_monitor.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory.
   1. Add header guard.
   2. Create a class `adder_monitor` that extends `uvm_monitor`.
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_component_utils(adder_monitor) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_component`.
   5. Declare a `virtual adder_if` attribute called `vif`.
   6. Declare a `adder_sequence_item` attribute called `trans`.
   7. Declare a `uvm_analysis_port #(adder_sequence_item)` attribute called `analysis_port`. (**[Note 15](#note-15)**)
2. Create a `build_phase()` and inside:
   1. Use the UVM configuration database `get` method to retrieve the configuration for the virtual interface into `vif` and check for errors. (**[Note 12](#note-12)**)
   2. Instantiate `analysis_port` using the normal `new()` construct.
      - Translated into code: `analysis_port = new("analysis_port", this);`
      - This code can be also placed in the constructor after the `super.new(name, super);` call.
3. Create a `run_phase()` task and inside
   1. Instantiate an `adder_sequence_item` called `trans` using the UVM creation mechanism.
      - Translated into code: `trans = adder_sequence_item::type_id::create("trans");`
   2. Capture the values of `vif` into `trans` every time `vif.C` changes, you can use a `forever` loop, then call the `write()` method of the `analysis_port`. It is a good practice to put this code into a separate task. (**[Note 14](#note-14)**)
   3. Use `` `uvm_info() `` to display the capture values.
4. Open `adder_agent.sv`.
   1. Declare a `adder_monitor` attribute called `mon`.
   2. Inside the `build_phase()`.
   3. Instantiate an `adder_monitor` called `mon` using the UVM creation mechanism.
      - Translated into code: `mon = adder_monitor::type_id::create("mon", this);`.
5. Open `adder_driver.sv`
   1. Comment the `` `uvm_info() `` line.
6. Do not forget to include `adder_monitor.sv` in `adder_pkg.sv`

## Verdi support

1. Add `$fsdbDumpvars;` as the first line inside the `initial` block in the `tb.sv` file.
2. Make sure you have `-lca -debug_access+all+reverse -kdb +vcs+vcdpluson` in your `vcs` compilation flags.

## Advanced Agent

An agent may not require a driver and sequencer if its sole function is to monitor the DUT. In such cases, the agent is passive. When the agent performs other functions, it is active. You can manage this behavior using a configuration object.

1. Create a `adder_config.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory.
   1. Add header guard.
   2. Create a class `adder_config` that extends `uvm_object`
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_component_utils(adder_config) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_object`.
   5. Declare an attribute  `uvm_active_passive_enum` called `is_active` and assign it a value of `UVM_ACTIVE`.
   6. Declare an attribute  `bit` called `coverage_enable`.
2. Open `top_env.sv`.
   1. Declare an attribute  `adder_config` called `adder_agt_cfg`.
   2. Create a void function called `build_adder_agent()` and inside.
   3. Instantiate an `adder_config` called `adder_agt_cfg` using the UVM creation mechanism.
      - Translated into code: `adder_agt_cfg = adder_config::type_id::create("adder_agt_cfg", this);`
   4. Configure the parameters of `adder_agt_cfg` to make the agent active and enable the coverage.
   5. Use the UVM configuration database `set` method to register the configuration object.
      - Translated into code: `uvm_config_db #()::set(this, "adder_agt", "cfg", adder_agt_cfg);`
   6. Move the instantiation code of the adder agent to the `build_adder_agent()` function.
   7. Call the function `build_adder_agent()` inside the `build_phase()` function.
3. Open `adder_agent.sv`.
   1. Declare an attribute `adder_config` called `cfg`.
   2. Inside the `build_phase()` function:
   3. Use the UVM configuration database `get` method to retrieve the configuration for the configuration object  into `cfg` and check for errors. (**[Note 12](#note-12)**)
   4. Using an `if` statement check `cfg.is_active` and if true instantiate instantiate the driver and the sequencer.
   5. Inside the `connect_phase()` function:
   6. Using an `if` statement check `cfg.is_active` and if true to connect the driver to the sequencer.
4. Include `adder_config.sv` into `adder_pkg.sv`

## Coverage

Another useful feature for the agent is tracking how much of the design has been tested, known as coverage. Coverage measures the variety of input combinations that have been applied to the DUT.

1. Create a `adder_coverage.sv` file in the `vrf/uvm/uvcs/adder_uvc` directory.
   1. Add header guard.
   2. Create a class `adder_coverage` that extends `uvm_suscriber` parametrized with the transaction `adder_sequence_item`.
   3. Register this class in the factory using the appropriate macro, which in this case is `` `uvm_component_utils(adder_coverage) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_component`.
   5. Declare an attribute `adder_config` called `cfg`.
   6. Declare an attribute `adder_sequence_item` called `trans`.
   7. Declare an attribute `bit` called `is_covered`.

The important thing to know about the `uvm_suscriber` class is that it has a built-in analysis export for receiving transactions from a connected analysis port. To be more precise it has a `uvm_analysis_imp #(T, this_type) analysis_export;` that is instantiated `analysis_export = new("analysis_imp", this);` in the constructor. Making such a connection subscribes this component to any transactions emitted by the connected analysis port. The analysis port in the monitor calls a `write()` method to broadcast out a handle to a sequence_item. Each analysis imp export connected to the port must implement this `write()` method. (**[Note 15](#note-15)**)

The implementation of the `write()` function must copy the sequence_item handle passed from the monitor to the coverage collectors handle and then called the coverage `sample()` method to actually collect coverage information.

1. Create a `covergroup` called `adder_cov` that checks all the 256 by 256 combinations of `A` and `B` of the adder. (**[Note 16](#note-16)**)
2. Instantiate the `covergroup` using the `new()` keyword inside the constructor of the class.
3. Create a `build_phase()` and inside:
   1. Use the UVM configuration database `get` method to retrieve the configuration for the configuration object  into `cfg` and check for errors. (**[Note 12](#note-12)**)
4. Create a `write()` function with an input of type `adder_sequence_item` called `t`.
   1. Using an `if` statement check `cfg.coverage_enable` and if true assign the value of `t` into `trans` and call the `adder_cov.sample()` function.
5. Create a `report_phase()` and inside
   1. Using an `if` statement check `cfg.coverage_enable` and if true and display the coverage using the  `` `uvm_info() `` macro and the `adder.cov.get_coverage()` method.

6. Open `adder_agent.sv`.
   1. Declare an attribute `adder_coverage` called `cov`.
   2. In the `build_phase()`.
   3. Using an `if` statement check `cfg.coverage_enable` and if true instantiate an `adder_coverage` called `cov` using the UVM creation mechanism.
      - Translated into code: `cov = adder_coverage::type_id::create("cov",this);`
   4. In the `connect_phase()`.
   5. Using an `if` statement check `cfg.coverage_enable` and if true connect the monitor to the coverage.
      - Translated into code: `mon.analysis_port.connect(cov.analysis_export);`

## Scoreboard

The primary role of a scoreboard in UVM is to verify that actual DUT outputs match predicted output values, we can follow a similar implementation as the coreverage.

1. Create a `top_scoreboard.sv` file in the `vrf/uvm/env` directory
   1. Add header guard.
   2. Create a class `top_scoreboard` that extends `uvm_suscriber` parametrized with the transaction `adder_sequence_item`.
   3. Register this class in the factory with the proper macro, which in this case is `` `uvm_component_utils(top_scoreboard) ``.
   4. The factory requires a constructor. Create the appropriate constructor for a `uvm_component`.
   5. Declare an attribute `adder_sequence_item` called `trans`.
   6. Declare an attribute `int` called `num_passed` and another called `num_failed` initialize with zero.
2. Create a `write()` function with an input of type `adder_sequence_item` called `t`.
   1. Assign the value of `t` into `trans`.
      2. Using and `if` statement check if the information of the monitor transaction is correct and increase the `num_passed` and `num_failed` accordingly.
3. Create a `report_phase()` and inside.
   1. Displays the values of `num_passed` and `num_failed` using the `` `uvm() `` macro.
4. Open `top_env.sv`.
   1. Declare an attribute `top_scoreboard` called `scoreboard`.
   2. Inside the `build_phase()`.
   3. Instantiate an `top_scoreboard` called `scoreboard` using the UVM creation mechanism.
      - Translated into code: `scoreboard = top_scoreboard::type_id::create("scoreboard", this);`
   4. In the `connect_phase()`.
5. Connect the the scoreboard `analysis_export` to the `analysis_port`. There are two options.
   1. Connect the scoreboard `analysis_export` directly to the monitor `analysis_port`.
   2. Connect the scoreboard `analysis_export` to the agent pass-through  `analysis_port`.

You can directly connect the `analysis_export` to the monitor's `analysis_port`, but this is not recommended. Users of the agent may not be familiar with its internal workings. Instead, it is preferable to create a pass-through port from the monitor to the agent before connecting it to the scoreboard. This approach encapsulates the agent more effectively and simplifies the environment writer's task. The environment writer only needs to connect the agent port to the scoreboard, without needing to understand the agent's internal implementation.

 1. Inside `top_env.sv`.
    1. Create a `connect_phase()` function and inside
    2. Connect the agent `analysis_port` to the scoreboard `analysis_export`.
       - Translated into code: `adder_agt.analysis_port.connect(scoreboard analysis_export);`
 2. Open `adder_agent.sv`.
    1. Declare an attribute `uvm_analysis_port #(adder_sequence_item) analysis_port;`
    2. Instantiate the analysis port in the `build_phase()` function . (**[Note 15](#note-15)**)
    3. In the `connect_phase()` function connect the monitor analysis port and the agent analysis port
       1. Translated into code: `mon.analysis_port.connect(this.analysis_port);`
 3. Add `top_scoreboard.sv` into the `top_env_pkg.sv`

## Overrides

From the command line:

```bash
make PLUS=uvm_set_type_override=adder_sequence_base,adder_sequence_rand_no_repeat
```

From the test:

In the test `build_phase()` of `top_test.sv` or in a extended class, let say `test_feat` of `top_test` you can put this override:

```systemverilog
set_type_override_by_type( adder_sequence_base::get_type(), adder_sequence_directed::get_type() );`
```

and select the test in the Makefile

```
UVM_TESTNAME=test_feat
```

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

### Note 10

([**Test**](#test))

It is important to notice that it is necessary to surround the declaration and instantiation of `seq` and the call to `seq.start(env.adder_agt.sqr)` in a `begin`, `end` block. If you do not do it this way you will get an error.

An alternative to avoid using the `begin`, `end` block is to declare and attribute `adder_sequence_base` called `seq` outside the `run_phase()` task, next to  `top_env env;` or before calling `phase.raise_objection(this)`.

Do not put a `` `uvm_info() `` macro at the beginning of the `run_phase()` for some reason it creates an error when trying to execute code after. When I removed the macro the `begin` block was not necessary.  I put the macro as the second command and it also worked.

### Note 11

([**Test**](#test))

The object in UVM that read the `+UVM_TESTNAME` switch is the UVM execution manager `uvm_root` starts via `run_test()`. It makes use of the UVM factory to create a top test object from the class name provided.

This top test object is called `uvm_test_top`. The `uvm_test_top` object sits at the top of the entire UVM test hierarchy. It is the root parent of all the UVM test components.

Since the UVM execution manager is the creator of the object, it is also aware of the entire UVM component structural hierarchy from test on down.

The UVM execution manager is a singleton object of the `uvm_root` class. You can retrieve the handle to this manager by calling `uvm_root::get()`. You can use this handle to print the test structural topology.

It is also useful for debugging to see all the user classes registered in the UVM Factory. You can get this information by calling `uvm_factory::get().print()`.

Example:

```systemverilog
function void top_test::end_of_elaboration_phase(uvm_phase phase);
  uvm_root::get().print_topology();
  uvm_factory::get().print();
endfunction : end_of_elaboration_phase
```

### Note 12

([**Connect to the DUT**](#connect-to-the-dut)) - ([**Advanced Agent**](#advanced-agent))

The mechanism for configuring object properties is done using UVM Configuration Database

Syntax:

```systemverilog
uvm_config_db #(type)::set(context, inst_name, field, value);
```

- `type`: Data type
- `context`: Object context in which the setter resides
- `inst_name`: Hierarchical instance name in context
- `field`: Tag to set value
- `value`: Value to set

```systemverilog
uvm_config_db #(type)::get(context, inst_name, field, value);
```

- `type`: Data type (Must match set)
- `context`: Object context in which the target resides
- `inst_name`: Hierarchical instance name in context
- `field`: Tag to get value
- `value`: Value to store value unchanged if not set

Example:

```systemverilog
// in tb.sv
uvm_config_db #(virtual adder_if)::set(null, "uvm_test_top.env.adder_agt", "vif", vif);

// in adder_driver.sv inside the build_phase
if ( !uvm_config_db #(virtual adder_if)::get(get_parent(), "", "vif", vif) ) begin
  `uvm_fatal(get_name(), "Could not retrieve adder_if from config db")
end
```

Example:

```systemverilog
// in top_env.sv build_phase
uvm_config_db #(adder_config)::set(this, "adder_agt", "cfg", adder_agt_cfg);

// in adder_agent.sv inside the build_phae
if ( !uvm_config_db #(adder_config)::get(this, "", "cfg", cfg) ) begin
      `uvm_fatal(get_name(), "Could not retrieve adder_config from config db")
end
```

If  `context` is `null` the `inst_name` must contain the full path.

### Note 13

This is the simplest code that a driver can have, directly assign the values of the transaction into the DUT I/O pins.

([**Connect to the DUT**](#connect-to-the-dut))

```systemverilog
task adder_driver::do_drive();
  vif.A <= req.A;
  vif.B <= req.B;
  #10;
endtask : do_drive
```

### Note 14

([**Monitor**](#monitor))

This is the simplest code that a monitor can have, directly assign the values of the transaction into the DUT I/O pins.

```systemverilog
task adder_monitor::do_mon();
  forever @(vif.C) begin
    trans.A = vif.A;
    trans.B = vif.B;
    trans.C = vif.C;
    analysis_port.write(trans);
    //`uvm_info(get_type_name(), $sformatf("A = %4d, B = %4d, C =  %4d", vif.A, vif.B, vif.C), UVM_MEDIUM)
  end
endtask : do_mon
```

## Note 15

([**Monitor**](#monitor)) - ([**Coverage**](#coverage)) - ([**Scoreboard**](#scoreboard))

These ports are TLM analysis ports, which permit a one-to-many connection. This allows the handle to the sequence_item object containing the DUT input values to be passed to both the scoreboard and a coverage collector. The `uvm_analysis_port` is a parameterized class, which must be specialized to work with a specific sequence_item class type.

The ports are constructed in the `build_phase()` of the monitor. Note that ports are constructed using the class
`new()` constructor, instead of the factory.

Each of these analysis imp exports must implement the `write()` method for its corresponding port.

Example:

```systemverilog
uvm_analysis_port #(adder_sequence_item) analysis_port;
// inside the build_phase
analysis_port = new("analysis_port", this);

uvm_analysis_imp #(adder_sequence_item) analysis_export;
// inside the build_phase
analysis_export = new("analysis_imp", this);
```

If multiple `uvm_analysis_imp` in the same class are need it, because SystemVerilog language does not have function overloading, it can not differentiate from one `write()` function to the other. To solve this problem UVM provides a solution to this dilemma in the form of a macro called `` `uvm_analysis_imp_decl() ``.

```systemverilog
`uvm_analysis_imp_decl(_uvc1)
uvm_analysis_imp_uvc1 #(adder_sequence_item, this) analysis_export_uvc1;
// inside the build_phase
analysis_export_uvc1 = new("analysis_export_uvc1", this);

`uvm_analysis_imp_decl(_uvc2)
uvm_analysis_imp_uvc1 #(adder_sequence_item, this) analysis_export_uvc2;
// inside the build_phase
analysis_export_uvc2 = new("analysis_export_uvc2", this);

```

## Note 16

 ([**Coverage**](#coverage))

Coverage group for adder.

Example:

```systemverilog
covergroup adder_cov;
   //option.per_instance = 1;
   cp_A: coverpoint trans.A {
   bins a_bins[] = { [0:255] };
   }
   cp_B: coverpoint trans.B {
   bins b_bins[] = { [0:255] };
   }
   cp_cross: cross cp_A, cp_B;
endgroup
```

## Note 17

When using `+ntb_random_seed_automatic` the seed appears in both the simulation log and the coverage report.

## References

- [1] UVM Cookbook | Cookbook | Siemens Verification Academy, Verification Academy. Accessed: Jun. 03, 2024. [Online]. Available: <https://verificationacademy.com/cookbook/uvm-universal-verification-methodology/>

- [2] S. Sutherland and T. Fitzpatrick, "UVM Rapid Adoption: A Practical Subset of UVM," in Proc. Design and Verification Conference (DVCon), March 2015. Available: <https://dvcon-proceedings.org/wp-content/uploads/uvm-rapid-adoption-a-practical-subset-of-uvm-paper.pdf>

- [3] (IEEE Std 1800-2017) - IEEE Standard for SystemVerilog--Unified Hardware Design, Specification, and Verification Language. IEEE. doi: 10.1109/IEEESTD.2018.8299595. [Online]. Available: <https://ieeexplore.ieee.org/document/8299595>

- [4] ClueLogic - Providing the clues to solve your verification problems. Accessed: Jun. 03, 2024. [Online]. Available: <https://cluelogic.com/>

- [5] “Easier UVM.” Accessed: Jun. 04, 2024. [Online]. Available: <https://www.doulos.com/knowhow/systemverilog/uvm/easier-uvm/>

- [6] “UVM (Universal Verification Methodology).” Accessed: Jun. 04, 2024. [Online]. Available: <https://www.accellera.org/downloads/standards/uvm>
