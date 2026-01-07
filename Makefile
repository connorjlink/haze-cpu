setup:
	ghdl -a --work=work --std=08 ./source/types.vhd
	ghdl -a --work=work --std=08 ./source/not_1.vhd ./source/not_N.vhd ./source/and_2.vhd ./source/or_2.vhd ./source/xor_2.vhd
	ghdl -a --work=work --std=08
	ghdl -a --work=work --std=08 ./source/*.vhd
	ghdl -a --work=work --std=08 ./test/*.vhd

test_barrel_shifter:
	ghdl --elab-run --std=08 tb_barrel_shifter



test:
	make setup
	make test_barrel_shifter