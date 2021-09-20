;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> memcheck.asm
;*	 
;*	[!] [dependency] :> Included in 8051 main.asm
;*
;**************************************************************
;0) Prompt user byte to write
;1) Write to each RAM location user byte
;2) Read from each RAM location and compare to 55h
;3) If the read data is not 55h then throw error and print address
;4) Repeat for AAh
;5) If we cool, then say we cool, then go back to menu.
dataPointer: db 'DPTR:#'
good: db 'MEMORY GOOD#'
bad: db 'MEMORY BAD#'
MemoryTest:
	push 0
	push 1
	push 2
	mov dpl, #0h  
	mov dph, #0h
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LED_Latch_Pulse2	;show it working
	mov A, #55h	;initialize variables
	mov R0, A	;R0 = 55h
	mov R2, #00h	;R2 clear
	acall WRITE_ALL_MEMORY	;write all the values
	mov dpl, #00h
	mov dph, #00h	;reset address
	acall READ_ALL_MEMORY_55	;read back data, see if it's good
	cjne R2, #00h, exit

	LCALL LED_Latch_Pulse2	;show it working
	mov A, #0AAh	;reinitialize variables
	mov R0, A	;R0 = 55h
	mov R2, #00h	;R2 clear

	acall WRITE_ALL_MEMORY	;write all the values
	mov dpl, #00h
	mov dph, #00h	;reset address
	acall READ_ALL_MEMORY_AA	;read back data, see if it's good
	cjne R2, #00h, exit
	mov DPTR, #good		;IF YOU GET HERE EVERYTHING WORKED :)
	LCALL LCD_String
	LCALL CHECK	;wait for input
	pop 2
	pop 1
	pop 0
	LJMP MENU
exit:
	pop 2
	pop 1
	pop 0
	LJMP MENU

;---------------------------------------------
WRITE_ALL_MEMORY:
	acall 	RAM_write
	inc dptr		;increment from 0 to 65535
	Mov r2, dpl
	cjne r2, #0h, WRITE_ALL_MEMORY
	mov r2, dph
	cjne r2, #0h, WRITE_ALL_MEMORY	;check if dpl and dph == 0
	ret				;done when above condition is met

READ_ALL_MEMORY_55:
	acall RAM_READ
	Cjne A, #55h, Error_MemTest
	inc dptr		;increment from 0 to 65535
	Mov r2, dpl
	cjne r2, #0h, READ_ALL_MEMORY_55
	mov r2, dph
	cjne r2, #0h, READ_ALL_MEMORY_55;check if dpl and dph == 0
	ret				;done when above condition is met

READ_ALL_MEMORY_AA:
	acall RAM_READ
	Cjne A, #0AAh, Error_MemTest
	inc dptr		;increment from 0 to 65535
	Mov r2, dpl
	cjne r2, #0h, READ_ALL_MEMORY_AA
	mov r2, dph
	cjne r2, #0h, READ_ALL_MEMORY_AA;check if dpl and dph == 0
	ret				;done when above condition is met
;---------------------------------------------

Error_MemTest:	;didn't read correct value back
	push dph
	push dpl
	MOV DPTR, #datapointer	;DPTR:
	LCALL LCD_STRING
	pop dpl
	pop dph

	mov R0, dph
	lcall ascii_address	;prints the ascii form of R0 to screen
	mov r0, dpl
	lcall ascii_address	;DPTR:XX

	mov DPTR, #bad
	LCALL LCD_NEWLINE	;DPTR:XX
				;MEMORY BAD
	LCALL CHECK	;wait for input then exit
	mov R2, #0FFh
	ret
;---------------------------------------------

RAM_write:	;WRITES A TO RAM
	CLR p3.3	;clear RS	(low = instruction / high = data)
	clr p3.4 	;clear LED_EN
	CLR p3.2	;clear RTC_EN
	movx  @dptr, A	;write data
	SETB p3.3
	setb p3.4
	setb p3.2
	ret

RAM_read:	;READS RAM TO A
	CLR p3.3	;clear RS	(low = instruction / high = data)
	clr p3.4 	;clear LED_EN
	CLR p3.2	;clear RTC_EN
	movx  A, @dptr	;read data
	SETB p3.3
	setb p3.4
	setb p3.2
	ret
