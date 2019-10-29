# board1.s ... Game of Life on a 10x10 grid

	.data

N:	.word 10  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

newBoard: .space 100
# Game of Life on a NxN grid
#
# Written by Enoch2019, June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

########################################################################
# global .data
	.data
			.align 4
prompt:		.asciiz "# Iterations: "
iter_msg1:	.asciiz "=== After iteration "
iter_msg2:	.asciiz " ==="
dot:		.asciiz "."
hash:		.asciiz "#"
eol:		.asciiz "\n"
			.align 4
maxiters:	.space 4	#int maxiters


## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow


########################################################################
# .TEXT <main>
	.text
main:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4, $s5
# Uses:		$a0, $a1, $v1, $s0, $s1, $s2, $s3, $s4, $s5
# Clobbers:	$a0, $a1

# Locals:
#		- 'maxiters' address in $s0
#		- 'n' in $s1
#		- 'i' in $s2
#		- 'j' in $s3
#		- 'N' in $s4
#		- newBoard index in $s5

# Structure:
#	main
#	-> main_prol
#	-> main_init
#	-> main_iter_init
#	-> main_iter_cond
#		-> main_row_init
#		-> main_row_cond
#			-> main_col_init
#			-> main_col_step
#			-> main_col_false
#		-> main_row_step
#		-> main_row_false
#	-> main_iter_step
#	-> main_iter_false
#	-> main_post

# Code:

	# Your main program code goes here.  Good luck!
main_prol:
	#main's prologue
		sw		$fp, -4($sp)	#storing address of fp
		la		$fp, -4($sp)
		sw		$ra, -4($fp)	#storing return address
		sw		$s0, -8($fp)	#storing value of $s0
		sw		$s1, -12($fp)
		sw		$s2, -16($fp)
		sw		$s3, -20($fp)
		sw		$s4, -24($fp)
		sw		$s5, -28($fp)
		add 	$sp, $sp, -32

main_init:
		la		$s0, maxiters	# $s0 = &maxiters
		li		$v0, 4
		la		$a0, prompt
		syscall
		# scanf ("%d", &maxiters)
		li 		$v0, 5
		syscall
		sw 		$v0, ($s0)

main_iter_init:
		lw  	$s4, N			# $s4 = N
		li 		$s1, 1			#int n = 1;
		lw		$s0, maxiters
main_iter_cond:
		# if (n > maxiters)
		
		bgt		$s1, $s0, main_iter_false
main_row_init:
		#row index int i = 0
		li		$s2, 0
main_row_cond:
		# if (i >= N)
		bge		$s2, $s4, main_row_false
main_col_init:
		#column index int j = 0
		li		$s3, 0
main_col_cond:
		# if (j >= N)
		bge		$s3, $s4, main_col_false
		# nn = neighbours
		move 	$a0, $s2		#$a0 = i
		move 	$a1, $s3		#$a1 = j
		jal		neighbours
		move	$t4, $v0		#$t4 = nn

		mul		$t0, $s2, $s4	#row in bytes	N*i
		add		$t0, $t0, $s3	#position of cell N*i + j
		la		$t1, board
		add		$t1, $t1, $t0	#moving the index of the board
		lb		$t5, ($t1)
		
		la		$s5, newBoard
		add		$s5, $s5, $t0	#moving the index of newBoard
		
		move 	$a0, $t5		#$a0 = current cell
		move 	$a1, $t4		#$a1 = nn
		jal		decideCell
		sb		$v0, ($s5)      #newboard[i][j] = ret

main_col_step:
		addi 	$s3, $s3, 1		#j++
		j		main_col_cond
main_col_false:	
main_row_step:
		addi 	$s2, $s2, 1		#i++
		j		main_row_cond
main_row_false:
		#printf("=== After iteration ")
		li		$v0, 4
		la		$a0, iter_msg1
		syscall
		#printf("%d", n)
		li 		$v0, 1
		move 	$a0, $s1
		syscall
		#printf(" ===")
		li		$v0, 4
		la 		$a0, iter_msg2
		syscall
		#printf("\n")
		li 		$v0, 4
    	la 		$a0, eol
    	syscall
		jal 	copyBackAndShow
