.data
array:.space 4096

.text
#target pc=0x3028
ori $gp,$0,0x1800
ori $sp,$0,0x2ffc
ori $10,$0,0x1c01
mtc0 $10,$12
mfc0 $10,$12
mfc0 $10,$13
mfc0 $10,$14

ori $3,$0,0x28
sw $3,0($0)
ori $4,$0,0x32
lw $5,0($0)
bne $4,$5,label2
nop

label1:
lui $6,1

label2:
lui $6,2