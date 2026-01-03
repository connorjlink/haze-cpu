add wave -noupdate -divider {Standard Inputs}
add wave -noupdate -label CLK /tb/CLK
add wave -noupdate -label reset /tb/reset

add wave -noupdate -divider {Instruction Information}
add wave -noupdate -radix hexadecimal /tb/MyRiscv/s_IPAddr
add wave -noupdate -radix hexadecimal /tb/MyRiscv/s_Inst
add wave -noupdate -radix hexadecimal /tb/MyRiscv/IFID_IF_buf.Insn
add wave -noupdate -radix hexadecimal /tb/MyRiscv/IDEX_IF_buf.Insn
add wave -noupdate -radix hexadecimal /tb/MyRiscv/EXMEM_IF_buf.Insn
add wave -noupdate -radix hexadecimal /tb/MyRiscv/MEMWB_IF_buf.Insn

add wave -noupdate -divider {Branch Information}
add wave -noupdate -radix hexadecimal /tb/MyRiscv/CPU_BGU/*

#add wave -noupdate -divider {Hazard Information}
#add wave -noupdate -radix hexadecimal /tb/MyRiscv/s_IPBreak
#add wave -noupdate -radix hexadecimal /tb/MyRiscv/IFID_Stall
#add wave -noupdate -radix hexadecimal /tb/MyRiscv/IFID_Flush
#add wave -noupdate -radix hexadecimal /tb/MyRiscv/IDEX_Stall
#add wave -noupdate -radix hexadecimal /tb/MyRiscv/IDEX_Flush
#add wave -noupdate -radix hexadecimal /tb/MyRiscv/EXMEM_Stall
#add wave -noupdate -radix hexadecimal /tb/MyRiscv/EXMEM_Flush

add wave -noupdate -divider {Hazard Correction Information}
add wave -noupdate -radix hexadecimal /tb/MyRiscv/CPU_HMU/*

add wave -noupdate -divider {Data Forwarding Information}
add wave -noupdate -radix hexadecimal /tb/MyRiscv/CPU_DFU/*

add wave -noupdate -divider {Data Inputs/Outputs}
add wave -noupdate -radix hexadecimal /tb/MyRiscv/CPU_RegisterFile/s_Rx
add wave -noupdate -radix hexadecimal /tb/MyRiscv/*