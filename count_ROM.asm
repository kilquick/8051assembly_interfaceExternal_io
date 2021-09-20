;**************************************************************
;*
;*	Tyler Zoucha
;*	Spring 2021
;*	Lab 4 - RAM Check
;*	> count.asm
;*	
;*	**Scrapped original idea, but using file to declare count
;*	**Creates strings with incremented Count in program memory
;*	 
;*	[!] [dependency] :> Included in 8051 main.asm
;*
;**************************************************************
zero: DB 'Count=0~',0,0			;<-Only this label should be needed if count is updated within RAM
one: DB 'Count=1 <0/C/E>~'		; **Currently using ROM implementation to submit for lab grade
two: DB 'Cnt=2 <1/0/C/E>~'		; *
three: DB 'Cnt=3 <1/0/C/E>~'		; *
four: DB 'Cnt=4 <1/0/C/E>~'		; *
five: DB 'Cnt=5 <1/0/C/E>~'		; * ROM IMPLEMENTATION IS MESSY
six: DB 'Cnt=6 <1/0/C/E>~'		; *
sevn: DB 'Cnt=7 <1/0/C/E>~'		; *
eight: DB 'Cnt=8 <1/0/C/E>~'		; *
nine: DB 'Cnt=9 <1/0/C/E>~'		; *
ten: DB 'Cnt=10 <1/0/C/E>~'		; *
elevn: DB 'Cnt=11 <1/0/C/E>~'		; *
twelv: DB 'Cnt=12 <1/0/C/E>~'		; *
thrtn: DB 'Cnt=13 <1/0/C/E>~'		; *
fourtn: DB 'Cnt=14 <1/0/C/E>~'		; *
fiftn: DB 'Cnt=15 <1/0/C/E>~'		; *
sixtn: DB 'Cnt=16 <1/0/C/E>1'		; **Current Implementation is limited by CJNE operand

;*****Might revisit concept later to expand on
;count: DB 'COUNT: ',0,0		;null space memory buffer for appending COUNT string
;clearCount:
;	CLR A		
;	MOV R4, A		;clear count in RAM
;countBytes:
;	MOV DPTR, #count	;load ROM pointer
;	MOV R0, #20H 		;load RAM pointer
;get_mem:										/////////////////////////////////////////////////////////////////////////
	;CLR A										//		Scrapped Attempt Using RAM for Count INC/DEC
	;MOVC A,@A+DPTR		;Move data from code space				// **I can't figure how to to point DPTR/dph:dpl properly to RAM data
	;JZ cont1									// -->Load COUNT label into RAM from ROM
	;MOV @R0, A		;SAVE in RAM at address stored in R0 0x20		// -->Add/Update real-time COUNT value as next sequential RAM address
	;INC DPTR		;INC ROM POINTER					// -->Place LCD_STRING delimiting CHAR HEXVALUE as next sequential RAM 
	;INC R0			;INC RAM POINTER					// 	->Should clean up a lot of the verbose count ROM declarations
	;SJMP get_mem									// 
;cont1:											*
				;							* [*] I've already wasted 4 extra days trying to make this work
;set_mem:										* 
	;MOV R0, #27H		;R0 = count MEMORY ADDRESS LOCATION			* [*] For the sake of lab submission, using ROM instead of RAM 
	;ORL A, #60h		;APPLY mask for ASCII					*	
	;MOV @R0, A		;Write COUNT ascii to MEMORY ADDRESS			* [!!]--->Newer ROM Implementation Incredibly efficient <---[!!]
	;INC R0			;NEXT MEMORY LOCATION					* 	\->Uses FIND.ASM with flag check for printing :)
	;MOV @R0, B		;Write DelimIT ~ to RAM as HEX				*/////////////////////////////////////////////////////////////////////