.text

start:     li t0, 0x11111111
	   li t1, 0x11111111
	   li t2, 0xFFFFFFFF
	   li a0, 0x10010000

task6e:    sw t1, (a0)
	   addi a0, a0, 0x4
           add t1, t1, t0
           bne t1, t2, task6e
           sw t1, (a0)