main_iter_step:
		addi 	$s1, $s1, 1		#n++
		j		main_iter_cond
main_iter_false:

main_post:
		lw		$s5, -28($fp)
		lw		$s4, -24($fp)
		lw		$s3, -20($fp)
		lw		$s2, -16($fp)
		lw		$s1, -12($fp)
		lw		$s0, -8($fp)
		lw		$ra, -4($fp)
		#remove stack frame
		la		$sp, 4($fp)
		lw		$fp, ($fp)
		#return 0
		li		$v0, 0
		jr		$ra

	# Put your other functions here
decideCell:
		#decideCell's prologue
		sw		$fp, -4($sp)	#storing address of fp
		la		$fp, -4($sp)
		sw		$ra, -4($fp)	#storing return address
		sw		$s0, -8($fp)	#storing value of $s0
		sw		$s1, -12($fp)
		sw		$s2, -16($fp)
		sw		$s3, -20($fp)
		sw		$s4, -24($fp)
		sw		$s5, -28($fp)
		addi 	$sp, $sp, -32

decideCell_init:
		move	$s0, $a0		#$s0 = old
		move	$s1, $a1		#$s1 = nn
		#$s2 = ret

decideCell_old:
		# if (old != 1)
		li		$t0, 1
		bne		$s0, $t0, decideCell_nn
decideCell_old_if:
		li		$t0, 2
		# if (nn >= 2)
		bge		$s1, $t0, decideCell_old_else_if
		li		$s2, 0
		j		decideCell_return

decideCell_old_else_if:
		li		$t0, 2
		beq		$t0, $s1, decideCell_old_true
		li		$t0, 3
		beq		$t0, $s1, decideCell_old_true
		j		decideCell_old_else

decideCell_old_true:
		li		$s2, 1
		j		decideCell_return
decideCell_old_else:
		li		$s2, 0
		j		decideCell_return
decideCell_nn:
		# if (nn != 3)
		li		$t0, 3
		bne		$s1, $t0, decideCell_false
		li		$s2, 1
		j		decideCell_return

decideCell_false:
		li		$s2, 0
decideCell_return:
		move	$v0, $s2
decideCell_post:
		lw		$s5, -28($fp)
		lw		$s4, -24($fp)
		lw		$s3, -20($fp)
		lw		$s2, -16($fp)
		lw		$s1, -12($fp)
		lw		$s0, -8($fp)
		lw		$ra, -4($fp)
		#remove stack frame
		la		$sp, 4($fp)
		lw		$fp, ($fp)
		#return
		jr		$ra
neighbours:
		#neighours's prologue
		sw		$fp, -4($sp)	#storing address of fp
		la		$fp, -4($sp)
		sw		$ra, -4($fp)	#storing return address
		sw		$s0, -8($fp)	#storing value of $s0
		sw		$s1, -12($fp)
		sw		$s2, -16($fp)
		sw		$s3, -20($fp)
		sw		$s4, -24($fp)
		sw		$s5, -28($fp)
		addi 	$sp, $sp, -32

neighbours_init:
		move	$s0, $a0		#$s0 = i
		move	$s1, $a1		#$s1 = j
		li		$s2, 0			#int nn = 0

neighbours_xPos_init:
		li		$s3, -1			#int x = -1
neighbours_xPos_cond:
		#if (x > 1)
		li		$t0, 1
		bgt		$s3, $t0, neighbours_xPos_false
neighbours_yPos_init:
		li		$s4, -1			#int y = -1
neighbours_yPos_cond:
		#if (y > 1)
		li		$t0, 1
		bgt		$s4, $t0, neighbours_yPos_false

		# (i + x < 0 || i + x > N - 1) continue
		li		$t0, 0
		add		$t1, $s0, $s3
		blt		$t1, $t0, neighbours_yPos_step
		lw		$t2, N
		addi	$t2, $t2, -1
		bgt		$t1, $t2, neighbours_yPos_step
		# (j + y < 0 || j + y > N - 1)
		li		$t0, 0
		add		$t1, $s1, $s4
		blt		$t1, $t0, neighbours_yPos_step
		lw		$t2, N
		addi	$t2, $t2, -1
		bgt		$t1, $t2, neighbours_yPos_step
		# if (x  != 0 || y != 0) 
		li		$t0, 0
		bne		$t0, $s3, neighbours_increment
		bne		$t0, $s4, neighbours_increment
		j		neighbours_yPos_step
