
SHELL := /bin/bash

.ONESHELL:

XVLOG ?= xvlog
XELAB ?= xelab
XSIM  ?= xsim

SIM_OUT ?= build/sim

# Absolute include dirs (so `include works after cd)
INCDIRS := -i $(CURDIR)/rtl/PEArray -i $(CURDIR)/generated

# Absolute sources
PEARRAY_RTL := $(CURDIR)/rtl/PEArray/pe.sv $(CURDIR)/rtl/PEArray/pe_array.sv
PEARRAY_TB  := $(CURDIR)/sim/PEArray/pe_array_tb2.sv

TOP ?= pe_array_tb2

.PHONY: sim-pearray clean-sim

sim-pearray:
	mkdir -p $(SIM_OUT)
	cd $(SIM_OUT) && \
	$(XVLOG) -sv $(INCDIRS) $(PEARRAY_RTL) $(PEARRAY_TB) && \
	$(XELAB) $(TOP) -debug typical && \
	$(XSIM) $(TOP) -runall

clean-sim:
	rm -rf $(SIM_OUT)
