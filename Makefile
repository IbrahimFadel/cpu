.PHONY: all cpu test alu fetch

IV = iverilog -Icpu
INPUT_FILES = $(wildcard cpu/*.v)
OUT = cpu.vvp

MODULE?=cpu/alu

all: cpu

cpu:
	$(IV) -o $(OUT) $(INPUT_FILES)

cpu_tb:
	$(IV) -o cpu_tb.vvp testbench/cpu_tb.v $(INPUT_FILES)
	vvp cpu_tb.vvp

# -p "techmap; opt" \

image:
	yosys \
		-p "read_verilog cpu/*.v" \
		-p "hierarchy -top cpu" \
		-p "flatten" \
		-p "synth -top cpu -flatten" \
		-p "abc -g gates" \
		-p "proc" \
		-p "show -prefix ./schematic -colors 1 -format png" \
		-p "stat"

# image:
# 	yosys \
# 		-p "read_verilog -sv -formal $(MODULE).v" \
# 		-p "flatten" \
# 		-p "proc" \
# 		-p "write_json $(MODULE).json"
# 	netlistsvg -o $(MODULE).svg $(MODULE).json
# 	convert -background white $(MODULE).svg $(MODULE).png
# 	rm $(MODULE).json $(MODULE).svg
