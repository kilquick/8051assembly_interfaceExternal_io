;***************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> main.asm
;*
;*	>> Main assembly source for my 8051 Memory/IO Computer.
;*	** Microprocessor System Design - Sr. Shariff
;*	** ECEN 4330 Project
;*	[!!] $INCLUDE(s) [dependencies] [!!]
;*		[!] dump.asm
;*		[!] move.asm
;*		[!] twoDigitRead.asm
;*		[!] edit.asm
;*		[!] find.asm
;*		[!] keypad.asm
;*		[!] count.asm
;*		[!] memCheck.asm
;*		[!] datatype.asm
;*
;*	:> Compile and test from this file only
;**************************************************************
ORG 0H
	LJMP start

NAMEHEADER: DB 'Tyler Zoucha~'		; end character = ~
NAMEFOOTER: DB 'ECEN 4330-Lab 4~'

HEADER1: DB '[Menu] <1>/2/3/4~'
FOOTER1: DB 'D:DUMP / B:MOVE~'		; D and B buttons on keypad, respectively

HEADER2: DB '[Menu] 1/<2>/3/4~'		
FOOTER2: DB 'E:EDIT / F:FIND~'		; # and * buttons on keypad, respectively

HEADER3: DB '[Menu] 1/2/<3>/4~'		; C and 0 buttons respectively
FOOTER3: DB 'C:COUNT / 0:SYS~'		; 0: System Menu/systemd/daemon manager

HEADER4: DB '[Menu] 1/2/3/<4>~'
FOOTER4: DB 'A: MEMORY CHECK~'		; A button

PAGECTRL: DB '[MEM PAGE CMDs]~'
CMDRev1: DB '0:Next / 1:Prev ~'
CMDRev2: DB 'C:Skip / E:Exit ~'

FIRSTPAGE_MENU: DB 'Press <0/C/E>~'
NEXTPAGE_MENU: DB 'Press <1/0/C/E>~'

PressAnyKey: DB 'Press <AnyKey>~'
RestartKey: DB 'Reboot <AnyKey>~'

EXIT_MSG1: DB '[SysDm_<2.4.19>] ~'	; *System Menu		**UPGRADED COMPNENTS: <count implementation> <data type block size check>
EXIT_MSG2: DB '0:REBOOT/1:BACK~'	;versionControl: rX.Y.Z
					;X = REDESIGN OF CODE ARCHITECTURE/FLOW
					;	-->Use Case: Major upgrades/changes to routines/subroutines
					;Y = Lab Number
					;	-->Use Case: Lab Submission Version Control
					;Z = Feature Implementation
					;	-->Use Case: Add/Fix Feature

ERRORMSG1: DB 'INVALID INPUT~'
ERRORMSG2: DB 'TRY AGAIN~'
FINISHMSG1: DB 'HitEndOfBlock! ~'
FINISHMSG2: DB 'Exiting to Menu~'

;*****************************************
RESTART:
START:
	MOV SP, #80H
	MOV DPTR, #NAMEHEADER
	ACALL LCD_INIT
	ACALL LCD_CLR
	ACALL LCD_STRING	;HEADER
	MOV DPTR, #NAMEFOOTER
	ACALL LCD_NEWLINE	;FOOTER
	ACALL DELAY_SHORT
	ACALL DELAY_SHORT
	LJMP MENU1		;SHOW MENU
CHECKINPUT:
	ACALL CHECK		;check keypad for input
	CJNE A, #44h, option2	;DUMP <D> is pressed
	LJMP dumpstart
option2:
	CJNE A, #42h, option3	;MOVE <B> is pressed
	LJMP moveStart
option3:
	CJNE A, #45h, option4	;EDIT <#/E> is pressed
	LJMP editStart
option4:
	CJNE A, #46h, option5	;FIND <*/F> is pressed
	LJMP findStart
option5:
	CJNE A, #43h, option6	;COUNT <C> is pressed
	LJMP countStart
option6:
	CJNE A, #31H, option7	;MENU <1> is pressed
	LJMP MENU1
option7:
	CJNE A, #32H, option8	;MENU <2> is pressed
	LJMP MENU2
