# #
# # Bubblesort algorithm
# #

.data
arr:.word  19, 91, 25, 41, 87, 55, 68, 13, 83, 49
space: .asciiz " "

.text
main:
	lui $s0, 0x1001		# array address
	addi $s1, $zero, 10	# n
	j bubblesort

bubblesort:
	addi $t0, $zero, 0	# i
	addi $t1, $zero, 0	# j
	addi $t2, $s1, -1
	j loop1
	
loop1:
    nop
	addi $t1, $zero, 0	# j
	j loop2

	loop1cond:
		addi $t0, $t0, 1
        nop
        nop
        nop

		bne $t0, $t2, loop1
	
add $t2, $zero, $s0
addi $t0, $zero, 0
j print
	
loop2:
	# arr[j]
    nop
    nop
	sll $s2, $t1, 2
    nop
    nop
    nop
	add $s2, $s2, $s0
    nop
    nop
    nop
	lw $t6, 0($s2)

	# arr[j+1]
	addi $s3, $t1, 1
    nop
    nop
    nop
	sll $s3, $s3, 2
    nop
    nop
    nop
	add $s3, $s3, $s0
    nop
    nop
    nop
	lw $t7, 0($s3)
    nop
    nop
    nop

	slt $t5, $t7, $t6
    nop
    nop
    nop
	bne $t5, $zero, swap
	
	loop2cond:
		addi $t1, $t1, 1	# j++
		addi $t3, $s1, -1	# x = n - 1
        nop
        nop
        nop
		sub $t3, $t3, $t0	# x = x - i
        nop
        nop
        nop
		slt $t4, $t1, $t3	# j < x
        nop
        nop
        nop
		bne $t4, $zero, loop2

	j loop1cond
	
swap:
	sw $t6, 0($s3)
	sw $t7, 0($s2)
	j loop2cond

print:
	addi $v0, $zero, 1
	lw $a0, 0($t2)
	syscall
	addi $v0, $zero, 4
	addi $a0, $zero, 32
	syscall

	addi $t2, $t2, 4	# increment in the array
	addi $t0, $t0, 1 	# i+1
    nop
    nop
    nop
	bne $t0, $s1, print	# i != n
	halt
