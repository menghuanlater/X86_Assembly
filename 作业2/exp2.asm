STACK1      SEGMENT PARA STACK
STACK_AREA  DW  100H DUP(?)
STACK_BTM   EQU $-STACK_AREA
STACK1      ENDS

DATA1       SEGMENT PARA
LEN1		DW		0
LEN2		DW		0
Succeed		DB		'Replace Succeed!',00H;替换成功
Initial		DB		'InitialStr:',00H
Current  	DB		'CurrentStr:',00H
NameObj		DB		'ZhangSan',00H
NameSrc		DB      'Menghuanlater',00H
TargetStr	DB		'Hello,My name is ZhangSan,Welcome to China.',00H
DATA1       ENDS

CODE1 		SEGMENT	PARA
			ASSUME      CS:CODE1,   DS:DATA1,   SS:STACK1,	 ES:DATA1
MAIN		PROC	FAR
			;首先进行初始化
			MOV			AX,DATA1
			MOV			DS,AX
			MOV			ES,AX
			MOV			AX,STACK1
			MOV			SS,AX
			MOV			SP,STACK_BTM
			
			;输出替换前的字符串
			MOV			SI,OFFSET	Initial
			CALL		DISPLAY
			MOV			SI,OFFSET	TargetStr
			CALL		DISPLAY
			CALL		NEWLINE
			;执行替换
			CALL		REPLACE
			;输出信息
			MOV			SI,OFFSET	Succeed
			CALL		DISPLAY
			CALL		NEWLINE
			MOV			SI,OFFSET	Current
			CALL		DISPLAY
			MOV			SI,OFFSET	TargetStr
			CALL		DISPLAY
			CALL		NEWLINE
			;结束
			MOV			AX,4C00H
			INT			21H
MAIN		ENDP

REPLACE		PROC
			;第一步,外循环遍历原字符串每一个字符
			MOV			SI,OFFSET	TargetStr
OutLoop:	
			MOV			AL,BYTE PTR [SI]
			CMP			AL,0
			JZ			_Replace_Exit;到达字符串结尾,结束
			JMP			Normal
_Replace_Exit:
			JMP			Replace_Exit
Normal:
			;字符与NameObj首字符比较
			PUSH		SI
			MOV			SI,OFFSET	NameObj
			MOV			BL,BYTE	PTR [SI]
			POP			SI
			CMP			AL,BL;进行比较
			JNZ			NotSame1
			;否则进入内循环
			PUSH		SI
						
			MOV			DI,OFFSET	NameObj
			InnerLoop:
						MOV			AL,BYTE PTR[SI]
						MOV			BL,BYTE PTR[DI]
						CMP			BL,00H
						JZ			SrcToObj
						CMP			AL,BL
						JNZ			InnerOver
						ADD			SI,1
						ADD			DI,1
						JMP			InnerLoop
			InnerOver:			
			POP			SI
NotSame1:
			ADD			SI,1
			JMP			OutLoop

SrcToObj: ;替换的核心
			;获取两个串的长度,SI暂时不需要复原
			MOV			SI,OFFSET	NameObj
			CALL		STR_LEN
			MOV			LEN1,AX
			MOV			SI,OFFSET	NameSrc
			CALL		STR_LEN
			MOV			LEN2,AX
			;SI复原,找到替换的起始点
			POP			SI
			MOV			DI,OFFSET	NameSrc
			;先比较替换串与被替换串的长度大小
			MOV			BX,LEN1
			CMP			BX,LEN2
			JB			ObjMinSrc
			SUB			BX,LEN2
			;先将内容替换
			R1:
					MOV		AL,BYTE PTR [DI]
					CMP		AL,0
					JZ		R1Next
					MOV		BYTE PTR[SI],AL
					INC		SI
					INC		DI
					JMP		R1
			R1Next:
					MOV		AL,BYTE PTR [BX+SI]
					MOV		BYTE PTR[SI],AL
					INC		SI
					CMP		AL,0
					JNZ		R1Next
			R1Over:
					JMP		Replace_Exit
						
ObjMinSrc:
			;先转移腾出空间
			PUSH		SI
			ADD			SI,LEN1
			MOV			DX,SI
			MOV			SI,OFFSET	TargetStr
			CALL		STR_LEN
			ADD			SI,AX
			MOV			BX,LEN2
			SUB			BX,LEN1
			R2:
					MOV		AL,BYTE PTR[SI]
					MOV		BYTE PTR[BX+SI],AL
					CMP		SI,DX
					JZ		R2Next
					DEC		SI
					JMP		R2
			R2Next:
					POP		SI
					MOV		DI,OFFSET	NameSrc
			_R2Next:
					MOV		AL,BYTE PTR [DI]
					CMP		AL,0
					JZ		R2Over
					MOV		BYTE PTR[SI],AL
					INC		SI
					INC		DI
					JMP		_R2Next
			R2Over:
					JMP		Replace_Exit
			
Replace_Exit:
			RET
REPLACE		ENDP

;字符串长度计算
STR_LEN		PROC
			PUSH		BX
			PUSH		SI
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
			POP			SI
			POP			BX
			RET
STR_LEN		ENDP

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

CODE1 		ENDS
			END		MAIN