option8:
	CJNE A, #33H, option9	;MENU <3> is pressed
	LJMP MENU3
option9:
	CJNE A, #34H, option10 	;MENU <4> is pressed
	LJMP MENU4
option10:
	CJNE A, #41H, option11	;MEMCHECK <A> pressed
	LJMP MEMORYTEST
option11:
	CJNE A, #30H, error	;EXIT <0> is pressed
	LJMP EXIT
error:
	MOV DPTR, #ERRORMSG1	;invalid keypad input
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
	LJMP MENU1
EXIT:
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	MOV DPTR, #EXIT_MSG1
	ACALL LCD_STRING
	MOV DPTR, #EXIT_MSG2
	ACALL LCD_NEWLINE
DONE:	ACALL CHECK
	CJNE A, #30H, DONE2	;<0> is pressed SYSTEM RESTART
	LJMP RESTART
DONE2: 	CJNE A, #31H, DONE	;<1> back to MENU
	LJMP MENU3
;******************************************
MENU1:
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT	;CLEAR AND RESET
	MOV DPTR, #HEADER1
	ACALL LCD_STRING	;D:DUMP | B: MOVE
	MOV DPTR, #FOOTER1
	ACALL LCD_NEWLINE	;*MENU: <1>|2|3|4 *
	LJMP CHECKINPUT

MENU2:
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT	;CLEAR AND RESET
	MOV DPTR, #HEADER2
	ACALL LCD_STRING	;E:EDIT | F:FIND
	MOV DPTR, #FOOTER2
	ACALL LCD_Newline	;*MENU: 1|<2>|3|4 *
	LJMP CHECKINPUT

MENU3:
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT	;CLEAR AND RESET
	MOV DPTR, #HEADER3
	ACALL LCD_STRING	;C: COUNT | 0: EXIT
	MOV DPTR, #FOOTER3
	ACALL LCD_Newline	;*MENU: 1|2|<3>|4 *
	LJMP CHECKINPUT

MENU4:
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT	;CLEAR AND RESET
	MOV DPTR, #HEADER4
	ACALL LCD_STRING	;A: MEMCHECK
	MOV DPTR, #FOOTER4
	ACALL LCD_Newline	;*MENU: 1|2|3|<4> *
	LJMP CHECKINPUT
;***************************************************
PRINT_CMDS_DYNAMIC:
INSTR0:	MOV DPTR, #CMD0		;0-Next
	ACALL LCD_NEWLINE
	ACALL DELAY_SHORT				
INSTR1:	MOV DPTR, #CMD1P	;1-Previous
	ACALL LCD_NEWLINE
	ACALL DELAY_SHORT
INSTRC:	MOV DPTR, #CMDC		;C-Skip through to last page
	ACALL LCD_NEWLINE
	ACALL DELAY_SHORT
INSTRE:	MOV DPTR, #CMDE		;E-Exit to main menu
	ACALL LCD_NEWLINE
	ACALL DELAY_SHORT
	RET
;******************************************	
PRINT_CMDS_STATIC:
	MOV DPTR, #CMDREV1
	ACALL LCD_CLR
	ACALL LCD_RSCOUNT
	ACALL LCD_STRING
	ACALL DELAY_SHORT
	MOV DPTR, #CMDREV2
	ACALL LCD_NEWLINE
	ACALL DELAY_SHORT
	RET
;***************************************************
LCD_INIT:

; 10 ms at beginning of init
; end of each cmd and data change to 50 microsec
; end of clear, 1.7ms
	;ACALL DELAY_1 ; 15 ms delay  !!!!!!!!!!!!!!!!! Removed for simulation testing only !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	MOV P1, #0H
	MOV P2, #0H
	CLR P2.2		;ENABLE LOW
	
;	ACALL DELAY_LONG 
	MOV A, #030H
	ACALL LCD_CMD		; INIT
;	ACALL DELAY_LONG
	ACALL LCD_CMD
;	ACALL DELAY_1
	ACALL LCD_CMD
	
	MOV A, #3CH
	ACALL LCD_CMD
	MOV A, #8H
	ACALL LCD_CMD
	MOV A, #6H
	ACALL LCD_CMD
	MOV A, #0FH
	ACALL LCD_CMD
	ACALL LCD_CLR	
	RET
