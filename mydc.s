
	.equ   ARRAYSIZE, 20
	.equ   EOF, -1
	
	.section ".rodata"

print:
	.asciz "%d\n"

scan:
	.asciz "%s"

errormsg:
	.asciz "dc: stack empty\n"
# --------------------------------------------------------------------

    .section ".data"

# --------------------------------------------------------------------

    .section ".bss"

buffer:
    .skip  ARRAYSIZE

# --------------------------------------------------------------------

	.section ".text"

	# -------------------------------------------------------------
	# int main(void)
	# Runs desk calculator program.  Returns 0.
	# -------------------------------------------------------------

	.globl  main
	.type   main,@function

main:
	pushl   %ebp
	movl    %esp, %ebp

input:
	# dc number stack initialized. %esp = %ebp
	
	# scanf("%s", buffer) 
	pushl	$buffer
	pushl	$scan
	call    scanf
	addl    $8, %esp

	# check if user input EOF
	cmp	$EOF, %eax
	je	quit

	# isdigit(char c)
	movzx	buffer, %edx    # saved buffer[0]
	pushl	%edx
	call	isdigit		    # boolean value is saved in a flag
	addl	$4, %esp	
	cmpl	$0, %eax	    # Checking output of isdigit
	jne	positive_number	    # if isdigit ture then goto positive_number
	
	# else if(c=='_')
	cmpl	$0x5F, %edx	    # checking condition c=='_'
	je	negative_number	    # if c=='_' then goto negative_number
	
	# else if(c=='p')
	cmpl	$0x70, %edx	    # checking condition c=='p'
	je	print_top	        # if(c=='p') then goto print_top
	
	# else if(c=='q')
	cmpl	$0x71, %edx	    # checking condition c=='q'
	je	quit		        # if(c=='q') then goto quit

	# else if(c=='+')
	cmpl	$0x2B, %edx	    # checking condition c=='+'
	je	plus		        # if(c=='+') then goto plus

	# else if(c=='-')
	cmpl	$0x2D, %edx	    # checking condition c=='-'
	je	minus		        # if(c=='-') then goto minus

	# else if(c=='*')
	cmpl	$0x2A, %edx	    # checking condition c=='*'
	je	multiply	        # if(c=='*') then goto multiply

	# else if(c=='/')
	cmpl	$0x2F, %edx	    # checking condition c=='/'
	je	divide		        # if(c=='/') then goto divide

	# else if(c=='%')
	cmpl	$0x25, %edx     # checking condition c=='%'
	je	mod		            # if(c=='%') then goto mod

	# else if(c=='^')
	cmpl	$0x5E, %edx	    # checking condition c=='^'
	je	power		        # if(c=='^') then goto power

	# else if(c=='x')
	cmpl	$0x78, %edx	    # checking condition c=='x'
	je get_random			# if(c=='x') then goto get_random

	# else if(c=='f')
	cmpl	$0x66, %edx	    # checking condition c=='f'
	je	print_elements	    # if(c=='f') then goto print_elements

	# else if(c=='c')
	cmpl	$0x63, %edx	    # checking condition c=='c'
	je	clear		        # if(c=='c') then goto clear
 
	# else if(c=='d')
	cmpl	$0x64, %edx	    # checking condition c=='d'
	je	duplicate	        # if(c=='d') then goto duplicate

	# else if(c=='r')
	cmpl	$0x72, %edx	    # checking condition c=='r'
	je	reverse		        # if(c=='r') then goto reverse

	jmp     input           # loop taking input again

positive_number:
	# strlen(buffer)
	pushl   $buffer			# pushing address
	call	strlen			# calling strlen
	addl	$4, %esp		# deallocate space for the address
	movl	$0, %ebx        # for(int i=0, i<str_len, i++)

valid_number_loop:
	cmpl	%eax, %ebx	    # Comparing i:str_len
	je	convert_number	    # converting string to number
	movzx	buffer(%ebx), %edi	# storing i-th char of the string
	cmpl	$0x30, %edi	    # Comparing char with '0'
	jl	input		        # If code for char < '0', goto input since we ignore the string
	cmpl	$0x39, %edi     # Comparing char with '9'
	jg	input		        # If code for char > '9', goto input since we ignore the string
	incl	%ebx		    # i++
	jmp	valid_number_loop   # checking next char

convert_number:
	# atoi(buffer)
	pushl	$buffer		    # pushing address
	call	atoi		    # calling atoi(buffer)
	addl	$4, %esp	    # deallocate space for the address
	pushl	%eax		    # pushing converted number onto the stack
	jmp	input		        # goto next input

negative_number:
	# strlen(buffer)
    pushl   $buffer			# pushing address
    call    strlen			# calling strlen
    addl    $4, %esp		# deallocate space for the address
    movl    $1, %ebx        # for(int i=1, i<str_len, i++)
	cmpl	%eax, %ebx	    # if(strlen==1)
	je	input		        # taking next input

loop_valid:
    cmpl    %eax, %ebx      # Comparing i:str_len
    je      negative_conv	# converting string to number
    movzx    buffer(%ebx), %edi       # storing i-th char of the string
    cmpl    $0x30, %edi     # Comparing char == '0'
    jl      input           # If code for char < '0', goto input since we ignore the string
    cmpl    $0x39, %edi     # Comparing char with '9'
    jg      input           # If code for char > '9', goto input since we ignore the string
    incl    %ebx            # i++
    jmp     loop_valid	    # checking next char

