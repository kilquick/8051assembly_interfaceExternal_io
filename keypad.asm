;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> keypad.asm
;*
;*	>> Assembly source to interface 8051 with MatrixKeypad for data entry.
;*	[!] [dependency] :> Included in 8051 main.asm
;*
;**************************************************************

;NEXTROW4 = ROW3 = PORT3 PIN 3
;NEGATIVE EDGE TRIGGERED
;PASSES BACK ASCII VALUE OF RADIO BUTTON
; * = F ascii value
; # = E ascii value
CHECK:
PAD_init:
	MOV A, #0F0H
	MOV B, A	;Store default state in B
	MOV P3, A	;MAKE 4 cols INPUT, 4 row OUT
GET_DATA:
	MOV A, P3	;P3 is keypad - store keypad data
	CJNE A, B, CHECK_ROWS
	SJMP GET_DATA
	
CHECK_ROWS:
	SETB P3.0	;SET ROW 1 - P3_BIT.0
	MOV A, P3	;GET R0W 1
	ANL A, #0F0H	;MASK
	CLR P3.0	;CLEAR P3_BIT.0
	MOV B, P3	;GET KEYPAD COLUMNS 
	
	;COMPARE COLUMNS AGAINST ROW MASK
	CJNE A,B, FOUNDROW1	;~>NOT EQUAL, FOUND ROW
	SJMP NEXTROW2		;~>EQUAL, KEEP GOING
FOUNDROW1:	;FOUND IN ROW 1
	JNB B.4, ONEPRESS	; 1 pressed
	JNB B.5, TWOPRESS	; 2 pressed
	JNB B.6, THREEPRESS	; 3 pressed
	JNB B.7, APRESS		; A pressed
APRESS:	;IF A = F0 MOVE ON
	MOV A, P3
	SUBB A, #0EFH
	JNZ APRESS
	mov a, #41H
	RET
ONEPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ ONEPRESS
	mov a, #31H
	RET
TWOPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ TWOPRESS
	mov a, #32H
	RET
THREEPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ THREEPRESS
	mov a, #33H
	RET

NEXTROW2:
	SETB P3.1	;SET ROW 2 - P3_BIT.1
	MOV A, P3	;GET R0W 2
	ANL A, #0F0H	;MASK
	CLR P3.1	;CLEAR ROW 2 - P3_BIT.1
	MOV B, P3	;GET KEYPAD COLUMNS 
	
	;COMPARE COLUMNS AGAINST ROW MASK
	CJNE A,B, FOUNDROW2	;~>NOT EQUAL, FOUND ROW
	SJMP NEXTROW3		;~>EQUAL, KEEP GOING
FOUNDROW2:	;FOUND IN ROW 2
	JNB B.4, FOURPRESS	; 4 pressed
	JNB B.5, FIVEPRESS	; 5 pressed
	JNB B.6, SIXPRESS	; 6 pressed
	JNB B.7, BPRESS		; B pressed
FOURPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ FOURPRESS
	mov a, #34H
	RET
FIVEPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ FIVEPRESS
	mov a, #35H
	RET
SIXPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ SIXPRESS
	mov a, #36H
	RET
BPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ BPRESS
	mov a, #42H
	RET
NEXTROW3:
	SETB P3.2	;SET ROW 3 - P3_BIT.2
	MOV A, P3	;GET R0W 3
	ANL A, #0F0H	;MASK
	CLR P3.2	;CLEAR ROW 3 - P3_BIT.2
	MOV B, P3	;GET KEYPAD COLUMNS 
	
	;COMPARE COLUMNS AGAINST ROW MASK
	CJNE A,B, FOUNDROW3	;~>NOT EQUAL, FOUND ROW
	SJMP NEXTROW4		;~>EQUAL, KEEP GOING
FOUNDROW3:	;FOUND IN ROW 3
	JNB B.4, SEVENPRESS	; 7 pressed
	JNB B.5, EIGHTPRESS	; 8 pressed
	JNB B.6, NINEPRESS	; 9 pressed
	JNB B.7, CPRESS		; C pressed
SEVENPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ SEVENPRESS
	mov a, #37H
	RET
EIGHTPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ EIGHTPRESS
	mov a, #38H
	RET
NINEPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ NINEPRESS
	mov a, #39H
	RET
CPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ CPRESS
	mov a, #43H
	RET
NEXTROW4:
	SETB P3.3	;SET ROW 4 - P3_BIT.3
	MOV A, P3	;GET R0W 4
	ANL A, #0F0H	;MASK
	CLR P3.3	;CLEAR ROW 3 - P3_BIT.3
	
	;COMPARE COLUMNS AGAINST ROW MASK
	CJNE A,B, FOUNDROW4	;~>NOT EQUAL, FOUND ROW
	LJMP CHECK_ROWS		;~>EQUAL, KEEP GOING
FOUNDROW4:	;FOUND IN ROW 2
	JNB B.4, STARPRESS	; * pressed
	JNB B.5, ZEROPRESS	; 0 pressed
	JNB B.6, POUNDPRESS	; # pressed
	JNB B.7, DPRESS		; D pressed
ZEROPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ ZEROPRESS
	mov a, #30H
	RET
DPRESS:
	MOV A, P3
	SUBB A, #0EFH
	JNZ DPRESS
	mov a, #44H
	RET
STARPRESS:		; * = F
	MOV A, P3
	SUBB A, #0EFH
	JNZ STARPRESS
	mov a, #46H	
	RET
POUNDPRESS:		; # = E
	MOV A, P3
	SUBB A, #0EFH
	JNZ POUNDPRESS
	mov a, #45H	
	RET

