;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> memcheck.asm
;*	 
;*	0) Prompt user BYYTE to write
;*	1) Write to each RAM location user BYTE
;*	2) Read from each RAM location and compare
;*	3) If the read data is not same BYTE then throw error and print address
;*	4) Invert BYTE and repeat 1-3
;*	5) Print status and exit
;*
;*	[!] [dependency] :> Included in 8051 main.asm
;*
;**************************************************************

good: db 'MEMORY TEST PASS~'
bad: db 'INVALID: 0x~'
writebyte: db 'WriteByte: ~'
checking: db '[Testing] <~'

MemoryTest:
	MOV DPTR, #WRITEBYTE
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	LCALL TWODIGITREAD
	MOV B, A		;Store Byte
	MOV DPTR, #CHECKING
	LCALL LCD_NEWLINE
PASS1:	MOV A, B		;Restore Byte
	MOV DPL, #08H		;Starting RAM index
	MOV DPH, #00H		
	ACALL WRITE_0x08_0x7F	;write until SP
	mov dpl, #08h		;Starting RAM index
	mov dph, #00h		
	ACALL READ_0x08_0x7F	;read back data, see if it's good
PASS2:	MOV A, B		;Restore Byte
	CPL A			;invert byte
	MOV B, A		;store shifted byte
	MOV DPL, #08H		;Starting RAM index
	MOV DPH, #00H	
	ACALL WRITE_0x08_0x7F	;write until SP
	mov dpl, #08h		;Starting RAM index
	mov dph, #00h		;reset address
	ACALL READ_0x08_0x7F	;read back data, see if it's good
exiting:
	MOV A, #3EH		; > ASCII
	LCALL LCD_DATA		; progress bar closing bracket
	LCALL DELAY_short
	LCALL DELAY_short
	MOV DPTR, #GOOD
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	MOV DPTR, #PRESSANYKEY
	LCALL LCD_NEWLINE
	LCALL CHECK
	LJMP MENU4

;---------------------------------------------
WRITE_0x08_0x7F:
	Mov R0, DPL
	ACALL 	RAM_write
	INC DPTR		;increment 
	CJNE R0, #7Fh, WRITE_0x08_0x7F
	MOV A, #2AH	; * ascii
	LCALL LCD_DATA	; Update LCD PROGRESS BAR
	RET

READ_0x08_0x7F:
	MOV R0, DPL
	ACALL RAM_READ
	CJNE A, B, Error_memtest
	inc dptr		;increment if good
	CJNE R0, #7FH, READ_0x08_0x7F
	MOV A, #2AH	; * ascii
	LCALL LCD_DATA	; Update LCD PROGRESS BAR
	RET
	
;---------------------------------------------

Error_MemTest:	;didn't read correct value back
	MOV A, #3EH		; > ASCII
	LCALL LCD_DATA		; print closign bracket
	push dph
	push dpl
	MOV DPTR, #bad	;dptr address location
	LCALL LCD_STRING
	pop dpl
	pop dph
	mov R0, dph
	lcall ascii_address	;prints the ascii form of R0 to screen
	mov r0, dpl
	lcall ascii_address	; INVALID: 0xXXXXH
	mov DPTR, #RESTARTKEY
	LCALL LCD_NEWLINE	
	LCALL CHECK	;wait for input then exit
	LJMP RESTART
;---------------------------------------------

RAM_write:	;WRITES A TO RAM
	MOV @R0, B
	ret

RAM_read:	;READS RAM TO A
	MOV A, @R0
	ret
