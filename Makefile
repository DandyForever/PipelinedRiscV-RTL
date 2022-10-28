MODULE_DIR := $(shell pwd)
RTL_DIR := $(MODULE_DIR)/rtl
STAGE_DIR := $(RTL_DIR)/stages
LATCH_DIR := $(RTL_DIR)/latches
COMP_DIR := $(RTL_DIR)/components

CPU_TOP = $(RTL_DIR)/cpu.v

ALU      = $(COMP_DIR)/alu.v
REG_FILE = $(COMP_DIR)/reg_file.v
CONTROL  = $(COMP_DIR)/control.v
SIGN_EXT = $(COMP_DIR)/sign_ext.v
ROM      = $(COMP_DIR)/rom.v
RAM      = $(COMP_DIR)/ram.v
COMPS    = $(ALU) + $(REG_FILE) + $(CONTROL) + $(ROM) + $(RAM) + $(SIGN_EXT)

FETCH     = $(STAGE_DIR)/fetch.v
DECODE    = $(STAGE_DIR)/decode.v
EXECUTE   = $(STAGE_DIR)/execute.v
MEMORY    = $(STAGE_DIR)/memory.v
WRITEBACK = $(STAGE_DIR)/writeback.v
STAGES    = $(FETCH) + $(DECODE) + $(EXECUTE) + $(MEMORY) + $(WRITEBACK)

FD_LATCH = $(LATCH_DIR)/fd.v
DE_LATCH = $(LATCH_DIR)/de.v
EM_LATCH = $(LATCH_DIR)/em.v
MW_LATCH = $(LATCH_DIR)/mw.v
LATCHES  = $(FD_LATCH) + $(DE_LATCH) + $(EM_LATCH) + $(MW_LATCH)

CPU_TB = $(MODULE_DIR)/tb/testbench.v

SRC = $(CPU_TB) + $(CPU_TOP) + $(COMPS) + $(STAGES) + $(LATCHES)

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
