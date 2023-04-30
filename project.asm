  # Osama Rihami 1190560 , Ferdos Ahmad 1161937
  .data
  array: .space 2004 		#Input float values read from the file
  output: .space 2004   	#Output float values computed
  buffer: .space 2004		#Input string read from the input file
  outBuffer: .space 2004	#Output string to write on the output file
  w1: .float 1.5		# window 1 value
  w2: .float 0.5		# window 2 value
  line:  .asciiz "\n"
  space:  .asciiz " "
  dot:  .asciiz "."
  fin: .asciiz "input.txt" 	# filename for input
  fout: .asciiz "output.txt" 	# filename for output
  string1:  .asciiz "Enter the level you want to reach: "
  string2:  .asciiz "Enter the way of computing average (1 for Arithmetic mean 2 for Median): "
  Error1:  .asciiz "The level required cannot be reached\n"
  Error2:  .asciiz "Invalid Input\n"

  .text
main:
################## Read from file and store to buffer as string ############################
  li $v0, 13 # system call for open file
  la $a0, fin
  li $a1, 0
  syscall 
  move $t0, $v0
  li $v0, 14   # Read to file just opened
  la $a1, buffer # address of buffer from which to write
  li $a2, 2004
  move $a0, $t0
  syscall
  ################## read float values from buffer and store them in float array ############################
  la $s0, array              #load address of array to s0
  la $t0, buffer              #load address of the string
  lb $t4, space
  lb $t5, line 
  lb $t6, dot 
  li $t7 , 10
  li $t2, 0		#before '.' value
  li $s1 , 0 		# columns counter
  li $s2, 1		# rows counter
  li $t3 , 0		#after '.' value
  li $t8 , 1		#10 power by (after '.' number of digits) 
 load:
  lb $t1, 0($t0)            #load byte of the string to t1
  beq $t6, $t1, dt	  #dot?  jump to dt
  beq $t4, $t1, addSpace  #space?  jump to addSpace
  beq $t5, $t1, addLine  #end of line?  jump to addLine
  beqz $t1, out		#end of file?  jump to out
  addiu $t1, $t1, -48        #convert char to integer
  mul $t2, $t2, $t7   	#multiply  by 10
  add  $t2, $t2, $t1   #add dec value of t1 to total
  addi $t0, $t0, 1         #position string
  j   load  
 dt:
  li $t3 , 0
  li $t8 , 1
  mtc1 $t2, $f2
  cvt.s.w $f2, $f2
 dloop:
  addi $t0, $t0, 1      
  lb $t1, 0($t0)            
  beq $t4, $t1, addSpace  
  beq $t5, $t1, addLine  
  beqz $t1, out
  addiu $t1, $t1, -48        
  mul $t3, $t3, $t7    #multiply  by 10
  add  $t3, $t3, $t1   #add dec value of t1 to sumtotal
  mul $t8, $t8, $t7    #multiply by 10
  j   dloop 
 addSpace:
  addi $s1, $s1, 1        
  j   next 
 addLine:
  addi $s2, $s2, 1 
  j   next 
 next: 
  mtc1 $t2, $f2
  cvt.s.w $f2, $f2
  mtc1 $t3, $f3
  cvt.s.w $f3, $f3
  mtc1 $t8, $f8
  cvt.s.w $f8, $f8
  div.s $f3,$f3,$f8    #divide after '.' values by t8
  add.s $f2,$f2 ,$f3	# add before '.' values to after '.' value 
  swc1  $f2, 0($s0)             #store float into the array
  addi $s0, $s0, 4         #position array
  addi $t0, $t0, 1         #position string
  li $t2, 0
  li $t3 , 0
  li $t8 , 1
  j   load                  # jump back to loop so we can compute next elements
 out:
  mtc1 $t2, $f2
  cvt.s.w $f2, $f2
  mtc1 $t3, $f3
  cvt.s.w $f3, $f3
  mtc1 $t8, $f8
  cvt.s.w $f8, $f8
  div.s $f3,$f3,$f8
  add.s $f2,$f2 ,$f3
  swc1  $f2, 0($s0)             #store last value into the array

  ################## check if the matrix can be down-sampeld to the level Given ############################ 
  div  $s1 ,$s1 , $s2	    	 
  addi $s1, $s1, 1         # Compute number of coulmns	
  mul $s3 ,$s1 ,$s2	    # number of elemnts in the matrix
  li $v0, 4
  la $a0, string1
  syscall
  li $v0, 5 # Getting user input
  syscall
  move $a3, $v0	  #level entered
  move $t4 ,$s1
  move $t5 ,$s2
  li $t1 ,2
  li $t2 ,1	#level counter
  beq $a3, $t2, error2   # an error will show if user enter 1 for the level 
 eloop:
  divu $t4 ,$t4, $t1		#divide rows by 2 untill we reach the required level or its not divisible
  mfhi $t3
  bnez $t3, error1
  divu $t5 ,$t5, $t1		#divide columns by 2 untill we reach the required level or its not divisible
  mfhi $t3
  bnez $t3, error1
  addi $t2,$t2 ,1
  blt $t2, $a3, eloop

