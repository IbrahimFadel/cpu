IV = iverilog -Isrc
INPUT_FILES = $(wildcard src/*.v)
TB_FILES = $(wildcard tb/*.v)
OUT_VVP = cpu.vvp
OUT_VCD = cpu.vcd

all: $(OUT_VCD)

$(OUT_VVP): $(INPUT_FILES)
	$(IV) -o $(OUT_VVP) $(INPUT_FILES)

$(OUT_VCD): $(INPUT_FILES) $(TB_FILES)
	$(IV) -o $(OUT_VVP) $(INPUT_FILES) $(TB_FILES)
	vvp $(OUT_VVP)

clean:
	rm *{.vcd,.vvp}
