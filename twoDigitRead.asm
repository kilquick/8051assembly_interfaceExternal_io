;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> twoDigitRead.asm
;*
;*	>> Assembly source to read each NIBBLE of BYTE
;*	-> [dependency] :> Included in 8051 main.asm
;*
;**************************************************************

twoDigitRead:
	;uses R6 and R0
	;output on A
	push 6
	push 0
	ACALL CHECK	;output message, get address
	ACALL LCD_DATA
	;check to see if it's a number or hexletter
	mov r6, A	;temporary hold
	clr c
	subb A,#41h
	jc foundNumber_src	;no carry set, then it's a number
	mov A, r6
	clr c
	subb a, #37h
	Swap A
	Mov R0, A
	jmp NextAddressDigit_src
foundNumber_src:
	mov A, r6
	ANL A, #0FH
	SWAP A
	MOV R0, A	;GET FIRST NIBBLE (UPPER)
NextAddressDigit_src:
	ACALL CHECK	;output message, get address
	ACALL LCD_DATA	
	mov r6, A	;temporary hold
	clr c
	subb A,#41h
	jc foundNumber2_src	;no carry set, then it's a number
	mov A, r6
	clr c
	subb a, #37h
	ORL A, R0
	jmp doneInputAddress_src
foundnumber2_src:
	mov A, r6
	ANL A, #0FH
	ORL A, R0	;GET SECOND NIBBLE (UPPER)
doneInputAddress_src:
	pop 0
	pop 6
	ret