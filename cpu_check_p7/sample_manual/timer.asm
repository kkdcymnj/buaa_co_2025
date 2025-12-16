.data
array:.space 4096

.text
ori $gp,$0,0x1800
ori $sp,$0,0x2ffc
ori $10,$0,0x1c01
mtc0 $10,$12
mfc0 $10,$12
mfc0 $10,$13
mfc0 $10,$14

ori $11,$0,0x8
sw $11,0x7f00($0)
ori $11,$0,0x4
sw $11,0x7f04($0)
lui $11,0x1
ori $11,0x2732
add $11,$11,$11
lui $10,0x1
ori $10,0x2
sub $11,$11,$10
mult $11,$10
add $10,$10,$10
mfhi $9
mflo $8

ori $11,$0,0x8
sw $11,0x7f10($0)
ori $11,$0,0x4
sw $11,0x7f14($0)
lui $11,0x1
ori $11,0x2732
add $11,$11,$11
lui $10,0x1
ori $10,0x2
sub $11,$11,$10
mult $11,$10
add $10,$10,$10
mfhi $9
mflo $8