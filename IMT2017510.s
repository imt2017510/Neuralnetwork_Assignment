     THUMB
	 PRESERVE8
	 AREA     factorial, CODE, READONLY
     EXPORT __main
     IMPORT printMsg
	 IMPORT printMsg2p
	 IMPORT printMsg4p
     ENTRY 
__main  FUNCTION	
;for logic_and R12 = 1
;for logic_or R12 = 2
;for logic_xor R12 = 3
;for logic_xnor R12 = 4
;for logic_nand R12 = 5
;for logic_nor R12 = 6
;for logic_not R11 = 7
		MOV R12,#1					;for logic gate selecting
		MOV R11,#7
		CMP R12,R11
		BLT __dataset1
		BL __dataset2
stop    B stop ; stop program
     ENDFUNC

		
		
;-------------------------------dataset--------------------------------------
__dataset1 FUNCTION
		PUSH {LR}; 
		MOV R4,#0					;a1	-> input 1
		MOV R5,#0					;a2	-> input 2
		MOV R6,#0					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		MOV R4,#1					;a1	-> input 1
		MOV R5,#0					;a2	-> input 2
		MOV R6,#0					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		MOV R4,#0					;a1	-> input 1
		MOV R5,#1					;a2	-> input 2
		MOV R6,#0					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		MOV R4,#0					;a1	-> input 1
		MOV R5,#0					;a2	-> input 2
		MOV R6,#1					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		MOV R4,#1					;a1	-> input 1
		MOV R5,#1					;a2	-> input 2
		MOV R6,#0					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		MOV R4,#1					;a1	-> input 1
		MOV R5,#0					;a2	-> input 2
		MOV R6,#1					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		MOV R4,#0					;a1	-> input 1
		MOV R5,#1					;a2	-> input 2
		MOV R6,#1					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		MOV R4,#1					;a1	-> input 1
		MOV R5,#1					;a2	-> input 2
		MOV R6,#1					;a3	-> input 3
		BL __loaddataset1
		BL __calllogic
		BL printMsg4p
		
		
		ADD R12,R12,#1
		CMP R12,R11
		BLT __dataset1
		BL __dataset2
		ENDFUNC


__dataset2 FUNCTION
		PUSH {LR}
		MOV R4,#1
		BL __loaddataset2
		BL __calllogic
		MOV R1,R3
		BL printMsg2p
		MOV R4,#0
		BL __loaddataset2
		BL __calllogic
		MOV R1,R3
		BL printMsg2p
		POP {LR}
		BX LR
		ENDFUNC
;---------------------------------------------------------------------------------
__loaddataset1 FUNCTION
		PUSH {LR};
		VMOV.F32 S0,R4		        ;move a1 to s0(floating point register)
		VMOV.F32 S1,R5		        ;move a2 to s1(floating point register)
		VMOV.F32 S2,R6		        ;move a3 to s2(floating point register)
		VCVT.F32.S32 S0,S0          ;convert into signed 32bit number
		VCVT.F32.S32 S1,S1          ;convert into signed 32bit number
		VCVT.F32.S32 S2,S2          ;convert into signed 32bit number
		POP {LR};
		BX lr;
		ENDFUNC
		
__loaddataset2 FUNCTION
		PUSH {LR};
		VMOV.F32 S0,R4		        ;move a1 to s0(floating point register)
		VCVT.F32.S32 S0,S0          ;convert into signed 32bit number
		POP {LR};
		BX lr;
		ENDFUNC	
__calculation FUNCTION
		BL __exponent
		BL __sigmoid
		VLDR.F32 S14,= 0.5			;Store 0.5 in S14
		VCMP.F32 S9,S14				;Compare current Y and 0.5		
		VMRS    APSR_nzcv, FPSCR;	 
		MOV R0, R4;
		MOV R1, R5;
		MOV R2, R6					;Move inouts to R0, R1 and R2 to print
		MOVGT	R3, #1				;If Y > 0.5, output is 1
		MOVLT	R3, #0				;If Y < 0.5, output is 0
		POP {LR};
		BX lr;	
		ENDFUNC

;Compute e^-x for value in S8 and store in S9	

__exponent FUNCTION
		PUSH {LR};
		MOV R7,#3					;No of terms in the series
		MOV R8,#1					;Count
		VLDR.F32 S9,=1				;Store value of e^x
		VLDR.F32 S10,=1				;Temp variable to hold the previous term
		VLDR.F32 S11,=1 			;division factor
LOOP1
		CMP R8,R7					;Compare count and no of term
		BLE LOOP2					;If count is < no og terms enter LOOP1
		VDIV.F32 S9,S11,S9          ;Store value of e^-x
		POP {LR}	
		BX lr						;else STOP
