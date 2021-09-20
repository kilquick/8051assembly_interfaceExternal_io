;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> count.asm
;*	
;*	**Writes count to RAM
;*	 *Backpacks off of find algorithm
;*
;*	[!] [dependency] :> Included in 8051 main.asm
;*
;**************************************************************

count: DB 'COUNT: ',0		;null space memory buffer for appending COUNT strinG

write_count:
	PUSH 0
	PUSH 3
	MOV DPTR, #count	;load ROM pointer
	MOV R0, #10H 		;load RAM pointer
get_mem:										
	CLR A										
	MOVC A,@A+DPTR		;Move data from code space				
	JZ set_mem
	MOV @R0, A		;SAVE in RAM at address stored in R0 0x10		
	INC DPTR		;INC ROM POINTER					
	INC R0			;INC RAM POINTER					
	SJMP get_mem
set_mem:
	MOV @R0, A		;Write COUNT ascii to MEMORY ADDRESS	
	MOV A, #0C0H		;newline cmd for LCD
	LCALL LCD_CMD		;print new line
	call convert_ascii
	MOV @R0, A
	INC R0			;NEXT MEMORY LOCATION
	MOV B, #7EH		;Delimiter ASCII				
	MOV @R0, B		;Write DelimIT ~ to RAM as HEX
	MOV R0, #10H		;Reset address index
	MOV R3, #40H		;R3 holds LCD cmd -> new line

PRINTED:
	MOV A, @R0		;Print count from RAM until delimiter
	LCALL LCD_CHAR
	INC R0
	CJNE @R0, #7EH, PRINTED
	MOV A, #20H		; SPACE
	LCALL LCD_CHAR		; PRINT WHITESPACE
	MOV A, #3CH		; <
	LCALL LCD_CHAR
	MOV A, #20H
	LCALL LCD_CHAR		; SPACE
	MOV A, #3EH		; >
	LCALL LCD_CHAR
	MOV A, #10H		;shift left
	lcall lcd_cmd		; send cmd
	mov a, #10h
	lcall lcd_cmd
	POP 3
	POP 0	
	RET
;**************************************************************
;**************************************************************
convert_ASCII:
	MOV A, R4
	Swap A
	Anl A, #0Fh	;get first digit of r0 (address)
	clr c
	Subb A, #0Ah
	jnc convert_letter
	mov A, R4	;THIS IS AN ASCII NUMBER
	SWAP A
	ANL A, #0FH
	ORL A, #30h	;ascii it up
	mov b, a	;yo
	jmp ascii_digit_done1
convert_letter:
	MOV A,R4	;THIS IS AN ASCII LETTER
	SWAP A
	ANL A, #0FH
	Add A, #37H	;ascii it up again
ascii_digit_done1:
	MOV A,R4
	Anl A, #0Fh	;get second digit of r0 (address)
	clr c
	Subb A, #0Ah
	jnc convert_letter2
	mov A, R4	;THIS IS AN ASCII NUMBER
	ANL A, #0FH
	ORL A, #30h	;ascii it up
	jmp ascii_digit_done2
convert_letter2:
	MOV A,R4	;THIS IS AN ASCII LETTER
	ANL A, #0FH
	Add A, #37H	;ascii it up again
ascii_digit_done2:
	mov B, A
	ret
