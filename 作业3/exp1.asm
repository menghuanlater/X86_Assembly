STACK1		SEGMENT		PARA	STACK
STACK_AREA	DB			200H	DUP(?)
STACK_BTM	EQU			$-STACK_AREA
STACK1		ENDS

DATA1		SEGMENT		PARA
DecCharArr	DB			10		DUP(?)
FuncArr		DW			5 		DUP(?)
;定义输出菜单等字符串
MainMenu	DB			'***Welcome To Function Menu***',0DH,0AH,'1:HexToDec',9,'2:DecToHex',9,'3:BinToDec',9,'4:Multiply',9,'5:Divide',9,'0:Exit',00H
InfoChoice	DB			'Please Input your choice:',00H
InfoHexToDec	DB		'Please Input a hexadecimal number such as F456:',00H
InfoDecToHex	DB		'Please Input a decimal	number such as 256:',00H
InfoBinToDec	DB		'Please Input a binary number such as 00101010:',00H
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
			MOV			SI,OFFSET	InfoExit
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

;乘
MULTIPLY	PROC
			;压栈
			PUSH		BX
			PUSH		SI
			
			;读取第一个乘数
			MOV			SI,OFFSET	InfoMulDiv1
			CALL		DISPLAY
			CALL		GETDECNUM
			PUSH		AX
			MOV			SI,OFFSET	InfoMulDiv2
			CALL		DISPLAY
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
			PUSH		DX
			MOV			DX,0
			MOV			BX,0
			MOV			SI,OFFSET	InfoMulDiv1
			CALL		DISPLAY
			CALL		GETDECNUM
			PUSH		AX
			MOV			SI,OFFSET	InfoMulDiv2
			CALL		DISPLAY
			CALL		GETDECNUM
			POP			BX
			XCHG		AX,BX
			DIV			BX
			PUSH		AX;堆栈传参
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			CALL		DECOUTPRINT
			CALL		NEWLINE
			
			POP			DX
			POP			SI
			POP			BX
			RET
DIVIDE		ENDP

;十进制->十六进制
DEC_TO_HEX	PROC
			PUSH		SI
			PUSH		BX
			PUSH		CX
			MOV			SI,OFFSET	InfoDecToHex
			CALL		DISPLAY
			CALL		GETDECNUM
			MOV			BX,AX
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			
			;将AX的16进制数以字符形式输出
			
			MOV			CL,12
			SHR			AX,CL
			CALL		MEM_TO_CHAR
			MOV			AX,BX
			
			MOV			CL,8
			SHR			AX,CL
			CALL		MEM_TO_CHAR
			MOV			AX,BX
			
			MOV			CL,4
			SHR			AX,CL
			CALL		MEM_TO_CHAR
			MOV			AX,BX
			
			CALL		MEM_TO_CHAR
			CALL		NEWLINE
			
			POP			CX
			POP			BX
			POP			SI
			RET
DEC_TO_HEX	ENDP

;十六进制->十进制
HEX_TO_DEC	PROC
			;压栈
			PUSH		SI
			PUSH		BX
			PUSH		CX
			MOV			SI,OFFSET	InfoHexToDec
			CALL		DISPLAY
			;首先进行16进制数的读取
			MOV			BX,16
			MOV			SI,0
GETHEXLOOP:
			MOV			AH,1
			INT			21H
			CMP			AL,0DH
			JZ			GETHEXEXIT
			MOV			CX,0
			CMP			AL,'A'
			JGE			ALPHANUMBER
			SUB			AL,48
			JMP			MULADD
ALPHANUMBER:
			SUB			AL,55
MULADD:
			MOV			CL,AL
			MOV			AX,SI
			MUL			BX
			ADD			AX,CX
			MOV			SI,AX
			JMP			GETHEXLOOP
GETHEXEXIT:
			;十六进制数已经读取,值在SI中
			PUSH		SI
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			CALL		DECOUTPRINT
			CALL		NEWLINE
			
			;弹栈
			POP			CX
			POP			BX
			POP			SI
			RET
HEX_TO_DEC	ENDP

;二进制->十进制
BIN_TO_DEC	PROC
			PUSH		SI
			PUSH		BX
			PUSH		CX
			
			MOV			SI,OFFSET	InfoBinToDec
			CALL		DISPLAY
			
			MOV			BX,2
			MOV			SI,0
GETBINLOOP:
			MOV			AH,1
			INT			21H
			CMP			AL,0DH
			JZ			GETBINEXIT
			MOV			CX,0
			SUB			AL,48
			MOV			CL,AL
			MOV			AX,SI
			MUL			BX
			ADD			AX,CX
			MOV			SI,AX
			JMP			GETBINLOOP
GETBINEXIT:
			PUSH		SI
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			CALL		DECOUTPRINT
			CALL		NEWLINE
			
			POP			CX
			POP			BX
			POP			SI
			RET
BIN_TO_DEC	ENDP

;十六进制字符输出
MEM_TO_CHAR	PROC
			;进行AX高12位清0
			AND			AX,000FH
			CMP			AX,10
			JGE			Alpha
			ADD			AX,48
			JMP			OutScreen
Alpha:
			ADD			AX,55
OutScreen:
			MOV			DL,AL
			MOV			AH,2
			INT			21H
			RET
MEM_TO_CHAR	ENDP

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
ReverseOut:
			MOV			DL,BYTE	PTR[DI]
			MOV			AH,2
			INT			21H
			DEC			DI
			CMP			DI,BX
			JGE			ReverseOut
			
			;相关寄存器弹栈
			POP			BP
			POP			DI
			POP			DX
			POP			CX
			POP			BX
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