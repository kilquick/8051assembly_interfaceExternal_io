;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> edit.asm
;*
;*	>> Assembly source to directly edit memory block location(s) and block data.
;*	-> [dependency] :> Included in 8051 main.asm
;*
;**************************************************************

startingAddress: DB 'EditAddress: ~'
enterData: DB 'NewHexValue: ~'
cmd0: DB '<0>Next Address~'
cmd1p: DB '<1>Prev Address~'
cmd1e: DB '<1>Exit to Menu~'
cmdC: DB '<C>Skip Thru2End~'
cmdE: DB '<E>Exit to Menu~'

editStart:
	MOV DPTR, #startingAddress
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
	ACALL twoDigitRead	;get value in A
	
editAddress:
	MOV R1, A	;Store memory address
	
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT	;clear screen, reset

	MOV A, R1
	MOV R0, A	;set up R0 for Ascii_address
	
	ACALL Ascii_address	;print out address
	MOV A, #3AH
	ACALL LCD_DATA		;COLON PRINT
	MOV A, @R1	;get data at inputted address
	MOV R0, A	;move that data to R0 for printing
	ACALL Ascii_address	;call ascii_address to print contents
	
	MOV DPTR, #enterData
	ACALL LCD_Newline
	ACALL twoDigitRead	;get value in A
	MOV @R1, A	;move new data to memory spot 

askToContinue:
	MOV DPTR, #cmd0		;Lab explicitly states 0 next
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
	MOV DPTR, #cmd1e	;Lab explicitly states 1 exit (I'd prefer E)
	ACALL LCD_NEWLINE
	ACALL Check
	CJNE A, #30h, checkExit	;checks 0
editNextAddress:
	INC R1		;next sequential address
	MOV A, R1
	JMP editAddress
checkExit:
	CJNE A, #31h, Invalidinput	;checks 1
	LJMP menu2
invalidinput:			;neither 0 nor 1 input
	MOV DPTR, #ERRORMSG1
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
	MOV DPTR, #ERRORMSG2
	ACALL LCD_NEWLINE
	JMP ASKTOCONTINUE