;**************************************************
DELAY_1:	;12ms
	PUSH 0
	PUSH 1
	MOV R0, #113	;original #053
LOOP1:
	MOV R1, #053;	;original #053
LOOP2:
	DJNZ R1, LOOP2
	DJNZ R0, LOOP1
	POP 1
	POP 0
	RET	
;*********************************************
DELAY_LONG:
	PUSH 0
	MOV R0, #016	;original #016
DELAY_INNER: 
	ACALL DELAY_1
	DJNZ R0, DELAY_INNER
	POP 0
	RET
;*********************************************
Delay_short:	;50ish microseconds
	PUSH 0
	mov r0, #20h
shortstuff:
	djnz R0, shortstuff
	pop 0
	ret	
;*********************************************
delay_medium:
DELAY_1med:	;12ms
	PUSH 0
	PUSH 1
	MOV R0, #13	;original #053
LOOP1med:
	MOV R1, #053;	;original #053
LOOP2med:
	DJNZ R1, LOOP2med
	DJNZ R0, LOOP1med
	POP 1
	POP 0
	RET	
;*********************************************
LCD_CMD:
	MOV P1, A	; A HOLDS COMMAND TO SEND TO LCD
	CLR P2.0	;CLEAR RS AND RW
	CLR P2.1	; ''
	SETB P2.2	; ENABLE LINE
;	NOP
	CLR P2.2
;	ACALL DELAY_LONG
	;acall DELAY_SHORT  		!!!!!!!!!!!!!!!!! Removed for simulation testing only !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;*********************************************
LCD_DATA:
	MOV P1, A	; A HOLDS DATA TO SEND TO LCD
	SETB P2.0	;	SET RS AND  CLEAR RW
	CLR P2.1	; ''
	SETB P2.2	; ENABLE LINE
	NOP
	CLR P2.2
;	ACALL DELAY_LONG
	;acall delay_short		!!!!!!!!!!!!!!!!! Removed for simulation testing only !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;*********************************************
LCD_CLR:
	MOV A, #01H
	ACALL LCD_CMD
	;ACALL DELAY_medium		!!!!!!!!!!!!!!!!! Removed for simulation testing only !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	ACALL DELAY_1
	RET
;********************************************
LCD_STRING:
L1:	
	CLR A
	MOVC A, @A+DPTR		; get pointed data
	subb a, #7Eh		; compare to ~
	JZ L2			; IF (A = ~) END OF LINE
	CLR A
	MOVC A, @A+DPTR
	ACALL LCD_CHAR 		; OTHERWISE SEND A CHAR OFF TO LCD
	INC DPTR
	SJMP L1
L2: 
	RET
;*****************************************
LCD_CHAR:
	PUSH ACC	;PUSH THE DATA TO WRITE
	
	MOV A, #80H	;SET DDRAM ADDRESS FIRST
	ADD A, R3	;R3 HOLDS ADDRESS FOR DDRAM OF LCD
	ACALL LCD_CMD	;SET ADDRESS BEFORE CALL DATA
	POP ACC		;GET DATA BACK
	ACALL LCD_DATA	;WRITE DATA TO LCD
	INC R3		;INCREMENT ADDRESS
	RET
;*****************************************
LCD_NEWLINE:
	MOV R3, #40h	;offset for address
	ACALL LCD_STRING
	MOV R3, #0h	;clear
	RET
;*****************************************
LCD_SPACE:
	PUSH ACC
	MOV ACC, #20H	;PRINT SPACE
	ACALL LCD_CHAR
	POP ACC
	RET

;*****************************************
LCD_RSCOUNT:
	PUSH ACC
	MOV A, #80H
	ACALL LCD_CMD
	MOV R3, #0H
	POP ACC
	RET
;******************************************
$include(dump.asm)
$include(keypad.asm)
$include(move.asm)
$include(twoDigitRead.asm)
$include(edit.asm)
$include(find.asm)
$include(count.asm)
$include(memCheck.asm)
$include(datatype.asm)

END
