onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider GENERAL
add wave -noupdate -label clk -radix binary /tb/u1/clk
add wave -noupdate -label foo -radix binary /tb/u1/foo
add wave -noupdate -label en -radix binary /tb/u1/en
add wave -noupdate -label pre_en -radix binary /tb/u1/pre_en
add wave -noupdate -label state -radix decimal /tb/u1/c/ctrl/state
add wave -noupdate -label reset -radix binary /tb/u1/resetn
add wave -noupdate -label pc -radix decimal /tb/u1/c/pc
add wave -noupdate -label ar -radix decimal /tb/u1/c/ar
add wave -noupdate -label instr -radix binary /tb/u1/c/instr
add wave -noupdate -divider DEBUG
add wave -noupdate -label registers -radix decimal /tb/u1/registers
add wave -noupdate -label WD3 -radix decimal /tb/u1/WD3
add wave -noupdate -label A3 -radix decimal /tb/u1/A3
add wave -noupdate -label reg_write -radix binary /tb/u1/reg_write

add wave -noupdate -label vga_en -radix binary /tb/u1/vga_en
add wave -noupdate -label vga_addr -radix decimal /tb/u1/vga_addr
add wave -noupdate -label vga_addr -radix decimal /tb/u1/mem/vga_addr
add wave -noupdate -label x1 -radix hex /tb/u1/x1

add wave -noupdate -label finished_register -radix binary /tb/u1/v/u1/cc/finished_register
add wave -noupdate -divider ALU
add wave -noupdate -label alu_op -radix binary /tb/u1/c/ctrl/alu_op
add wave -noupdate -label A -radix decimal /tb/u1/c/dp/A
add wave -noupdate -label B -radix decimal /tb/u1/c/dp/B
add wave -noupdate -label rd -radix decimal /tb/u1/c/dp/rd
add wave -noupdate -label a_src -radix binary /tb/u1/c/dp/alu_a_src
add wave -noupdate -label b_src -radix binary /tb/u1/c/dp/alu_b_src
add wave -noupdate -label imm_ext -radix decimal /tb/u1/c/dp/imm_ext
add wave -noupdate -label alu_result -radix decimal /tb/u1/c/dp/alu_result
add wave -noupdate -label zero -radix binary /tb/u1/c/ctrl/zero
add wave -noupdate -label jump -radix binary /tb/u1/c/ctrl/md/jump
add wave -noupdate -divider REGISTERS
add wave -noupdate -label rd -radix decimal /tb/u1/c/dp/rd
add wave -noupdate -label wd3 -radix decimal /tb/u1/c/dp/wd3
add wave -noupdate -label reg_write -radix decimal /tb/u1/c/dp/reg_write
add wave -noupdate -label registers -radix decimal /tb/u1/c/dp/rf/registers
add wave -noupdate -divider MEMORY
add wave -noupdate -label cpu_addr -radix decimal /tb/u1/mem/cpu_addr
add wave -noupdate -label vga_addr -radix decimal /tb/u1/mem/vga_addr
add wave -noupdate -label addr -radix decimal /tb/u1/mem/addr
add wave -noupdate -label wd -radix decimal /tb/u1/mem/wd
add wave -noupdate -label we -radix decimal /tb/u1/mem/we
add wave -noupdate -label rd -radix decimal /tb/u1/mem/rd
add wave -noupdate -label src -radix decimal /tb/u1/mem_src

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {120 ns}
