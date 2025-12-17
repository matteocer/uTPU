SIM = iverilog
SIMFLAGS = -g2012
OUT = sim.out

VVP = vvp

RTL_SRCS := $(shell find rtl -type d)
SIM_SRCS  := $(shell find sim -type d)


build:
	$(SIM) $(SIMFLAGS) -o $(OUT) $(RTL_SRCS) $(SIM_SRCS)
