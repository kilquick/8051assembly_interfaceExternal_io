;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> datatype.asm
;*	
;*	**Validates user data type and block size input
;*
;*	[!] [dependency] :> Included in 8051 main.asm
;*
;**************************************************************

datatype: DB 'DATA TYPE SEL: ~'
datatypes: DB '1:BYT/2:WRD/3:DW~'
typetop: DB '1:BYTE / 2:WORD~'
typebot: DB '3:DW   / E:EXIT ~'
blocksize: DB 'BlockSize: ~'
BlockSizeError: db 'SIZE/TYPE ERROR ~'
zerosizeERROR: db 'SIZE ZERO ERROR ~'

askDataType:
	MOV DPTR, #DATATYPES
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
seltype:
	MOV DPTR, #DATATYPE
	LCALL LCD_NEWLINE
	LCALL CHECK
	CJNE A, #31H, notByte	; <1> is pressed
	MOV B, #01H		; MIPS Byte= 8 bits --> Size = 1 block
	RET
notByte:
	CJNE A, #32H, notWord	; <2> is pressed
	MOV B, #04H 		; MIPS Word= 16 bits --> Size = 4 blocks
	RET
notWord:
	CJNE A, #33H, notDWord	; <3> is pressed
	MOV B, #08H		; MIPS dWword= 32 bits --> Size = 8 blocks
	RET
notDWord: 
	JMP SELTYPE

;******************************************************

askBlockSize:
	PUSH B
	MOV DPTR, #BlockSize
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING	
	Lcall twoDigitRead	;get value in A
	jz zeroblocksize	;if A = 0 then that's a no no
	Mov R3, A	;blocksize in R3
	POP B 		;compare chosen data type with block size
	clr c
	subb A, B
	jz goodBlockSize
	jnc badBlockSize
	jmp goodblocksize
zeroBlockSize:
		;redo input of blocksize
	MOV DPTR, #zerosizeerror
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	POP B
	ljmp ASKBLOCKSIZE
badBlocksize:
		;redo input of blocksize
	MOV DPTR, #BlockSizeError
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	ljmp ASKBLOCKSIZE
goodBlockSize:
	mov A, r3	;move blocksize
	mov R4, A	;r4 = counter
	RET