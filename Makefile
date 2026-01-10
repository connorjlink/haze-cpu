GHDL    ?= ghdl
STD     ?= 08
WORK    ?= work

ANALYZE := $(GHDL) -a --work=$(WORK) --std=$(STD)
RUN     := $(GHDL) --elab-run --std=$(STD)

AS      := riscv64-unknown-elf-as
ASFLAGS := -march=rv32i -mabi=ilp32

LD      := riscv64-unknown-elf-ld
OBJCOPY := riscv64-unknown-elf-objcopy

RARS     := java -jar C:\rars.jar
RARS_NC  ?= nc
RARS_HEX ?= HexText

# GHDL's library index file for VHDL-2008
WORK_CF  := work-obj08.cf

ifeq ($(OS),Windows_NT)
    IS_WINDOWS := 1
else
    IS_WINDOWS := 0
endif

ifeq ($(IS_WINDOWS),1)
    define RM
powershell -NoProfile -Command "Remove-Item '$(1)' -Force -ErrorAction SilentlyContinue"
    endef
else
    define RM
rm -f $(1)
    endef
endif

ifeq ($(IS_WINDOWS),1)
    define TOUCH
powershell -NoProfile -Command "New-Item -ItemType File -Path '$(1)' -Force | Out-Null"
    endef
else
    define TOUCH
touch $(1)
    endef
endif


SOURCE := \
	./source/types.vhd \
	./source/not_1.vhd ./source/not_N.vhd ./source/and_2.vhd ./source/or_2.vhd ./source/xor_2.vhd \
	./source/multiplexer_2to1.vhd ./source/multiplexer_2to1_N.vhd ./source/multiplexer_32to1.vhd \
	./source/register_1.vhd ./source/register_N.vhd \
	./source/decoder_5to32.vhd \
	./source/adder_1.vhd \
	./source/adder_N.vhd \
	./source/addersubtractor_N.vhd \
	./source/barrel_shifter.vhd \
	./source/instruction_decoder.vhd \
	./source/instruction_pointer.vhd \
	./source/register_file.vhd \
	./source/memory.vhd \
	./source/extender_NtoM.vhd \
	./source/arithmetic_logic_unit.vhd \
	./source/pipeline_register.vhd ./source/register_IF.vhd ./source/register_ID.vhd ./source/register_EX.vhd ./source/register_MEM.vhd ./source/register_WB.vhd \
	./source/control_unit.vhd \
	./source/branch_unit.vhd \
	./source/multiplier.vhd \
	./source/forwarding_unit.vhd \
	./source/hazard_unit.vhd \
	./source/processor.vhd

ASSEMBLY_DIR := ./riscv
BINARY_DIR   := ./binary

