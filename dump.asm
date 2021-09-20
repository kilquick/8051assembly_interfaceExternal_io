;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> dump.asm
;*
;*	>> Assembly source to dump memory data block to LCD
;*	[!] [dependency] --> Included in 8051 main.asm
;*
;**************************************************************

addressmessage: db 'Address: ~'
sizemessage: db 'Size: ~'
sizeerror: db 'SIZE ERROR~'
dump_menu: db '1:Prv/0:Nxt/E:Ex~'
dumpstart:
	PUSH 6		;Preserve R6=0
	PUSH 7		;Preserve R7=0
	;ACALL storeRegstoMem
	mov dptr, #addressmessage
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
	ACALL CHECK	;output message, get address
	ACALL LCD_DATA
	;check to see if it's a number or hexletter
	mov r6, A	;temporary hold
	clr c
	subb A,#41h
	jc foundNumber	;no carry set, then it's a number
	mov A, r6
	clr c
	subb a, #37h
	Swap A
	Mov R0, A
	jmp NextAddressDigit
foundnumber:
	mov A, r6
	ANL A, #0FH
	SWAP A
	MOV R0, A	;GET FIRST NIBBLE (UPPER)
NextAddressDigit:
	ACALL CHECK	;output message, get address
	ACALL LCD_DATA	
	mov r6, A	;temporary hold
	clr c
	subb A,#41h
	jc foundNumber2	;no carry set, then it's a number
	mov A, r6
	clr c
	subb a, #37h
	ORL A, R0
	Mov R0, A
	jmp doneInputAddress
foundnumber2:
	mov A, r6
	ANL A, #0FH
	ORL A, R0	;GET SECOND NIBBLE (UPPER)
	Mov R0, A	
doneInputAddress:
	;YOU NOW HAVE THE ADDRESS IN A & R0
	;Mov R2, A	;REDUNDANT ADDRESS STORAGE
	LCALL AskDataType
	ACALL LCD_DATA
	LCALL ASKBLOCKSIZE
	;check to see if it's a number or hexletter
	mov r6, A	;temporary hold
	clr c
	subb A,#41h
	jc foundNumber3	;no carry set, then it's a number
	mov A, r6
	clr c
	subb a, #37h
	Swap A
	Mov R1, A
	jmp NextSizeDigit
foundnumber3:
	mov A, r6
	ANL A, #0FH
	SWAP A
	MOV R1, A	;GET FIRST NIBBLE (UPPER)
NextSizeDigit:
	mov r6, A	;temporary hold
	clr c
	subb A,#41h
	jc foundNumber4	;no carry set, then it's a number
	mov A, r6
	clr c
	subb a, #37h
	ORL A, R1
	Mov R1, A
	jmp doneInputSize
foundnumber4:
	mov A, r6
	ANL A, #0FH
	ORL A, R1	;GET SECOND NIBBLE (UPPER)
	Mov R1, A
doneInputSize:
	Mov R5, A	;save max size
	;R0 = ADDRESS, R1 = SIZE, R5 = ORIGINAL BLOCK SIZE
;**************************************************
	;DISPLAY USING R0 = ADDRESS, R1 = SIZE, 
	;R4 = Counter,
	CJNE A, #0H, validSize	;if(size == 0){err}
	mov dptr, #sizeerror
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
	ljmp dumpstart
validSize:
	clr c
	SUBB A, #04h
	jc lessThanfourNode	;check if it's <4, if so print it out
comeback:
	mov r4, #04h	;print 4 2digit hex numbers
	Mov A, r1	;check again
	clr c
	SUBB A, #04h
	JNC NotZero	; if it's >4 then print menu and dump
	
	mov dptr, #pressanykey	; otherwise, print dump, and quit.
	acall LCD_newline
	acall check
	ljmp MENU1
NotZero:	;specify r4 = counter before calling
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT ;firt print the address
	acall ascii_address	;print address
	MOV A, #3AH
	ACALL LCD_DATA		;COLON PRINTED\
	;mov r4, #04h		;4 2digit numbers to print
	acall ascii_dump	;print dump
	ljmp print_dump_menu	;print menu
	
