

## Interfaces

(IEEE Std 1800-2017 - page 49)

- The interface construct, enclosed between the keywords `interface...endinterface`, encapsulates the communication between design blocks, and between design and verification blocks.

- At its lowest level, an interface is a named bundle of nets or variables. The interface is instantiated in a design and can be connected to interface ports of other instantiated modules, interfaces and programs. 

- To provide direction information for module ports and to control the use of subroutines within particular modules, the `modport` construct is provided. As the name indicates, the directions are those seen from the module.


Summary: Use it to declare the signals of the design and pass the clock as an argument if necessary. The signals does not have directions and are asyncronous by default. It is useful to encapsulate the communication.


## Modport block

(IEEE Std 1800-2017 - page 754)

- To restrict interface access within a module, there are `modport` lists with directions declared within the interface. The keyword `modport` indicates that the directions are declared as if inside the module.

- The `modport` construct can also be used to specify the direction of `clocking` blocks declared within an interface. As with other `modport` declarations, the directions of the `clocking` block are those seen from the module in which the interface becomes a port.


Summary: Use it to give direction to the signals of the interface. From the point of view the interface, an input of the DUT is an output of the interface and an output of the DUT is an input of the interface. You can put `clocking` blocks inside a `modport` and repeat signals that are inside the `clocking` block to have both access to syncronous and asyncronous behavior.


## Clocking blocks

(IEEE Std 1800-2017 - page 336)

- The clocking block construct identifies clock signals and captures the timing and synchronization requirements of the blocks being modeled. A clocking block is defined between the keywords `clocking` and `endclocking`.

- A clocking block assembles signals that are synchronous to a particular clock and makes their timing explicit. The clocking block is a key element in a cycle-based methodology, which enables users to write testbenches at a higher level of abstraction.  Rather than focusing on signals and transitions in time, the test can be defined in terms of cycles and transactions. Depending on the environment, a testbench can contain one or more clocking blocks, each containing its own clock plus an arbitrary number of signals.

- The clocking block separates the timing and synchronization details from the structural, functional, and procedural elements of a testbench. Thus, the timing for sampling and driving clocking block signals is implicit and relative to the clocking blocks clock. This enables a set of key operations to be written very succinctly, without explicitly using clocks or specifying timing. These operations are as follows:
    - Synchronous events
    - Input sampling
    - Synchronous drives


Summary: Use it to give syncronous behaviour to the interface. Use `@(posedge clk)` when declaring the `clocking` block. From the point of view the interface, an input of the DUT is an output of the interface and an output of the DUT is an input of the interface. Use `default input #1ns output #0ns` to define the input and output skew. If the clock edge occurs at to, then input skew specify the amount of time before the edge of the clock that the value of the signal sample (to - input_skew), the output skew specify the amout of time after the edge of the clock that the value of the signal is driven (to + output_skew). You can pass the `clocking` block to a `modport`.


## Constraint blocks

(IEEE Std 1800-2017 - page 503)

- Constraint-driven test generation allows users to automatically generate tests for functional verification. Random testing can be more effective than a traditional, directed testing approach. By specifying constraints, one can easily create tests that can find hard-to-reach corner cases. SystemVerilog allows users to specify constraints in a compact, declarative way. The constraints are then processed by a solver that generates random values that meet the constraints.

- The random constraints are typically specified on top of an object-oriented data abstraction that models the data to be randomized as objects that contain random variables and user-defined constraints. The constraints determine the legal values that can be assigned to the random variables. Objects are ideal for representing complex aggregate data types and protocols such as Ethernet packets.

- Constraint blocks and covergroups shall not be declared in interface classes.

- Constraint programming is a powerful method that lets users build generic, reusable objects that can later be extended or constrained to perform specific functions. 

Examples:

```systemverilog
class Bus;
    rand bit[15:0] addr;
    rand bit[31:0] data;

    constraint word_align {addr[1:0] == 2'b0;}
endclass
```


```systemverilog
typedef enum {low, mid, high} AddrType;
class MyBus extends Bus;
    rand AddrType atype; 
    constraint addr_range {
        (atype == low ) -> addr inside { [0 : 15] };
        (atype == mid ) -> addr inside { [16 : 127]};
        (atype == high) -> addr inside {[128 : 255]};
    }
endclass
```


Objects can be further constrained using the randomize() with construct, which declares additional constraints in-line with the call to randomize():

```systemverilog
task exercise_bus (MyBus bus);
    int res;

    // EXAMPLE 1: restrict to low addresses
    res = bus.randomize() with {atype == low;};

    // EXAMPLE 2: restrict to address between 10 and 20
    res = bus.randomize() with {10 <= addr && addr <= 20;};

    // EXAMPLE 3: restrict data values to powers-of-two
    res = bus.randomize() with {(data & (data - 1)) == 0;};
endtask
```


## Functional Coverage


(IEEE Std 1800-2017 - page 553)


- Coverage is defined as the percentage of verification objectives that have been met. It is used as a metric for evaluating the progress of a verification project in order to reduce the number of simulation cycles spent in verifying a design.

- Broadly speaking, there are two types of coverage metrics: those that can be automatically extracted from the design code, such as code coverage, and those that are user-specified in order to tie the verification environment to the design intent or functionality. The latter form is referred to as functional coverage.

- Functional coverage is a user-defined metric that measures how much of the design specification, as enumerated by features in the test plan, has been exercised. It can be used to measure whether interesting scenarios, corner cases, specification invariants, or other applicable design conditions?captured as features of the test plan?have been observed, validated, and tested.

- The key aspects of functional coverage are as follows:
    - It is user-specified and is not automatically inferred from the design.
    - It is based on the design specification (i.e., its intent) and is thus independent of the actual design code or its structure


- Create a `covergroup`
- Covergroup encapsulates
    - Coverage bins definitions, State, Transition, Cross correlation
    - Coverage bins sample timing definition
    - Coverage attributes e.g. coverage goal

