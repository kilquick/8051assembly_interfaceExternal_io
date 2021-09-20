;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> move.asm
;*
;*	>> Assembly source to copy memory block data between locations
;*	-> [dependency] :> Included in 8051 main.asm
;*
;**************************************************************

sourceaddress: db 'SrcAddress: ~'
destaddress: db 'DestAddress: ~'

moveStart:
	mov dptr, #sourceaddress
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING	
	Acall twoDigitRead	;get value in A
	Mov R0, A	;src in R0

	MOV DPTR, #destaddress
	ACALL LCD_NEWLINE
	Acall twoDigitRead	;get value in A
	Mov R1, A	;dest in R1
inputBlocksize:
	LCALL ASKDATATYPE
	ACALL LCD_DATA
	LCALL ASKBLOCKSIZE
	
loopy:
	mov A, @R0	;get data at source
	mov @R1, A	;put data in destination

	mov a, r0
	clr c
	Subb a, #0FFh
	jz badAddress	;if FF then done
	
	mov a, r1
	clr c
	Subb a, #0FFh
	jz badAddress
	
	inc R0
	inc R1
	djnz r4, loopy	;loop blocksize number of times
	
badAddress:
	MOV DPTR, #PressAnyKey
	ACALL lcd_newline
	acall check
	ljmp menu1
	