lessThanfourNode:
	acall special_print
	ljmp comeback
;**********************************************************
;ASCII CONVERSIONS AND PRINTING
;***********************************************************
ascii_address:
	;R0 = address
	MOV A,R0
	Swap A
	Anl A, #0Fh	;get first digit of r0 (address)
	clr c
	Subb A, #0Ah
	jnc ascii_letter
	mov A, R0	;THIS IS AN ASCII NUMBER
	SWAP A
	ANL A, #0FH
	ORL A, #30h	;ascii it up
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
	jmp ascii_address_done1
ascii_letter:
	MOV A,R0	;THIS IS AN ASCII LETTER
	SWAP A
	ANL A, #0FH
	Add A, #37H	;ascii it up again
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
ascii_address_done1:

	MOV A,R0
	Anl A, #0Fh	;get second digit of r0 (address)
	clr c
	Subb A, #0Ah
	jnc ascii_letter2
	mov A, R0	;THIS IS AN ASCII NUMBER
	ANL A, #0FH
	ORL A, #30h	;ascii it up
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
	jmp ascii_address_done2
ascii_letter2:
	MOV A,R0	;THIS IS AN ASCII LETTER
	ANL A, #0FH
	Add A, #37H	;ascii it up again
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
ascii_address_done2:
	ret

;**********************
;ASCII DUMP PROCEDURE
;**********************

ascii_dump:
	;R0 = address
	;SET R4 previously to calling this function
	;R4 = num of characters printed
	mov A, r4
	push A
ascii_dump_redo:
	MOV A,@R0
	Swap a
	Anl A, #0Fh	;get first digit of Data at r0 (address)
	clr c
	Subb A, #0Ah
	jnc ascii_letter3
	mov A, @R0	;THIS IS AN ASCII NUMBER
	SWAP A
	ANL A, #0FH
	ORL A, #30h	;ascii it up
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
	jmp ascii_dump_done2
ascii_letter3:
	MOV A,@R0	;THIS IS AN ASCII LETTER
	SWAP A
	ANL A, #0FH
	Add A, #37H	;ascii it up again
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
ascii_dump_done2:

	MOV A,@R0
	Anl A, #0Fh	;get second digit of Data at r0 (address)
	clr c
	Subb A, #0Ah
	jnc ascii_letter4
	mov A, @R0	;THIS IS AN ASCII NUMBER
	ANL A, #0FH
	ORL A, #30h	;ascii it up
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
	jmp ascii_dump_done3
ascii_letter4:
	MOV A,@R0	;THIS IS AN ASCII LETTER
	ANL A, #0FH
	Add A, #37H	;ascii it up again
	ACALL LCD_DATA	;FIRST NUM OF ADDRESS
ascii_dump_done3:
	mov A, R0
	cjne a, #0FFh, DoStuff
	
	Mov A, R0	;HIT TOP OF RAM #FFh
	clr c
	Subb A, r4
	mov R0, A	;decrement r0 back to where it came from
	Mov A, R1
	add A, r4
	mov R1, A	;increment r1 back to where it came from
	Mov R4, #00h	;clear counter
	Pop A		
	mov r4, A	;get value of r4 back.
	ret
	
DoStuff:
	Inc R0	;not top of ram
	Dec R1
	DJNZ r4, ascii_dump_redo
	Pop A
	mov r4, A	;get value of r4 back.
	ret




;********************************************************
	;now print the MENU1 after dumping
print_dump_Menu:
	mov dptr, #dump_menu
	ACALL LCD_Newline
	ACALL Check		;get input for what to do
	cjne a,#30h,checknext1
	jmp dump_next		;if 0 was entered, execute next method
checknext1:
	cjne a,#31h,checknext2
	jmp dump_previous	;if 1 was entered, execute previous method
checknext2:
	clr c
	subb a, #45h
	jnz invalid_dump_Input	;if it's not zero, it's a bad entry
	;ACALL GetRegsFromMem
	POP 7
	POP 6
	ljmp menu1		;if * was entered, go to starting menu