LOOP2  
		VMUL.F32 S10,S10,S8		    ;Temp_var = temp_var * x
		VMOV.F32 S12,R8				;Move the count in R9 to S13 (floating point register)
		VCVT.F32.S32 S12,S12		;Convert into signed 32bit number
		VDIV.F32 S10,S10,S12		;Divide temp_var by count (Now the term is finished)
		VADD.F32 S9,S9,S10		    ;Add temp_var to the sum
		ADD R8,R8,#1				;Increment the count
		B LOOP1;
		ENDFUNC
;Compute sigmoid function e^-x in S9 and store Sigmoid function output in S12
__sigmoid FUNCTION
		PUSH {LR}
		VLDR.F32 S13,= 1				;temporary variable
		VADD.F32 S9,S9,S13				;S9 has (e^-x)+1
		VDIV.F32 S9,S13,S9				;S9 has 1 / (e^-x)+1-> 	Value of Y - sigmoid function
		POP {LR}
		BX lr	
		ENDFUNC


;----------------------------------logic gates------------------------------------------------

__and FUNCTION
		PUSH {LR};	 
		VLDR.F32 S4,= 0.2			;Weight 1(W1)
		VLDR.F32 S5,= 0.2			;Weight 2(W2)
		VLDR.F32 S6,= -0.1			;Weight 3(W3)
		VLDR.F32 S7,= -0.2			;Bias(b)
		VMUL.F32 S0,S0,S4			;a1*w1
		VMUL.F32 S1,S1,S5			;a2*w2
		VMUL.F32 S2,S2,S6			;a3*w3
		VADD.F32 S3,S0,S1			;a1*w1 + a2*w2 
		VADD.F32 S3,S3,S2			;a1*w1 + a2*w2 + a3*w3 
		VADD.F32 S3,S3,S7			;a1*w1 + a2*w2 + a3*w3 + b
		VMOV.F32 S8,S3				;S8 has the value of x
		
		BL __calculation
		POP {LR};	
		BX lr;
		ENDFUNC

;		logic OR

__or FUNCTION
		PUSH {LR};	 
		VLDR.F32 S4,= 0.7			;Weight 1(W1)
		VLDR.F32 S5,= 0.7			;Weight 2(W2)
		VLDR.F32 S6,= -0.1			;Weight 3(W3)
		VLDR.F32 S7,= -0.1			;Bias(b)
		VMUL.F32 S0,S0,S4			;a1*w1
		VMUL.F32 S1,S1,S5			;a2*w2
		VMUL.F32 S2,S2,S6			;a3*w3
		VADD.F32 S3,S0,S1			;a1*w1 + a2*w2 
		VADD.F32 S3,S3,S2			;a1*w1 + a2*w2 + a3*w3 
		VADD.F32 S3,S3,S7			;a1*w1 + a2*w2 + a3*w3 + b
		VMOV.F32 S8,S3				;S8 has the value of x
		
		BL __calculation
		POP {LR};	
		BX lr;
		ENDFUNC
		
;		logic nand

__nand FUNCTION
		PUSH {LR};	 
		VLDR.F32 S4,= -0.8			;Weight 1(W1)
		VLDR.F32 S5,= -0.8			;Weight 2(W2)
		VLDR.F32 S6,= 0.6			;Weight 3(W3)
		VLDR.F32 S7,= 0.3			;Bias(b)
		VMUL.F32 S0,S0,S4			;a1*w1
		VMUL.F32 S1,S1,S5			;a2*w2
		VMUL.F32 S2,S2,S6			;a3*w3
		VADD.F32 S3,S0,S1			;a1*w1 + a2*w2 
		VADD.F32 S3,S3,S2			;a1*w1 + a2*w2 + a3*w3 
		VADD.F32 S3,S3,S7			;a1*w1 + a2*w2 + a3*w3 + b
		VMOV.F32 S8,S3				;S8 has the value of x
		
		BL __calculation
		POP {LR};	
		BX lr;
		ENDFUNC
		
;		logic nor


		
__nor FUNCTION
		PUSH {LR};	 
		VLDR.F32 S4,= -0.7			;Weight 1(W1)
		VLDR.F32 S5,= -0.7			;Weight 2(W2)
		VLDR.F32 S6,= 0.5			;Weight 3(W3)
		VLDR.F32 S7,= 0.1			;Bias(b)
		VMUL.F32 S0,S0,S4			;a1*w1
		VMUL.F32 S1,S1,S5			;a2*w2
		VMUL.F32 S2,S2,S6			;a3*w3
		VADD.F32 S3,S0,S1			;a1*w1 + a2*w2 
		VADD.F32 S3,S3,S2			;a1*w1 + a2*w2 + a3*w3 
		VADD.F32 S3,S3,S7			;a1*w1 + a2*w2 + a3*w3 + b
		VMOV.F32 S8,S3				;S8 has the value of x
		
		BL __calculation
		POP {LR};	
		BX lr;
		ENDFUNC
		