################## check if user choose arithmetic or median ##########################  
  li $v0, 4
  la $a0, string2
  syscall
  li $v0, 5 # Getting user input
  syscall
  move $s0, $v0
  la  $t0, array
  li $t4, 1    #level counter
  beq $s0, 1, arithmetic
  beq $s0, 2, median
  j error2

####################  arithmetic mean function  ########################################   
 arithmetic:
  la $t1 ,output
  li $t2, 0    #matrix elemnts counter 
  lwc1 $f6 , w1
  lwc1 $f7 , w2
 aloop:
  mov.s $f5 , $f0
  l.s  $f1, 0($t0)
  addi  $t0, $t0,4      #position array
  l.s  $f2, 0($t0)
  addi  $t0, $t0,4  
  l.s  $f3, 0($t0)
  addi  $t0, $t0,4   
  l.s  $f4, 0($t0)
  li $a2, 2
  addi $t5 ,$t4 ,1     # check if next level is even or odd?
  divu $t8 ,$t5, $a2 
  mfhi $t3
  bnez $t3, odd
 even:
  mul.s $f1,$f1,$f6
  add.s $f5,$f5,$f1
  mul.s $f2,$f2,$f7
  add.s $f5,$f5,$f2
  mul.s $f3,$f3,$f7
  add.s $f5,$f5,$f3
  mul.s $f4,$f4,$f6
  add.s $f5,$f5,$f4
  j cont
 odd:
  mul.s $f1,$f1,$f7
  add.s $f5,$f5,$f1
  mul.s $f2,$f2,$f6
  add.s $f5,$f5,$f2
  mul.s $f3,$f3,$f6
  add.s $f5,$f5,$f3
  mul.s $f4,$f4,$f7
  add.s $f5,$f5,$f4
 cont:
  li $t8 ,4
  mtc1 $t8, $f8
  cvt.s.w $f8, $f8
  div.s $f5 ,$f5 ,$f8	# divide sum by 4
  swc1  $f5, 0($t1)
  addi $t1, $t1, 4         #position output
  addi  $t0, $t0,4    
  addi  $t2, $t2,4  
  blt $t2, $s3, aloop  	    #keep going untill we do all the elemnts of the matrix
  la $t0 ,output
  div $s1 ,$s1 ,2	# recompute the column and rows counter (divide by 2)
  div $s2 ,$s2 ,2
  mul $s3 ,$s2 ,$s1
  addi $t4 ,$t4 , 1
  blt $t4, $a3, arithmetic   #keep going untill reach the required level
  j finish
####################  median   function #########################################      
 median:
  la $t1 ,output
  li $t2, 0
 mloop:
  mov.s $f5 , $f0
  l.s  $f1, 0($t0)
  addi  $t0, $t0,4
  l.s  $f2, 0($t0)
  addi  $t0, $t0,4 
  l.s  $f3, 0($t0)
  addi  $t0, $t0,4  
  l.s  $f4, 0($t0)
  c.lt.s $f1, $f2  	  # save the smallest value in f1 and the largest value in f4 and find the maen of f2 and f3
  bc1f notLess1          # if false, branch
  mov.s $f6,$f1		  #switch f1 and f2
  mov.s $f1,$f2
  mov.s $f2,$f6
 notLess1:
  c.lt.s $f1, $f3  
  bc1f notLess2          # if false, branch
  mov.s $f6,$f1
  mov.s $f1,$f3
  mov.s $f3,$f6
 notLess2:
  c.lt.s $f1, $f4  
  bc1f notLess3          # if false, branch 
  mov.s $f6,$f1
  mov.s $f1,$f4
  mov.s $f4,$f6
 notLess3:
  c.le.s $f4, $f2  
  bc1t  notGreater1          # if true, branch
  mov.s $f6,$f4
  mov.s $f4,$f2
  mov.s $f2,$f6
 notGreater1:
  c.le.s $f4, $f3  
  bc1t  notGreater2          # if true, branch
  mov.s $f6,$f4
  mov.s $f4,$f3
  mov.s $f3,$f6
 notGreater2:
  add.s $f5,$f5,$f3
  add.s $f5,$f5,$f2
  li $t3 ,2
  mtc1 $t3, $f8
  cvt.s.w $f8, $f8
  div.s $f5 ,$f5 ,$f8
  swc1  $f5, 0($t1)             #store into the output
  addi $t1, $t1, 4        
  addi  $t0, $t0,4      
  addi  $t2, $t2,4    
  blt $t2, $s3, mloop       	 #keep going untill we do all the elemnts of the matrix
  la $t0 ,output
  div $s1 ,$s1 ,2
  div $s2 ,$s2 ,2
  mul $s3 ,$s2 ,$s1
  addi $t4 ,$t4 , 1
  blt $t4, $a3, median    	#keep going untill reach the required level
  j finish
