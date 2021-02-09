
# mips
initial:
    lui     	$6, 0x666           	# $6 = 0x06660000
    addi	$1, $0, 2		# $1 = $0 + 2 = 2
    nop
    nop
    nop
    nop
    addi	$2, $1, 14		# $2 = $1 + 14 = 16
    sw		$1, 8($2)		# store 2 to address 24
l1:
    ori     	$3, $1, 4           	# $3 = $1 | 4 = 6
    sll     	$1, $1, 4           	# $1 = $1 << 4 = 32
    nop
    nop
    nop
    nop
    lw		$4, -8($1)		# $4 = *(32-8) = *24 = 2
    sra     	$1, $1, 1           	# $1 = $1 >> 1 = 16
    nop
    nop
    nop
    nop
    beq		$1, $2, l2	        # if $1 == $2 then go to l2
    nop
    nop
    nop
    nop
    addi	$6, $6, -1		# $6 = $6 - 1
l2:
    addi	$1, $0, 2		# $1 = $0 + 2 = 2
    nop
    nop
    nop
    nop
    bne		$4, $1, l1	        # if $1 == $4 then go to l1  
    nop
    nop
    nop
    nop
exit:
    add		$7, $2, $2		# $7 = $2 + $2 = 32


# If finally $7 = 32 and $6 = 0x06660000, your CPU will be considered to be well done!

# riscv
initial:
    lui     	x6, 0x666           	# x6 = 0x06660000
    addi	x1, x0, 2		# x1 = x0 + 2 = 2
    nop
    nop
    nop
    nop
    addi	x2, x1, 14		# x2 = x1 + 14 = 16
    sw		x1, 8(x2)		# store 2 to address 24
l1:
    ori     	x3, x1, 4           	# x3 = x1 | 4 = 6
    slli     	x1, x1, 4           	# x1 = x1 << 4 = 32
    nop
    nop
    nop
    nop
    lw		x4, -8(x1)		# x4 = *(32-8) = *24 = 2
    srai     	x1, x1, 1           	# x1 = x1 >> 1 = 16
    nop
    nop
    nop
    nop
    beq		x1, x2, l2	        # if x1 == x2 then go to l2
    nop
    nop
    nop
    nop
    addi	x6, x6, -1		# x6 = x6 - 1
l2:
    addi	x1, x0, 2		# x1 = x0 + 2 = 2
    nop
    nop
    nop
    nop
    bne		x4, x1, l1	        # if x1 == x4 then go to l1  
    nop
    nop
    nop
    nop
exit:
    add		x7, x2, x2		# x7 = x2 + x2 = 32


# If finally x7 = 32 and x6 = 0x06660000, your CPU will be considered to be well done!