ASSEMBLY  := $(wildcard $(ASSEMBLY_DIR)/*.s)
IHEXFILES := $(patsubst $(ASSEMBLY_DIR)/%.s,$(BINARY_DIR)/%_i.hex,$(ASSEMBLY))
DHEXFILES := $(patsubst $(ASSEMBLY_DIR)/%.s,$(BINARY_DIR)/%_d.hex,$(ASSEMBLY))

$(BINARY_DIR):
	mkdir $(BINARY_DIR)

.PHONY: setup verify tests hex \
	test_barrel_shifter test_adder_1 test_adder_N test_addersubtractor_N test_arithmetic_logic_unit test_branch_unit test_not_N test_decoder_5to32 test_instruction_decoder test_register_1 test_register_N test_memory test_extender test_instruction_pointer test_multiplexer_32to1 test_multiplexer_2to1_N test_multiplexer_2to1 test_multiplier test_register_file test_control_unit test_processor

# suppress "Entering/Leaving directory"
# MAKEFLAGS += --no-print-directory

setup: $(WORK_CF)

assemble: $(OBJECTS)

$(OBJECTS_DIR)/%.o: $(ASSEMBLY_DIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<

hex: $(IHEXFILES) $(DHEXFILES)

$(BINARY_DIR)/%_i.hex: $(ASSEMBLY_DIR)/%.s | $(BINARY_DIR)
	$(RARS) $(RARS_NC) a dump .text $(RARS_HEX) $@ $<

$(BINARY_DIR)/%_d.hex: $(ASSEMBLY_DIR)/%.s | $(BINARY_DIR)
	$(call TOUCH,$@)
	$(RARS) $(RARS_NC) a dump .data $(RARS_HEX) $@ $<


clean:
	$(call RM,binary/*_i.hex)
	$(call RM,binary/*_d.hex)
	$(call RM,binary/*.o)
	$(call RM,work-obj08.cf)


# Re-analyze the whole design if any source changes
$(WORK_CF): $(SOURCE)
	$(ANALYZE) $(SOURCE)

tests: test_barrel_shifter test_adder_1 test_adder_N test_addersubtractor_N test_arithmetic_logic_unit test_branch_unit test_not_N test_decoder_5to32 test_instruction_decoder test_register_1 test_register_N test_memory test_extender test_instruction_pointer test_multiplexer_32to1 test_multiplexer_2to1_N test_multiplexer_2to1 test_multiplier test_register_file test_control_unit test_processor

verify: setup tests

test_barrel_shifter: setup ./test/tb_barrel_shifter.vhd
	$(ANALYZE) ./test/tb_barrel_shifter.vhd
	$(RUN) tb_barrel_shifter

test_adder_1: setup ./test/tb_adder_1.vhd
	$(ANALYZE) ./test/tb_adder_1.vhd
	$(RUN) tb_adder_1

test_adder_N: setup ./test/tb_adder_N.vhd
	$(ANALYZE) ./test/tb_adder_N.vhd
	$(RUN) tb_adder_N

test_addersubtractor_N: setup ./test/tb_addersubtractor_N.vhd
	$(ANALYZE) ./test/tb_addersubtractor_N.vhd
	$(RUN) tb_addersubtractor_N

test_arithmetic_logic_unit: setup ./test/tb_arithmetic_logic_unit.vhd
	$(ANALYZE) ./test/tb_arithmetic_logic_unit.vhd
	$(RUN) tb_arithmetic_logic_unit

test_branch_unit: setup ./test/tb_branch_unit.vhd
	$(ANALYZE) ./test/tb_branch_unit.vhd
	$(RUN) tb_branch_unit

test_not_N: setup ./test/tb_not_N.vhd
	$(ANALYZE) ./test/tb_not_N.vhd
	$(RUN) tb_not_N

test_decoder_5to32: setup ./test/tb_decoder_5to32.vhd
	$(ANALYZE) ./test/tb_decoder_5to32.vhd
	$(RUN) tb_decoder_5to32

test_instruction_decoder: setup ./test/tb_instruction_decoder.vhd
	$(ANALYZE) ./test/tb_instruction_decoder.vhd
	$(RUN) tb_instruction_decoder

test_register_1: setup ./test/tb_register_1.vhd
	$(ANALYZE) ./test/tb_register_1.vhd
	$(RUN) tb_register_1

test_register_N: setup ./test/tb_register_N.vhd
	$(ANALYZE) ./test/tb_register_N.vhd
	$(RUN) tb_register_N

test_memory: setup ./test/tb_memory.vhd
	$(ANALYZE) ./test/tb_memory.vhd
	$(RUN) tb_memory

test_extender: setup ./test/tb_extender_NtoM.vhd
	$(ANALYZE) ./test/tb_extender_NtoM.vhd
	$(RUN) tb_extender_NtoM

test_instruction_pointer: setup ./test/tb_instruction_pointer.vhd
	$(ANALYZE) ./test/tb_instruction_pointer.vhd
	$(RUN) tb_instruction_pointer

test_multiplexer_32to1: setup ./test/tb_multiplexer_32to1.vhd
	$(ANALYZE) ./test/tb_multiplexer_32to1.vhd
	$(RUN) tb_multiplexer_32to1

test_multiplexer_2to1_N: setup ./test/tb_multiplexer_2to1_N.vhd
	$(ANALYZE) ./test/tb_multiplexer_2to1_N.vhd
	$(RUN) tb_multiplexer_2to1_N

test_multiplexer_2to1: setup ./test/tb_multiplexer_2to1.vhd
	$(ANALYZE) ./test/tb_multiplexer_2to1.vhd
	$(RUN) tb_multiplexer_2to1

test_multiplier: setup ./test/tb_multiplier.vhd
	$(ANALYZE) ./test/tb_multiplier.vhd
	$(RUN) tb_multiplier

test_register_file: setup ./test/tb_register_file.vhd
	$(ANALYZE) ./test/tb_register_file.vhd
	$(RUN) tb_register_file

test_control_unit: setup ./test/tb_control_unit.vhd
	$(ANALYZE) ./test/tb_control_unit.vhd
	$(RUN) tb_control_unit

test_processor: setup ./test/tb_processor.vhd
	$(ANALYZE) ./test/tb_processor.vhd
	$(RUN) tb_processor