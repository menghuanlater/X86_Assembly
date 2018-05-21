STACK1		SEGMENT		PARA	STACK
STACK_AREA	DB			100H	DUP(?)
STACK_BTM	EQU			$-STACK_AREA
STACK1		ENDS

DATA1		SEGMENT		PARA
DecCharArr	DB			10		DUP(?)
InfoInput	DB			'Please Input a number:',00H
InfoOutPut	DB			'Outcome is:',00H
DATA1		ENDS

CODE1       SEGMENT		PARA
			ASSUME		CS:CODE1,	DS:DATA1,	SS:STACK1,	ES:DATA1
MAIN		PROC		FAR
			MOV			AX,DATA1
			MOV			DS,AX
			MOV			ES,AX
			MOV			AX,STACK1
			MOV			SS,AX
			MOV			SP,STACK_BTM
			
			MOV			SI,OFFSET	InfoInput
			CALL		DISPLAY
			CALL		GETDECNUM
			PUSH		AX
			CALL		FACTORIAL
			PUSH		AX
			MOV			SI,OFFSET	InfoOutPut
			CALL		DISPLAY
			CALL		DECOUTPRINT
			CALL		NEWLINE
			
			MOV			AX,4C00H
			INT         21H
			RET
MAIN		ENDP

;递归阶乘
FACTORIAL	PROC
			;压栈
			PUSH		BP
			MOV			BP,SP
			PUSH		BX
			
			MOV			BX,[BP+4]
			CMP			BX,1
			JZ			EQUAL_1
			MOV			AX,BX
			DEC			AX
			PUSH		AX
			CALL		FACTORIAL
			MUL			BX
			JMP			FACT_EXIT
EQUAL_1:	
			MOV			AX,1
FACT_EXIT:					
			;弹栈
			POP			BX
			POP			BP
			RET			2
FACTORIAL	ENDP

;getnumber
GETDECNUM		PROC
			;寄存器入栈
			PUSH		SI
			PUSH		BX
			PUSH		CX
			MOV			SI,0
			MOV			BX,10
GETDECNUM_LOOP:
			MOV			AH,1
			INT			21H
			CMP			AL,0DH
			JZ			GETDECNUM_EXIT
			SUB			AL,48
			MOV			CX,0
			MOV			CL,AL
			MOV			AX,SI
			MUL			BX
			ADD			AX,CX
			MOV			SI,AX
			JMP			GETDECNUM_LOOP
GETDECNUM_EXIT:
			MOV			AX,SI;返回值
			POP			CX
			POP			BX
			POP			SI
			RET
GETDECNUM	ENDP

;十进制输出
DECOUTPRINT	PROC
			;压栈
			PUSH		BP
			MOV			BP,SP
			PUSH		BX
			PUSH		CX
			PUSH		DX
			PUSH		DI
			;相关寄存器压栈
			
			;取出栈中数据
			MOV			AX,WORD PTR[BP+4]
			MOV			BX,10
			MOV			DX,0
			MOV			DI,OFFSET	DecCharArr	
LOOP_DIV_TEN:
			DIV			BX
			ADD			DX,48
			MOV			BYTE PTR[DI],DL
			INC			DI
			
			CMP			AX,0;判断商是否为0
			JZ			LOOP_DIV_TEN_EXIT
			MOV			DX,0
			JMP			LOOP_DIV_TEN
			
LOOP_DIV_TEN_EXIT:
			MOV			BX,OFFSET	DecCharArr
			DEC			DI
ReverseOut:
			MOV			DL,BYTE	PTR[DI]
			MOV			AH,2
			INT			21H
			DEC			DI
			CMP			DI,BX
			JGE			ReverseOut
			
			;相关寄存器弹栈
			POP			DI
			POP			DX
			POP			CX
			POP			BX
			POP			BP
			RET			2
DECOUTPRINT	ENDP

;打印一个字符串
DISPLAY		PROC
			PUSH		DX		
			;字符串首地址SI中
			CLD
WHILE_LOOP:
			LODSB
			CMP			AL,0
			JZ			WHILE_EXIT
			MOV			DL,AL
			MOV			AH,2
			INT			21H
			JMP			WHILE_LOOP

WHILE_EXIT:
			POP			DX
			RET
DISPLAY		ENDP

;输出换行与回车符
NEWLINE		PROC
			MOV			DL,0DH
			MOV			AH,2
			INT			21H
			MOV			DL,0AH
			MOV			AH,2
			INT			21H
			RET
NEWLINE		ENDP

CODE1		ENDS

END			MAIN