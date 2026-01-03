quit -sim

vcom -2008 -work work RISCV_types.vhd
vcom -2008 -work work *.vhd
vcom -2008 -work work TopLevel/*.vhd

# more VCOM here

vsim -voptargs=+acc tb_RISCV_Processor

set NumericStdNoWarnings 1
run 0 ps
set NumericStdNoWarnings 0

#mem load -infile ../../output/lab3Seq.s/imem.hex -format hex /tb_RISCV_Processor/DUT0/IMEM
#mem load -infile ../../../test/exhaustive/program.hex -format hex /tb_RISCV_Processor/DUT0/IMEM
#mem load -infile ../../output/simplebranch.s/imem.hex -format hex /tb_RISCV_Processor/DUT0/IMEM

#mem load -infile ../../output/fibonacci.s/imem.hex -format hex /tb_RISCV_Processor/DUT0/IMEM
#mem load -infile ../../output/fibonacci.s/dmem.hex -format hex /tb_RISCV_Processor/DUT0/DMEM

#mem load -infile ../../output/grendel.s/imem.hex -format hex /tb_RISCV_Processor/DUT0/IMEM
#mem load -infile ../../output/grendel.s/dmem.hex -format hex /tb_RISCV_Processor/DUT0/DMEM

mem load -infile ../../output/Proj1_base_test.s/imem.hex -format hex /tb_RISCV_Processor/DUT0/IMEM
mem load -infile ../../output/Proj1_base_test.s/dmem.hex -format hex /tb_RISCV_Processor/DUT0/DMEM

mem load -infile ../../../test/zero.hex -format hex /tb_RISCV_Processor/DUT0/CPU_RegisterFile/s_Rx

add wave -noupdate -divider {Standard Inputs}
add wave -noupdate -label CLK /tb_RISCV_Processor/CLK
add wave -noupdate -label reset /tb_RISCV_Processor/reset

add wave -noupdate -divider {Instruction Information}
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/s_IPAddr
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/s_Inst
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/IFID_IF_buf.Insn
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/IDEX_IF_buf.Insn
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/EXMEM_IF_buf.Insn
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/MEMWB_IF_buf.Insn

add wave -noupdate -divider {Branch Information}
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/CPU_BGU/*

#add wave -noupdate -divider {Hazard Information}
#add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/s_IPBreak
#add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/IFID_Stall
#add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/IFID_Flush
#add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/IDEX_Stall
#add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/IDEX_Flush
#add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/EXMEM_Stall
#add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/EXMEM_Flush

add wave -noupdate -divider {Hazard Correction Information}
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/CPU_HMU/*

add wave -noupdate -divider {Data Forwarding Information}
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/CPU_DFU/*

add wave -noupdate -divider {Data Inputs/Outputs}
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/CPU_RegisterFile/s_Rx
add wave -noupdate -radix hexadecimal /tb_RISCV_Processor/DUT0/*

run 540