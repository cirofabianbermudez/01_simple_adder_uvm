TEST ?= top_test
VERBOSITY ?= UVM_MEDIUM
SEED ?= 1
RUN_DIR ?= work
PLUS ?=

ROOT_DIR = $(CURDIR)
RDIR = $(abspath $(RUN_DIR))

INCL_FILES = +incdir+$(ROOT_DIR)/vrf/uvm \
						 +incdir+$(ROOT_DIR)/vrf/uvm/test

RTL_FILES = $(ROOT_DIR)/rtl/adder_if.sv \
						$(ROOT_DIR)/rtl/adder.sv

PKG_FILES = $(ROOT_DIR)/vrf/uvm/test/top_test_pkg.sv

TEST_FILES = $(ROOT_DIR)/vrf/uvm/tb/tb.sv

FILES = $(INCL_FILES) $(RTL_FILES) $(PKG_FILES) $(TEST_FILES)

VCS = vcs -full64 -sverilog -ntb_opts uvm-1.2 \
			-lca -debug_access+all+reverse -kdb +vcs+vcdpluson \
			-timescale=1ns/100ps $(FILES) -l comp.log

SIM_OPTS = +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) -l simv.log \
					 +UVM_TR_RECORD +UVM_LOG_RECORD +UVM_NO_RELNOTES \
					 +$(PLUS)

+ntb_random_seed=${SEED}

.PHONY: version compile sim random clean help

all: compile sim

version:
	vcs -ID

compile:
	@mkdir -p $(RDIR)/sim 
	cd $(RDIR)/sim && $(VCS)

sim:
	cd $(RDIR)/sim && ./simv +ntb_random_seed=${SEED} $(SIM_OPTS)

random:
	cd $(RDIR)/sim && ./simv +ntb_random_seed_automatic $(SIM_OPTS)

clean:
	rm -rf $(RDIR)

help:
	@echo ""
	@echo "=================================================================="
	@echo ""
	@echo "---------------------------- Targets -----------------------------"
	@echo "  all                 : Runs compilation and simulation"
	@echo "  compile             : Runs compilation"
	@echo "  sim                 : Runs simulation"
	@echo "  clean               : Removes the work directory"
	@echo ""
	@echo "--------------------------- Variables ----------------------------"
	@echo "  TEST                : Name of UVM_TEST"
	@echo "  VERBOSITY           : UVM_VERBOSITY of the simulation"
	@echo "  SEED                : Random seed used, must be an integer > 0"
	@echo "  PLUS                : Add extra flags in simv command"
	@echo ""
	@echo "--------------------------- Defaults -----------------------------"
	@echo "  TEST                : $(TEST)"
	@echo "  VERBOSITY           : UVM_MEDIUM"
	@echo "  SEED                : 1"
	@echo ""
	@echo "=================================================================="
	@echo ""
