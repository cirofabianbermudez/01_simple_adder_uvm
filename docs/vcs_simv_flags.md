

# VCS Flags

| Flag                   | Description                                                                                                                                                                                                                                                             |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-full64`              | Enables compilation and simulation in 64-bit mode.                                                                                                                                                                                                                      |
| `-sverilog`            | Enables the analysis of SystemVerilog source code.                                                                                                                                                                                                                      |
| `-ntb_opts uvm-1.2`    | Load UVM-1.2                                                                                                                                                                                                                                                            |
| `-lca`                 | Enable Limited Customer Availability (LCA) features.                                                                                                                                                                                                                    |
| `-debug_access+all`    | Compiling/Elaborating the Design in the Full Debug Mode.                                                                                                                                                                                                                |
| `-kdb`                 | Enables generating Verdi Knowledge Database (KDB).                                                                                                                                                                                                                      |
| `+vcs+vcdpluson`       | Specifying a VCD file. A compile-time substitute for `$vcdpluson` option system task. This switch enables dumping for the entire design.                                                                                                                                |
| `-timescale=1ns/100ps` | If only some source files contain the `` `timescale `` compiler directive and the ones that don't appear first on the vcs command line, use this option to specify the time scale for these source files. Fist argument is the time units and the second the precision. |
| `-l comp.log`          | Specifies a log file for VCS compilation messages.                                                                                                                                                                                                                      |
| `+incdir+<directory>`  | Specifies the directory or directories that VCS searches for include files used in the`` `include `` compiler directive.                                                                                                                                                |
| `-f <filename>`        | Specifies a file that contains a list of pathnames to source files and compile-time. options.                                                                                                                                                                           |
| `-F <filename>`        | Same as the `-f` option but allows you to specify a path to the file and the source files listed in the file do not have to be absolute pathnames.                                                                                                                      |

Example:

```bash
 vcs -full64 -sverilog -ntb_opts uvm-1.2 \
     -lca -debug_access+all+reverse -kdb +vcs+vcdpluson \
     -timescale=1ns/100ps +incdir+include test.sv -l comp.log
```

# SIMV Flags

| Flag                         | Description                                                                                                                                                                                                            |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-l sim.log`                 | Specifies a log file for VCS compilation messages.                                                                                                                                                                     |
| `+UVM_TESTNAME=base_test`    | Select the test that is run inside `run_test()`.                                                                                                                                                                       |
| `+UVM_VERBOSITY=UVM_MEDIUM`  | Specifies the verbosity level `UVM_MEDIUM` is the default.                                                                                                                                                             |
| `+ntb_random_seed=1`         | Sets the seed value to be used by the top-level random number generator at the start of simulation. The value can be any integer. The default random seed value is 1.                                                  |
| `+ntb_random_seed_automatic` | Picks a unique value to supply as the first seed used by a testbench. The value is etermined by combining the time of day, host name and process id. This ensures that no two simulations have the same starting seed. |
| `+UVM_TR_RECORD`             | This flag enables transaction recording in UVM. Transaction recording allows you to capture information about transactions that occur within your design during simulation                                             |
| `+UVM_LOG_RECORD`            | This flag enables logging in UVM. Logging allows you to capture messages, warnings, errors, and other relevant information generated by components in your UVM testbench during simulation.                            |
| `+UVM_NO_RELNOTES`           | Disable release notes message.                                                                                                                                                                                         |

Example:


```bash
./simv +UVM_TESTNAME=base_test +UVM_VERBOSITY=UVM_MEDIUM -l simv.log \
       +ntb_random_seed=1 +UVM_TR_RECORD +UVM_LOG_RECORD +UVM_NO_RELNOTES
```
