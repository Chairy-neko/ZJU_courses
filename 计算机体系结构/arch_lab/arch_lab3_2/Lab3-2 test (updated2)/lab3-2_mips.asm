begin:
Lw $1, 20($zero)		//R1=4
Lw $2, 24($zero)		//R2=1
Add $3,$2,$1    	//R3=5	//2LW-ALU:forwarding:1 stall
Sub $4,$3,$1      	//R4=1	//2ALU-ALU
And $5,$3,$1     	//R5=4	//无冲突
Or $6,$3,$1		//R6=5	//无冲突
addi $6,$3,4		//$6=9	//无冲突
Add $7, $zero, $1		//R7=4	//无冲突
Lw $8,0($7)     	//R8=8	//2ALU-LW
Sw $8,8($7)    		//	//2LW-SW：forwarding可以解决
Lw $9, 8($7)		//R9=8
Sw $7, 0($9)		//	//2LW-SW: forwarding:1 stall
Lw $10,0($9)		//R10=4
Add $11, $1, $1 	//R11=8
Add $10, $1, $10	//R10=8 //1LW-ALU:forwarding可以解决
Add $10,$1,$2		//R10=5
Beq $10, $11 ,label1   	// not taken//2+1ALU-BEQ//	branch x
Lw $1, 8($7)		//R1=8
Lw $2, 24($zero)		//R2=1
label1:
Add $3,$2,$1		//R3=9	//2LW-ALU
Sub $4,$3,$1		//R4=1   //2ALU-R-R
Addi $20, $4, 1 	//R20=2	//2ALU-addi
Ori $20, $4, 0x8000   	//R20=0x8001	//无冲突 无符号扩展
Bne $1, $2, label2  		//taken x
Lw $1,20($zero)		//不执行
label2:
Lw $2,24($zero)		//R2=1
Add $3,$2,$1		//R3=9   //2ALU
Sub $4,$3,$1		//R4=1   //2ALU x
Jal label3		
Srl $5,$1,2		//R5=2 //移位指令
Lui $5, 0x1111		//R5=0x11110000	//无冲突
Addi $6,$5,0x8000		//R6=0x11108000	符号扩展//2forwarding可以解决
J begin			//j
label3:
Slt $3,$1,$2		//R3=0
Slti $4,$3,0x8000	//R4=0	//2forwarding可以解决
Andi $5,$6,0x11		//R5=1
Jr $31			//回到1d