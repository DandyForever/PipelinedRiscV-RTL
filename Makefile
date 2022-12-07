MODULE_DIR := $(shell pwd)
RTL_DIR := $(MODULE_DIR)/rtl
STAGE_DIR := $(RTL_DIR)/stages
LATCH_DIR := $(RTL_DIR)/latches
COMP_DIR := $(RTL_DIR)/components

CPU_TOP = $(RTL_DIR)/cpu.sv

LATCH    = $(COMP_DIR)/latch.sv
ALU      = $(COMP_DIR)/alu.sv
REG_FILE = $(COMP_DIR)/reg_file.sv
CONTROL  = $(COMP_DIR)/control.sv
SIGN_EXT = $(COMP_DIR)/sign_ext.sv
ROM      = $(COMP_DIR)/rom.sv
RAM      = $(COMP_DIR)/ram.sv
COMPS    = $(LATCH) + $(ALU) + $(REG_FILE) + $(CONTROL) + $(ROM) + $(RAM) + $(SIGN_EXT)

FETCH     = $(STAGE_DIR)/fetch.sv
DECODE    = $(STAGE_DIR)/decode.sv
EXECUTE   = $(STAGE_DIR)/execute.sv
MEMORY    = $(STAGE_DIR)/memory.sv
WRITEBACK = $(STAGE_DIR)/writeback.sv
STAGES    = $(FETCH) + $(DECODE) + $(EXECUTE) + $(MEMORY) + $(WRITEBACK)

CPU_TB = $(MODULE_DIR)/tb/testbench.sv

SRC = $(CPU_TB) + $(CPU_TOP) + $(COMPS) + $(STAGES)

cpu:
	cd $(MODULE_DIR)/sim && rm -rf cpu && mkdir cpu
	cd $(MODULE_DIR)/sim/cpu && xrun -64bit -sv -access +rwc \
		-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/sim/cpu/cpu.log && vim $(MODULE_DIR)/sim/cpu/cpu.log

cpu_gui:
	cd $(MODULE_DIR)/sim && rm -rf cpu && mkdir cpu
	cd $(MODULE_DIR)/sim/cpu && xrun -64bit -sv -access +rwc \
		-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/sim && rm -rf ./*
