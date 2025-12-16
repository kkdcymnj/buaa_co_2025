.data
array:.space 4096

.text
#target pc=0x302c
ori $gp,$0,0x1800
ori $sp,$0,0x2ffc
ori $10,$0,0x1c01
mtc0 $10,$12
mfc0 $10,$12
mfc0 $10,$13
mfc0 $10,$14

lui $7,0x7fff
ori $7,$7,0xffff
lui $8,0x7fff
ori $8,$8,0xffff
add $9,$8,$7
nop

label1:
lui $6,1

label2:
lui $6,2