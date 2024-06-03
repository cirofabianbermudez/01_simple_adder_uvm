TEST ?= top_test
VERBOSITY ?= UVM_MEDIUM
SEED ?= 1
RUN_DIR ?= work
PLUS ?=

ROOT_DIR = $(CURDIR)
RDIR = $(abspath $(RUN_DIR))

INCL_FILES = +incdir+$(ROOT_DIR)/vrf/uvm \
						 +incdir+$(ROOT_DIR)/vrf/uvm/test \
						 +incdir+$(ROOT_DIR)/vrf/uvm/env \
						 +incdir+$(ROOT_DIR)/vrf/uvm/uvcs/adder_uvc \
						 +incdir+$(ROOT_DIR)/vrf/uvm/tb

INTER_FILES = $(ROOT_DIR)/vrf/uvm/uvcs/adder_uvc/adder_if.sv

RTL_FILES = $(ROOT_DIR)/rtl/adder.sv

PKG_FILES = $(ROOT_DIR)/vrf/uvm/uvcs/adder_uvc/adder_pkg.sv \
						$(ROOT_DIR)/vrf/uvm/env/top_env_pkg.sv \
						$(ROOT_DIR)/vrf/uvm/test/top_test_pkg.sv

TEST_FILES = $(ROOT_DIR)/vrf/uvm/tb/tb.sv

FILES = $(INCL_FILES) $(INTER_FILES) $(RTL_FILES) $(PKG_FILES) $(TEST_FILES)

VCS = vcs -full64 -sverilog -ntb_opts uvm-1.2 \
			-lca -debug_access+all+reverse -kdb +vcs+vcdpluson \
			-timescale=1ns/100ps $(FILES) -l comp.log

SIM_OPTS = +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) -l simv.log \
					 +UVM_TR_RECORD +UVM_LOG_RECORD +UVM_NO_RELNOTES \
					 +$(PLUS)

+ntb_random_seed=${SEED}

.PHONY: version compile sim random clean help

all: compile random

version:
	vcs -ID

compile:
	@mkdir -p $(RDIR)/sim 
	cd $(RDIR)/sim && $(VCS)

sim:
	cd $(RDIR)/sim && ./simv +ntb_random_seed=${SEED} $(SIM_OPTS)

random:
	cd $(RDIR)/sim && ./simv +ntb_random_seed_automatic $(SIM_OPTS)

verdi:
	cd $(RDIR)/sim && verdi -dbdir ./simv.daidir -ssf ./novas.fsdb -nologo &

coverage:
	cd $(RDIR)/sim && urg -dir simv.vdb && urg -dir simv.vdb -format text

clean:
	rm -rf $(RDIR)

help:
	@echo ""
	@echo "=================================================================="
	@echo ""
	@echo "---------------------------- Targets -----------------------------"
	@echo "  all                 : Runs compilation and simulation"
	@echo "  compile             : Runs compilation"
	@echo "  sim                 : Runs simulation using SEED"
	@echo "  random              : Runs simulation using a random seed"
	@echo "  verdi               : Opens Verdi GUI"
	@echo "  coverage            : Generate coverage reports"
	@echo "  clean               : Removes all simulation files"
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
	@echo "  PLUS                : "
	@echo ""
	@echo "=================================================================="
	@echo ""
