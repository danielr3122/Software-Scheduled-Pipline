# data section
.data

# code/instruction section
.text
# Arithmetic
addi 	$s0, $zero, 1   # $s0 = 1  
addiu	$s1, $zero, 1   # $s1 = 1
nop # s1 <= EX
nop

addu	$s2, $s0, $s1   # $s2 = 2 #dp: s1 s0
#add	    $s3, $s0, $s1   # $s3 = 2 #dp: s1 s0
#sub	    $s4, $s2, $s1   # $s4 = 1 #dp: s2 s1
#subu	$s5, $s3, $s1   # $s5 = 1 #dp: s3 s1
#
#addi 	$s6, $zero, -1  # $s6 = -1 
#sra	    $s6, $s6, 1     # $s6 = -1 #dp: s6