neighbours_increment:
		add		$t0, $s0, $s3	#i+x
		lw		$t1, N
		mul		$t0, $t0, $t1	#N*(i+x)
		add		$t1, $s1, $s4	#j + y
		add		$t0, $t0, $t1	#N*(i+x) + (j+y)
		la		$t2, board		#$t2 = board[0][0]
		add		$t2, $t2, $t0	#board[i+x][j+y]
		lb		$t3, ($t2)		#$t3 = board[i+x][j+y]
		li		$t0, 1
		# if (board[i+x][j+y] != 1)
		bne		$t3, $t0, neighbours_yPos_step
		addi	$s2, $s2, 1

neighbours_yPos_step:
		addi	$s4, $s4, 1		#y++
		j		neighbours_yPos_cond
neighbours_yPos_false:
neighbours_xPos_step:
		addi	$s3, $s3, 1		#x++
		j		neighbours_xPos_cond
neighbours_xPos_false:
		move	$v0, $s2
neighbours_post:
		lw		$s5, -28($fp)
		lw		$s4, -24($fp)
		lw		$s3, -20($fp)
		lw		$s2, -16($fp)
		lw		$s1, -12($fp)
		lw		$s0, -8($fp)
		lw		$ra, -4($fp)
		#remove stack frame
		la		$sp, 4($fp)
		lw		$fp, ($fp)
		#return
		jr		$ra
copyBackAndShow:
		#copyBackAndShow's prologue
		sw		$fp, -4($sp)	#storing address of fp
		la		$fp, -4($sp)
		sw		$ra, -4($fp)	#storing return address
		sw		$s0, -8($fp)	#storing value of $s0
		sw		$s1, -12($fp)
		sw		$s2, -16($fp)
		sw		$s3, -20($fp)
		sw		$s4, -24($fp)
		sw		$s5, -28($fp)
		addi 	$sp, $sp, -32

copyBackAndShow_row_init:
		li		$s0, 0			#int i = 0
		lw		$s2, N
copyBackAndShow_row_cond:
		bge 	$s0, $s2, copyBackAndShow_row_false
copyBackAndShow_col_int:
		li		$s1, 0			#int j = 0
copyBackAndShow_col_cond:
		bge		$s1, $s2, copyBackAndShow_col_false

		mul		$t0, $s0, $s2	#N*i
		add		$t0, $t0, $s1	#N*i + j
		la		$t1, newBoard   #$t1 = &newBoard
		add		$t1, $t1, $t0   #newBoard[i][j]
		la		$t2, board      #$t2 = &board
		add		$t2, $t2, $t0   #$t2 = board[i][j]
		lb		$t0, ($t1)		#$t0 = newBoard[i][j]
		sb		$t0, ($t2)		#board[i][j] = newBoard[i][j]
		li		$t3, 0
		
		#move	$a0, $t0
		#li		$v0, 1
		#syscall

		bne		$t0, $t3, copyBackAndShow_else
		li 		$v0, 4
    	la 		$a0, dot
    	syscall
		j		copyBackAndShow_col_step
		
copyBackAndShow_else:
		li 		$v0, 4
    	la 		$a0, hash
    	syscall
copyBackAndShow_col_step:
		addi	$s1, $s1, 1
		j		copyBackAndShow_col_cond
copyBackAndShow_col_false:
		li 		$v0, 4
    	la 		$a0, eol
    	syscall
copyBackAndShow_row_step:
		addi	$s0, $s0, 1		#i++
		j		copyBackAndShow_row_cond
copyBackAndShow_row_false:
copyBackAndShow_post:
		lw		$s5, -28($fp)
		lw		$s4, -24($fp)
		lw		$s3, -20($fp)
		lw		$s2, -16($fp)
		lw		$s1, -12($fp)
		lw		$s0, -8($fp)
		lw		$ra, -4($fp)
		#remove stack frame
		la		$sp, 4($fp)
		lw		$fp, ($fp)
		#return
		jr		$ra
