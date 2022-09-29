		.text

start:		li t1, 0x10
		li t0, 0
		li a0, 0x10010000
task4_write:	sw t0, (a0)
		addi t0, t0, 0x1
		addi a0, a0, 0x4
		bltu t0, t1, task4_write

		li t3, 0xf
		li t4, 0
task4_inc:      li t0, 0
		li a0, 0x10010000
task4_inc_loop:	lw t5, (a0)
		addi t5, t5, 0x1
		sw t5, (a0)
		addi a0, a0, 0x4
		addi t0, t0, 0x1
		bltu t0, t1, task4_inc_loop
		addi t2, t2, 0x1
		bltu t2, t3, task4_inc