.data
array:.space 4096

.text
ori $2,$0,2000
ori $3,$0,3000
ori $4,$0,5000
sw $2,0($0)
sw $3,4($0)
sw $4,8($0)
sw $2,12($0)
sw $3,16($0)
sw $4,20($0)
add $3,$3,$2	#$3=5000
beq $3,$4,label2
nop

label1:
add $2,$2,$3

label2:
ori $5,$0,4
ori $6,$0,8
add $7,$5,$6
lw $8,0($7)	
ori $7,$5,0
lw $8,0($7)
sw $7,0($8)
jal label4
nop

label3:
add $3,$2,$3

label4:
ori $8,$31,0
jal label6
nop

label5:
add $3,$2,$3

label6:
beq $5,$31,label7
nop
jal label8
nop

label7:
add $3,$2,$3

label8:
lui $10,1
lui $9,1
beq $10,$9,label10
nop
jal label10
nop
jal end
nop

label9:
add $3,$2,$3

label10:
jal label11
nop

label11:
beq $0,$0,end
nop

end:
beq $31,$0,end
nop