Invalid_dump_Input:
	mov dptr, #ERRORMSG1
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
;	jmp reprintMenu		;display error message, then redisplay dump/menu
reprintMenu:
	Mov A, R0
	clr c
	Subb A, #04h
	Mov R0, A
	Mov A, R1
	Add A, #04h
	Mov R1, A
	ljmp notzero
;**************************************************
	;DISPLAY USING R0 = ADDRESS, R1 = SIZE, 
	;R4 = Counter, R5 = 0RIGINAL BLOCK SIZE
dump_next:
	;1. check if zero
	;2. check if less than 4
	;3. 
	mov A, R0
	cjne a, #0FFh, keepgoing
	ljmp reprintmenu
keepgoing:
	MOV A, R1
	Jz reprintMenu	;if Size = 0, then just reprint menu
	clr c
	SUBB A, #04h
	jc LessThanFour_Next	;if less than 4, go do stuff over there
	mov r4, #04h	;4 2digit hex values
	ljmp notzero	;otherwise, print the next 4 as normal
Lessthanfour_Next:
	Acall special_print
	ljmp print_dump_menu
LessThanFour:
	Acall Special_print
	ret
Special_print:	;prints a page < 4 after a next input
	;will readjust the address and size to keep it consistant
	;after printing (will not change address or size left)
	;r1 = size < 4
	;r0 = address
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT	;reset lcd
	acall ascii_address
	MOV A, #3AH
	ACALL LCD_DATA		;COLON PRINTED\
	mov A, r1	;Current size
	mov r4, a	;save current number of chars left
	acall ascii_dump;pass r4 
	mov a, r4
	mov r1, a	;get current size back
	mov B, A	;B now has current size
	mov A, r0	;current wrong address
	clr c
	Subb A, B	;Current address - number of spots advanced
			; = GoodAddress
	Mov R0, A	;r0 now has correct address. 
	Mov R7, #01h	;R7 used to check that we just printed this.
	ret

dump_previous:
	;if add 8 to current size and it's equal to maximum size, then 
	;we know it's at the most previous page.
	;1. Check size limit (Current size - 4)
	;2. If current size - 4 results in a carry, then - at a high limit
	;3. If current size - 4 results no carry, then in middle or bottom
	Mov A, R0	;move calculated address to A
	Mov B, R2	;move starting addresss to B
	clr c
	subb A, B
	jc resetAddress
	jz topReprint
	
	Mov A, R1	;get current size
	add a, #04h	;add 4 that were just printed
	clr c 
	subb a, r5
	jz checkIfTop	;reprint menu if at starting point 


	Mov A, R1	;get current size
	clr c
	subb a, #04h	;check size limit
	jc atTopLimit	;if carry, then R1 < 4 which means top limit

	jmp previous_address
topReprint:
	ljmp notzero
checkIfTop:
	;either reset r4 = 4 or only jump reprintMenu
	mov A, r7
	cjne a, #01h, notSet
	mov r4, #04h	;reset counter
	jmp reprintmenu
notSet:
	jmp reprintmenu
atTopLimit:
	;need to treat top limit differently because the address
	;doesn't increment when the dump has < 4 2digit hex nums printed
	mov a, r7
	cjne a, #01h, previous_address
	mov A, R0	;get current address
	clr c
	subb A, #04h	;subtract only 4
	Mov R0, A
	Mov A, R1	;get current size
	Add A, #04h	;add 4 back
	Mov R1, A	;put it back
	Mov R4, #04h	;print 4 characters
	mov r7, #00h	;clear r7
	Ljmp Notzero	;print it 4 points back from current

	;otherwise, proceed below
previous_address:
	mov A, R0
	clr c
	Subb A, #08h
	Mov R0, A	;get current address - 8
	Mov A, R1	;get current size
	Add A, #08h	;add 8 to it.
	Mov R1, A	;put it back
	Mov R4, #04h	;print 4 characters, c'mon!

	Ljmp Notzero	;start printing at R0 -8 with R1 +8 points ahead of it
resetAddress:
	mov A, R2	;holds starting address
	Mov R0, A
	ljmp Notzero	;if address ever goes below starting address, reset.



