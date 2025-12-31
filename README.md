# horizon
A fully-functional five-stage hardware-scheduled pipelined, multithreaded RISC-V–based processor implemented in SystemVerilog and VHDL.

## Key Features
- Full RV32-I base RISC-V integer unpriviliged instruction set support
- 5-stage pipelined design with an unoptimized maximum frequency of 53 MHz
- Native VHDL2008 implementation compatible with both Siemens (R) QuestaSim (TM) and Intel (R) Quartus (TM).
- Native SystemVerilog 2012 implementation compatbile with Icarus Verilog.

![hw_all_tests_passing_on_VDI](hw_all_tests_passing_on_VDI.png)

## Related Projects
 - _stratus_: My barebones custom operating system kernel design to run on the _horizon_ CPU implementation in RISC-V.
   - [https://github.com/connorjlink/stratus](https://github.com/connorjlink/stratus)
 - _haze_: My custom x86 & RISC-V optimizing compiler designed to generated executables for the _horizon_ CPU in RV32-I (+ relevant extensions) machine code.
   - [https://github.com/connorjlink/haze](https://github.com/connorjlink/haze)
