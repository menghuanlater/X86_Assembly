STACK1		SEGMENT		PARA	STACK
STACK_AREA	DB			100H	DUP(?)
STACK_BTM	EQU			$-STACK_AREA
STACK1		ENDS

DATA1		SEGMENT		PARA
FuncArr		DW			5 		DUP(?)
;定义输出菜单等字符串
MainMenu	DB			'***Welcome To Function Menu***\r\n1:HexToDec\t2:DecToHex\t3:BinToDec\t4:Multiply\t5:Divide\t0:Exit',00H
InfoChoice	DB			'Please Input your choice:',00H
InfoHexToDec	DB		'Please Input a hexadecimal number such as F456H:',00H
InfoDecToHex	DB		'Please Input a decimal	number such as 256D:',00H
InfoBinToDec	DB		'Please Input a binary number such as 00101010B',00H
InfoMulDiv1	DB		'please Input the first number:',00H
InfoMulDiv2	DB		'Please Input the second number:',00H
InfoExit	DB		'Procedure exit sucessfully.',00H
InfoOutcome	DB		'Outcome is:',00H
DATA1		ENDS

CODE1		SEGMENT		PARA
			ASSUME		CS:CODE1,	DS:DATA1,	SS:STACK1,	ES:DATA1
			
MAIN		PROC		FAR
			;初始化
			MOV			AX,DATA1
			MOV			DS,AX
			MOV			ES,AX
			MOV			AX,STACK1
			MOV			SS,AX
			MOV			SP,STACK_BTM
			
			;初始化函数指针表
			MOV			SI,OFFSET	FuncArr
			MOV			AX,OFFSET	HEX_TO_DEC
			MOV			[SI],AX
			
			MOV			AX,OFFSET	DEC_TO_HEX
			MOV			[SI+2],AX
			
			MOV			AX,OFFSET	BIN_TO_DEC
			MOV			[SI+4],AX
			
			MOV			AX,OFFSET	MULTIPLY
			MOV			[SI+6],AX
			
			MOV			AX,OFFSET	DIVIDE
			MOV			[SI+8],AX
			
			;使用一个while循环接受键盘的输入,如果是0,则退出
MENU_WHILE:
			MOV			SI,OFFSET	MainMenu
			CALL		DISPLAY
			CALL		NEWLINE
			
			MOV			SI,OFFSET	InfoChoice
			CALL		DISPLAY
			
			CALL		GETDECNUM
			CMP			AX,0
			JZ			MENU_EXIT
			;计算函数指针
			SUB			AX,1
			MOV			BL,2
			MUL			BL
			MOV			SI,OFFSET	FuncArr
			ADD			SI,AX
			CALL		[SI]
			JMP			MENU_WHILE
MENU_EXIT:
			MOV			SI,InfoExit
			CALL		DISPLAY
			CALL		NEWLINE
			;结束
			MOV			AX,4C00H
			INT			21H
MAIN		ENDP

;getnumber
GETDECNUM		PROC
			;寄存器入栈
			PUSH		SI
			PUSH		BX
			PUSH		CX
			MOV			SI,0
			MOV			BL,10
GETDECNUM_LOOP:
			MOV			AH,1
			INT			21H
			CMP			AL,0DH
			JZ			GETDECNUM_EXIT
			SUB			AL,48
			MOV			CX,0
			MOV			CL,AL
			MOV			AL,SI
			MUL			BL
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

;乘
MULTIPLY	PROC
			;压栈
			PUSH		BX
			PUSH		SI
			;读取第一个乘数
			CALL		GETDECNUM
			PUSH		AX
			CALL		GETDECNUM
			POP			BX
			MUL			BX
			PUSH		AX;堆栈传参
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			CALL		DECOUTPRINT
			CALL		NEWLINE
			;弹栈
			POP			SI
			POP			BX
			RET
MULTIPLY	ENDP

;除
DIVIDE		PROC
			PUSH		BX
			PUSH		SI
			CALL		GETDECNUM
			PUSH		AX
			CALL		GETDECNUM
			POP			BX
			XCHG		AX,BX
			DIV			BX
			PUSH		AX;堆栈传参
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			CALL		DECOUTPRINT
			CALL		NEWLINE
			
			POP			SI
			POP			BX
			RET
DIVIDE		ENDP

;十进制->十六进制
DEC_TO_HEX	PROC
			RET
DEC_TO_HEX	ENDP

;十六进制->十进制-
HEX_TO_DEC	PROC
			RET
HEX_TO_DEC	ENDP

;二进制->十进制-
BIN_TO_DEC	PROC
			RET
BIN_TO_DEC	ENDP

;十进制输出
DECOUTPRINT	PROC
			;压栈
			PUSH		BP
			MOV			BP,SP
			RET
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