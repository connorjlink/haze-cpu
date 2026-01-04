test_instruction_pointer:
	iverilog -g2012 -o simv -I ../source testbench_instruction_pointer.sv
	vvp simv
	rm simv

test_comparator:
	iverilog -g2012 -o simv -I ../source testbench_comparator.sv
	vvp simv
	rm simv

test_registerfile:
	iverilog -g2012 -o simv -I ../source testbench_registerfile.sv
	vvp simv
	rm simv

test_register_N:
	iverilog -g2012 -o simv -I ../source testbench_register_N.sv
	vvp simv
	rm simv

test:
	make test_instruction_pointer
	make test_comparator
	make test_registerfile