####################  convert float values to string   #########################################      
 finish:
  la $t0 ,output
  la $t1 ,outBuffer
  li $t2 , 0
  li $s6 , 1 # counter to print a line
 ploop:
  l.s $f1 ,0($t0)
  mov.s $f2 , $f1	# f1 has the value before '.' and f2 has the value after
  cvt.w.s $f1 , $f1
  mfc1 $t3 , $f1
  li   $t9, -1
  addi $sp, $sp, -4         # make space on stack
  sw   $t9, ($sp)           # and save -1 (end of stack marker) on MIPS stack
 push:		# Write the before '.' intger into buffer by pushing it on stack then pop it
  divu $t3 ,$t3, 10 
  mfhi $t9
  addi $sp, $sp, -4         # save digit on stack
  sw   $t9, ($sp)
  blez $t3 ,pop
  j push
 pop:
  lw   $t9, ($sp)           # $t9 = pop off "digit" from MIPS stack
  addi $sp, $sp, 4
  beq  $t9, -1 ,done
  addiu $t9, $t9, 48        #convert intger to char
  sb $t9, 0($t1)
  addiu $t1 ,$t1 ,1
  j pop
 done:
  li $t9 , '.'  # Write '.'  into buffer
  sb $t9, 0($t1)
  addiu $t1 ,$t1 ,1
  cvt.s.w $f1 , $f1
  sub.s $f2 , $f2 ,$f1
  li $t4, 100
  mtc1 $t4, $f4
  cvt.s.w $f4, $f4
  mul.s $f2 , $f2 ,$f4
  cvt.w.s $f2 , $f2
  mfc1 $t5 , $f2
  li   $t9, -1
  addi $sp, $sp, -4         # make space on stack
  sw   $t9, ($sp)           # and save -1 (end of stack marker) on MIPS stack
 push1:		# Write the after '.' intger to buffer by pushing it on stack then pop it
  divu $t5 ,$t5, 10 
  mfhi $t9
  addi $sp, $sp, -4         # make space on stack
  sw   $t9, ($sp)
  blez $t5 ,pop1
  j push1
 pop1:
  lw   $t9, ($sp)           # $t9 = pop off "digit" from MIPS stack
  addi $sp, $sp, 4
  beq  $t9, -1 ,done1
  addiu $t9, $t9, 48        #convert integer to char
  sb $t9, 0($t1)
  addiu $t1 ,$t1 ,1
  j pop1
 done1:
  blt  $s6 , $s1 , wspace
  li $s6 ,0		# write line after the counter reach the number of coulmns
  li $t9 , '\n'
  sb $t9, 0($t1)
  j wLine
 wspace:
  li $t9 , ' '
  sb $t9, 0($t1)
 wLine:
  addiu $t1 ,$t1 ,1
  addiu $t2 ,$t2 ,1
  addiu $t0 ,$t0 ,4
  addiu $s6 ,$s6 ,1
  blt $t2, $s3, ploop
##############################  write output on the file   #########################################      
  la $a0, fout # system call for open file
  li $a1, 1 
  li $v0, 13 
  syscall
  move $t0, $v0
  li $v0, 15 # system call for write to file
  la $a1, outBuffer # address of buffer from which to write
  li $a2, 2004 
  move $a0, $t0
  syscall
  li $v0, 16 # system call for close file
  move $a0, $t0 
  syscall
  li $v0, 10
  syscall 
  j noError
##############################  print Errors   #########################################      
 error1:
  la $a0, fout # system call for open file
  li $a1, 1 
  li $v0, 13 
  syscall
  move $t0, $v0
  li $v0, 15 # system call for write to file
  la $a1, Error1 # address of buffer from which to write
  li $a2, 38 
  move $a0, $t0
  syscall
  li $v0, 16 # system call for close file
  move $a0, $t0 
  syscall
  li $v0, 10
  syscall 
  j noError
 error2:
  la $a0, fout # system call for open file
  li $a1, 1 
  li $v0, 13 
  syscall
  move $t0, $v0
  li $v0, 15 # system call for write to file
  la $a1, Error2 # address of buffer from which to write
  li $a2, 38
  move $a0, $t0
  syscall
  li $v0, 16 # system call for close file
  move $a0, $t0 
  syscall
  li $v0, 10
  syscall 
  j noError
 noError:
