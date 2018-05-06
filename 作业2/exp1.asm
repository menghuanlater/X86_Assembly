STACK1      SEGMENT PARA STACK
STACK_AREA  DW  100H DUP(?)
STACK_BTM   EQU $-STACK_AREA
STACK1      ENDS

DATA1       SEGMENT PARA
Copy_Right	DB		'Congratulations,the copy procedure executes correctly.',00H;复制成功
Copy_Error	DB		'Sorry,the size of string1 is bigger than string2,thus the copy procedure can not carray out!',00H;出现复制的极端情况不允许执行
String1Name	DB		'String1:',00H
String2Name DB		'String2:',00H
String1		DB		'Today is Friday',00H
String2		DB      'Hello We are Family',00H
DATA1       ENDS

CODE1       SEGMENT PARA
            ASSUME      CS:CODE1,   DS:DATA1,   SS:STACK1,	 ES:DATA1

MAIN        PROC        FAR
			;初始化
            MOV         AX,DATA1
            MOV         DS,AX
			MOV			ES,AX
            MOV         AX,STACK1
            MOV         SS,AX
            MOV         SP,STACK_BTM
			
			;先进行String1与String2的操作前显示
			CALL		OBSERVE
			
			;执行STRCPY,使用堆栈传递参数
			MOV			DX,OFFSET	String2
			PUSH		DX
			MOV			DX,OFFSET	String1
			PUSH		DX
			CALL		STRCPY
			;输出复制后结果
			CALL		OBSERVE
			
			;结束
			MOV			AX,4C00H
			INT			21H		
MAIN        ENDP

;输出观察
OBSERVE		PROC
			;压栈
			PUSH		SI
			PUSH		DX
			;显示过程
			MOV			SI,OFFSET	String1Name
			CALL		DISPLAY
			MOV			SI,OFFSET	String1
			CALL		DISPLAY
			CALL		NEWLINE
			
			MOV			SI,OFFSET	String2Name
			CALL		DISPLAY
			MOV			SI,OFFSET	String2
			CALL		DISPLAY
			CALL		NEWLINE
			;弹栈
			POP			DX
			POP			SI
			RET
OBSERVE		ENDP

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

;复制的strcpy函数
STRCPY		PROC		
			PUSH		BP
			MOV			BP,SP
			;首先进行压栈
			PUSH		SI
			PUSH		DI
			PUSH		AX
			PUSH		BX
			PUSH		CX
			PUSH		DX
			;使用BX,CX保存两个字符串的长度数值
			;使用AX来作为函数调用返回值
			;使用SI作为函数参数的传递者
			MOV			SI,[BP+4];String1
			MOV			DI,[BP+6];String2
			PUSH		SI;先压入栈
			CALL		STR_LEN
			MOV			BX,AX
			MOV			SI,DI
			CALL		STR_LEN
			MOV			CX,AX
			POP			SI;数据恢复
			
			;进行比较，是否可以进行复制过程
			CMP			BX,CX;BX-CX--->len(Str1)-len(Str2)
			JG			ErrorDel
			;可以正常复制
			PUSH		SI
			MOV			SI,OFFSET	Copy_Right
			CALL		DISPLAY
			CALL		NEWLINE
			POP			SI
			
			;进行正常的复制过程
			CLD
WHILE_2:
			LODSB
			STOSB
			CMP			AL,0
			JZ			COPY_EXIT
			JMP			WHILE_2
			
ErrorDel:
			MOV			SI,OFFSET	Copy_Error
			CALL		DISPLAY
			CALL		NEWLINE
			
COPY_EXIT:
			;弹栈
			POP			DX
			POP			CX
			POP 		BX
			POP			AX
			POP			DI
			POP			SI
			POP			BP
			RET			4
STRCPY		ENDP

STR_LEN		PROC
			PUSH		BX
			;利用BX作为计数器
			MOV			BX,00H
			CLD
WHILE_3:
			LODSB
			CMP			AL,0
			JZ			WHILE_3_EXIT
			ADD			BX,1
			JMP			WHILE_3
WHILE_3_EXIT:
			MOV			AX,BX
			POP			BX
			RET
STR_LEN		ENDP

CODE1       ENDS
            END         MAIN