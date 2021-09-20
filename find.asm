;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> find.asm 
;*
;*	>> Assembly source to search through memory block for BYTE of data
;*		--> Allows both manual paging through found addresses and
;*		automatic searching/printing of sequential found addresses
;*	[!] [dependency] :> Included in 8051 main.asm
;*
;*	[!!] Used to FIND and COUNT [!!]
;*
;**************************************************************

startAddress: db 'StartAddress: ~'
searchvalue: db 'SearchValue: ~'
FoundAddress: db 'FoundAddress: ~'
ByteFound: db 'Byte(s) Found~'
ByteNotFound: db 'BYTE NOT FOUND ~'
HitRAMTop: db 'HitRAMTop~'

countStart:				;Count backpacks off of Find search algorithm
	MOV R6, #1			;Count Flag stored in R6
findStart:
	CLR A
	MOV R0, A
	MOV R1, A
	MOV R2, A
	MOV R4, A
	MOV R5, A
	LCALL PRINT_CMDS_STATIC		;Quick overview of PageFileCmds
	MOV DPTR, #startAddress
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING	
	LCALL twodigitread
	MOV R1, A			;save start address
	LCALL ASKDATATYPE
	ACALL LCD_DATA
	LCALL ASKBLOCKSIZE
;getBlockSize:
;	MOV DPTR, #blocksize
;	LCALL LCD_Newline
;	LCALL twodigitread
;	MOV R2, A			;save blocksize
;	JZ INVALID_BLOCKSIZE	;	check if block size is zero
;	JMP validBlockSize
;
;Invalid_BlockSize:
;	MOV DPTR, #BlockSizeError
;	LCALL LCD_CLR
;	LCALL LCD_RSCOUNT
;	LCALL LCD_STRING
;	LJMP getBlockSize

ValidBlockSize:
	MOV R4, #0H			; SET COUNT TO 0
	MOV R2, A			; save blocks to iterate
	MOV DPTR, #searchvalue
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	LCALL twodigitread
	MOV R5, A			;save searchvalue
	;search for value in block at address
tryAgain:
	MOV A, R5
	CLR C
	SUBB A, @R1	;subtract the searchvalue from the current data
	JZ foundByte	;only zero if they're the same number
	
THIS_LOC:
	MOV A, R1	;Check current RAM location
	CLR C
	SUBB A, #0FFH
	JZ RAM_END ;at address FF, no next block
	
NEXT_RAMLOC:
	INC R1
	DJNZ R2, tryagain	;decrement remaining blocks and go again
	JMP finishedSearch
	
RAM_END:
	MOV DPTR, #Hitramtop
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	
finishedSearch:
	MOV DPTR, #finishmsg1
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	CJNE R4, #0H, EXIT_HERE	;Exits happily if found
	MOV DPTR, #bytenotfound	;ELSE TELL USER BYTE NOT FOUND
	LCALL LCD_NEWLINE
	LCALL DELAY_SHORT
	LJMP menu2
	
exit_HERE:
	MOV DPTR, #BYTEFOUND
	LCALL LCD_NEWLINE
	LCALL DELAY_SHORT
	CLR A
	MOV R7, A	; Reset fast-forward FLAG
	MOV R6, A	; ; Reset Count Branch flag	
EXIT_2MENU:
	LJMP menu2


foundByte:
	CJNE R6, #01H, PRT 
	CJNE R7, #00h, PRT
	LCALL PRINT_CMDS_DYNAMIC	;Quick CMDs review 
PRT:	INC R4				;Increment count when found
	CJNE R7, #0, FINDBYTES		;Checks for non-interactive FIND bit - Skip2End is active
	MOV DPTR, #foundaddress
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	MOV A, R1 			;CURRENT ADDRESS
	MOV R0, A			;INITIALIZE R0 WITH THE CURRENT ADDRESS
	LCALL ASCII_ADDRESS		;print address from R0
	CJNE R4, #1, secondaryPage	;ONE count means NO PREVIOUS pages
firstPage:
	MOV A, R6			;check Count flag R6
	JNZ WITHCOUNT
	MOV DPTR, #FirstPAGE_MENU
	LCALL LCD_NEWLINE
	JMP userprompt
secondaryPage:
	MOV DPTR, #NEXTPAGE_MENU
	MOV A, R6			;check Count flag R6
	JNZ WITHCOUNT
	LCALL LCD_NEWLINE
userPrompt:
	LCALL Check
	CJNE A, #30h, C1	;0/next
	MOV 8, 0		;Stores foundAddress to RAM
	MOV 9, 2		;Stores current blocksize
	lJMP THIS_LOC		
C1: 	CJNE A, #31H, C2	;1/previous
	MOV A, R4
	SUBB A, #1h		;explicitly check if 1 is input while already at first page
	JZ E1			;Display error if try to access blk[-1]
	DEC R4			;first undo this iteration's automatic increment
	DEC R4			;then make sure to undo last iteration increment
	MOV 1, 8		;Retreives last foundAddress from RAM
	MOV 2, 9		;Get previous block size back
	LJMP TRYAGAIN		;Reiterates with patched variables corresponding with previous address
	
C2:	CJNE A, #43H, C3	;C/skip is pressed for non-interactive search
	MOV R7, #01H		;r7=#01h to enable non-interactive search
	LJMP THIS_LOC
C3:	CJNE A, #45h, C3	;E/exit to menu is pressed
	JMP EXIT_2MENU
E1:	MOV DPTR, #ERRORMSG1
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	MOV DPTR, #ERRORMSG2
	LCALL LCD_NEWLINE
	DEC R4
	JMP FOUNDBYTE

WITHCOUNT:
	ACALL WRITE_COUNT
	JMP USERPROMPT

FINDBYTES:			; R7 is set - automatically iterates and prints each address page
	MOV DPTR, #foundaddress
	LCALL LCD_CLR
	LCALL LCD_RSCOUNT
	LCALL LCD_STRING
	MOV A, R1 	;CURRENT ADDRESS
	MOV B, A	
	MOV R0, A	;INITIALIZE R0 WITH THE CURRENT ADDRESS
	LCALL ASCII_ADDRESS	;print address from R0
	LCALL DELAY_SHORT
	MOV A, R6		;check flag to print with Count
	JZ SKIPCOUNT		;prints out count data if set
	ACALL write_count
SKIPCOUNT:
	LJMP THIS_LOC		;count not set, next location