negative_conv:
	# atoi(buffer)
	leal	buffer, %edi	# storing address
	incl	%edi		    # pointing to the number
    pushl   %edi		    # pushing address of the number
    call    atoi            # calling atoi(buffer)
    addl    $4, %esp        # deallocate space for the address
	movl	$-1, %esi
	imull	%esi		    # making the number negative
    pushl   %eax            # pushing converted number onto the stack
    jmp     input           # goto next input
	
plus:
	leal	4(%esp), %edi	# %edi = stack_address+4
	cmpl	%ebp, %edi	    # Comparing %edi : %ebp
	jge	error		        # If => goto error because stack has at most one element
	popl	%edi		    # %edi	= b
    popl	%eax		    # %eax	= a
	addl	%edi, %eax	    # %eax = a + b
	pushl	%eax		    # push a + b
	jmp	input		        # taking next input

minus:
    leal    4(%esp), %edi   # %edi = stack_address+4
    cmpl    %ebp, %edi      # Comparing %edi : %ebp
    jge     error           # If => goto error because stack has at most one element
    popl	%edi		    # %edi	= b
    popl	%eax		    # %eax	= a
	subl	%edi, %eax	    # %eax = a - b
	pushl	%eax		    # push a - b
	jmp	input		        # taking next input

multiply:
    leal    4(%esp), %edi   # %edi = stack_address+4
    cmpl    %ebp, %edi      # Comparing %edi : %ebp
    jge     error           # If => goto error because stack has at most one element
    popl    %edi            # %edi = b
    popl    %eax            # %eax = a
    imull   %edi            # %eax = a * b
	pushl	%eax		    # push a * b
	jmp	input		        # taking next input

divide:
    leal    4(%esp), %edi   # %edi = stack_address+4
    cmpl    %ebp, %edi      # Comparing %edi : %ebp
    jge     error           # If => goto error because stack has at most one element
    popl    %edi            # %edi = b
    popl    %eax            # %eax = a
	cdq                     # Sign extend into %edx
    idivl   %edi            # %eax = a / b
	pushl	%eax		    # push a / b
	jmp	input		        # taking next input

mod:
    leal    4(%esp), %edi   # %edi = stack_address+4
    cmpl    %ebp, %edi      # Comparing %edi : %ebp
    jge     error           # If => goto error because stack has at most one element
    popl    %edi            # %edi = b
    popl    %eax            # %eax = a
    cdq                     # Sign extend into %edx
	idivl   %edi            # %edx = a % b
    pushl	%edx		    # push	a % b
    jmp	input		        # taking next input

print_top:	
	cmpl	%ebp, %esp	    # checking whether stack is empty
	je	error		        # if empty, goto error
	pushl   $print          # push "%d"
	call	printf		    # printf("%d", stack.peek())
	addl	$4, %esp	    # deallocate space for $print
	jmp	input		        # taking next input

duplicate:
	cmpl	%ebp, %esp	    # Comparing %esp:%ebp
	je	error		        # If == goto error because stack is empty
	movl	(%esp), %eax	# result = top element of the stack
	pushl	%eax		    # push duplicate onto the stack
	jmp	input		        # taking next input

reverse:
    leal    4(%esp), %edi   # %edi = stack_address+4
    cmpl    %ebp, %edi      # Comparing %edi : %ebp
    jge     error           # If => goto error because stack has at most one element
	popl	%eax		    # top element of the stack in %eax
	popl	%edi		    # second top element of the stack in %edi
	pushl	%eax		    # pushing original top element onto the stack
	pushl	%edi		    # pushing original second top element onto the stack
	jmp	input		        # taking next input

clear:	
	movl	%ebp, %esp	    # stack points at the base and all elements were deallocated
	jmp	input		        # taking next input

power:
    leal    4(%esp), %edi   # %edi = stack_address+4
    cmpl    %ebp, %edi      # Comparing %edi : %ebp
    jge     error           # If => goto error because stack has at most one element
    popl    %esi            # %esi = b
    popl    %edi            # %edi = a
	call	power_function	# calling power_function(a,b)
	push	%eax		    # pushing the result
	jmp	input		        # taking next input

get_random:
	pushl 	%eax			# pushing address
	call 	rand			# calling rand
	jmp input        		# taking next input

print_elements:
	movl	%esp, %ebx	    # save %esp in order to iterate over stack

print_loop:	
	cmpl	%ebp, %ebx	    # Comparing %ebx:%ebp
	je	input		        # If == goto input
	pushl	(%ebx)		    # push integer = %ebx
	pushl	$print	        # push "%d"
	call	printf		    # calling printf("%d", integer)
	addl	$4, %ebx	    # move to the next element on the stack
	addl	$8, %esp	    # deallocate space used for integer and print
	jmp	print_loop	        # loop untill stack will be empty

error:
	pushl	$errormsg		# pushing error message
	call	printf		    # calling printf
	addl	$4, %esp	    # deallocate stack memory allocated to error message
	jmp	input		        # taking next input

quit:	
	# return 0
	movl    $0, %eax
	movl    %ebp, %esp
	popl    %ebp
	ret

	.type power_function,@function

power_function:				
	movl	$1, %eax	    # make result=1

power_loop:	
	testl   %esi, %esi		# checking whether exponent is 0
	je	done		    	# if yes then goto done
	imull	%edi			# result*=x
	decl	%esi			# y--
	jmp	power_loop	    	# goto power_loop

done:
	ret			        	# returning the result