__calllogic FUNCTION
		CMP R12,#1
		BEQ __and
		CMP R12,#2
		BEQ __or
		CMP R12,#3
		BEQ __xor
		CMP R12,#4
		BEQ __xnor
		CMP R12,#5
		BEQ __nand
		CMP R12,#6
		BEQ __nor
		CMP R12,#7
		BEQ __not2
		ENDFUNC
;       logic not		
__not 	FUNCTION
		PUSH {LR};	 
		VLDR.F32 S4,= 0.5			;eight 1
		VLDR.F32 S7,= 0.1			;Bias
		VMUL.F32 S0,S0,S4			;A1*W1
		VADD.F32 S3,S0,S7			;A1*W1 + B
		VMOV.F32 S8,S3				;S8 has the value of x
		BL __calculation
		POP {LR};	
		BX lr;
		ENDFUNC

;      logic xnor

__xnor FUNCTION
		PUSH {LR};		

		BL __xor;
		VMOV.F32 S0,R3				;Move the count in R4 to S0 (floating point register)
		VCVT.F32.S32 S0,S0			;Convert into signed 32bit number
		BL __not;
	 
		POP {LR};	
		BX lr;
		ENDFUNC

;		logic not

__not2 FUNCTION
		PUSH {LR};	 
		VLDR.F32 S4,= -0.7;			Weight2
		VLDR.F32 S7,= 0.1;			Bias
	 
		VMUL.F32 S0,S0,S4;			A1*W1
		VADD.F32 S3,S0,S7;			A1*W1 + B
	 
		VMOV.F32 S8,S3;			S10 has the value of x
		BL __calculation;
		POP {LR};	
		BX lr;
		ENDFUNC
; 		logic xor

__xor FUNCTION
		PUSH {LR};
		; Store the inputs 
		VMOV.F32 S19,S0				;S19 has A1
		VMOV.F32 S20,S1				;S20 has A2
		VMOV.F32 S21,S2				;S21 has A3
		BL __not					;Computes not for A AND stored in R3
		VMOV.F32 S22,R3				;Move the A' in R3 to S22 (floating point register)
		VCVT.F32.S32 S22,S22		;Convert into signed 32bit number
		
		VMOV.F32 S0,S20				;Move value of A2 to S0		
		BL __not					;Computes not for b AND stored in R3
		VMOV.F32 S23,R3				;Move the A' in R3 to S23 (floating point register)
		VCVT.F32.S32 S23,S23		;Convert into signed 32bit number
		
		VMOV.F32 S0,S21				;Move value of A2 to S0		
		BL __not					;Computes not for b AND stored in R3
		VMOV.F32 S24,R3				;Move the A' in R3 to S23 (floating point register)
		VCVT.F32.S32 S24,S24		;Convert into signed 32bit number
		
		VMOV.F32 S0,S22	
		VMOV.F32 S1,S20
		VMOV.F32 S2,S24
		BL __and					;compute A1'*A2*A3' 
		MOV R7,R3					;Store value in R7
		
		VMOV.F32 S0,S19	
		VMOV.F32 S1,S23
		VMOV.F32 S2,S24
		BL __and					;compute A1*A2'*A3' 
		MOV R8,R3					;Store value in R8

		VMOV.F32 S0,S22	
		VMOV.F32 S1,S23
		VMOV.F32 S2,S21
		BL __and					;compute A1'*A2'*A3 
		MOV R9,R3					;Store value in R9
		
		VMOV.F32 S0,S19	
		VMOV.F32 S1,S20
		VMOV.F32 S2,S21
		BL __and					;compute A1*A2*A3 
		MOV R10,R3					;Store value in R10	
;    Compute OR for R7, R8, R9, R10

		VMOV.F32 S0,R10				;Move the count in R10 to S0 (floating point register)
		VCVT.F32.S32 S0,S0			;Convert into signed 32bit number
		VMOV.F32 S1,R9				;Move the count in R9 to S1 (floating point register)
		VCVT.F32.S32 S1,S1			;Convert into signed 32bit number
		VMOV.F32 S2,R8				;Move the count in R8 to S2 (floating point register)
		VCVT.F32.S32 S2,S2			;Convert into signed 32bit number
		BL __or
		MOV R10,R3
		
		VMOV.F32 S0,R7				;Move the count in R4 to S0 (floating point register)
		VCVT.F32.S32 S0,S0			;Convert into signed 32bit number
		VMOV.F32 S1,R10				;Move the count in R4 to S0 (floating point register)
		VCVT.F32.S32 S1,S1			;Convert into signed 32bit number
		VLDR.F32 S2, = 0			;3rd input	
		BL __or
		POP {LR};		
		BX lr;
		LTORG
		ENDFUNC		
	END
		
