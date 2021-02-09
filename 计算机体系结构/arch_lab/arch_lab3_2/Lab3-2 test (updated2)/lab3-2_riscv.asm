begin:
    lw x1, 20(x0) #R1=4
    lw x2, 24(x0) #R2=1
    add x3,x2,x1 #R3=5 #2lw-ALU:forwarding:1 stall
    sub x4,x3,x1 #R4=1 #2ALU-ALU
    and x5,x3,x1 #R5=4 #No Hazard
    or x6,x3,x1 #R6=5 #No Hazard
    addi x6,x3,4 #x6=9 #No Hazard
    add x7, x0, x1 #R7=4 #No Hazard
    lw x8,0(x7) #R8=8 #2ALU-lw
    sw x8,8(x7) # #2lw-sw: forwarding or stall can handle
    lw x9, 8(x7) #R9=8
    sw x7, 0(x9) # #2lw-sw: forwarding:1 stall
    lw x10,0(x9) #R10=4
    add x11, x1, x1 #R11=8
    add x10, x1, x10 #R10=8 #1lw-ALU:forwarding or stall can handle
    add x10,x1,x2 #R10=5
    beq x10, x11 ,label1 # not taken#2+1ALU-beq# branch x
    lw x1, 8(x7) #R1=8
    lw x2, 24(x0) #R2=1
label1:
    add x3,x2,x1 #R3=9 #2lw-ALU
    sub x4,x3,x1 #R4=1 #2ALU-R-R
    addi x20, x4, 1 #R20=2 #2ALU-addi
    ori x20, x4, 0x600 #R20=0x0601 #No Hazard unsigned-extend
    bne x1, x2, label2 #taken x
    lw x1,20(x0) #
label2:
    lw x2,24(x0) #R2=1
    add x3,x2,x1 #R3=9 #2ALU
    sub x4,x3,x1 #R4=1 #2ALU x
    jal x31, label3
    srli x5,x1,2 #R5=2 #shift
    lui x5, 0x11110 #R5=0x11110000 #No Hazard
    addi x6,x5,0x600 #R6=0x11110600 #2forwarding or stall can handle
    jal x30, begin #j
label3:
    slt x3,x1,x2 #R3=0
    slti x4,x3,-1 #R4=0 #2forwarding or stall can handle
    andi x5,x6,0x11 #R5=1
    jalr x0 x31 0 #return to 1d

PC	    Machine Code	Basic Code	    Original Code
0x0	    0x01402083	    lw x1 20(x0)	lw x1, 20(x0) #R1=4
0x4	    0x01802103	    lw x2 24(x0)	lw x2, 24(x0) #R2=1
0x8	    0x001101B3	    add x3 x2 x1	add x3,x2,x1 #R3=5 #2lw-ALU:forwarding:1 stall
0xc	    0x40118233	    sub x4 x3 x1	sub x4,x3,x1 #R4=1 #2ALU-ALU
0x10	0x0011F2B3	    and x5 x3 x1	and x5,x3,x1 #R5=4 #No Hazard
0x14	0x0011E333	    or x6 x3 x1	    or x6,x3,x1 #R6=5 #No Hazard
0x18	0x00418313	    addi x6 x3 4	addi x6,x3,4 #x6=9 #No Hazard
0x1c	0x001003B3	    add x7 x0 x1	add x7, x0, x1 #R7=4 #No Hazard
0x20	0x0003A403	    lw x8 0(x7)	    lw x8,0(x7) #R8=8 #2ALU-lw
0x24	0x0083A423	    sw x8 8(x7)	    sw x8,8(x7) # #2lw-sw: forwarding or stall can handle
0x28	0x0083A483	    lw x9 8(x7)	    lw x9, 8(x7) #R9=8
0x2c	0x0074A023	    sw x7 0(x9)	    sw x7, 0(x9) # #2lw-sw: forwarding:1 stall
0x30	0x0004A503	    lw x10 0(x9)	lw x10,0(x9) #R10=4
0x34	0x001085B3	    add x11 x1 x1	add x11, x1, x1 #R11=8
0x38	0x00A08533	    add x10 x1 x10	add x10, x1, x10 #R10=8 #1lw-ALU:forwarding or stall can handle
0x3c	0x00208533	    add x10 x1 x2	add x10,x1,x2 #R10=5
0x40	0x00B50663	    beq x10 x11 12	beq x10, x11 ,label1 # not taken#2+1ALU-beq# branch x
0x44	0x0083A083	    lw x1 8(x7)	    lw x1, 8(x7) #R1=8
0x48	0x01802103	    lw x2 24(x0)	lw x2, 24(x0) #R2=1
0x4c	0x001101B3	    add x3 x2 x1	add x3,x2,x1 #R3=9 #2lw-ALU
0x50	0x40118233	    sub x4 x3 x1	sub x4,x3,x1 #R4=1 #2ALU-R-R
0x54	0x00120A13	    addi x20 x4 1	addi x20, x4, 1 #R20=2 #2ALU-addi
0x58	0x60026A13	    ori x20 x4 1536	ori x20, x4, 0x600 #R20=0x0601 #No Hazard unsigned-extend
0x5c	0x00209463	    bne x1 x2 8	    bne x1, x2, label2 #taken x
0x60	0x01402083	    lw x1 20(x0)	lw x1,20(x0) #
0x64	0x01802103	    lw x2 24(x0)	lw x2,24(x0) #R2=1
0x68	0x001101B3	    add x3 x2 x1	add x3,x2,x1 #R3=9 #2ALU
0x6c	0x40118233	    sub x4 x3 x1	sub x4,x3,x1 #R4=1 #2ALU x
0x70	0x01400FEF	    jal x31 20	    jal x31, label3
0x74	0x0020D293	    srli x5 x1 2	srli x5,x1,2 #R5=2 #shift
0x78	0x111102B7	    lui x5 69904	lui x5, 0x11110 #R5=0x11110000 #No Hazard
0x7c	0x60028313	    addi x6 x5 1536	addi x6,x5,0x600 #R6=0x11110600 #2forwarding or stall can handle
0x80	0xF81FFF6F	    jal x30 -128	jal x30, begin #j
0x84	0x0020A1B3	    slt x3 x1 x2	slt x3,x1,x2 #R3=0
0x88	0xFFF1A213	    slti x4 x3 -1	slti x4,x3,-1 #R4=0 #2forwarding or stall can handle
0x8c	0x01137293	    andi x5 x6 17	andi x5,x6,0x11 #R5=1
0x90	0x000F8067	    jalr x0 x31 0	jalr x0 x31 0 #return to 1d


