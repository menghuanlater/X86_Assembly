STACK1		SEGMENT		PARA	STACK
STACK_AREA	DW			100H	DUP(?)
STACK_BTM 	EQU			$-STACK_AREA
STACK1		ENDS

DATA1		SEGMENT		PARA
StrArr		DW			10		DUP(?);保存排序好的十个字符串的首地址
StrArrLen	DW			10
Str1		DB			'Golley',00H
Str2		DB			'Elling',00H
Str3		DB			'Abily',00H
Str4		DB			'Orange',00H
Str5		DB			'Jungle',00H
Str6		DB			'Zazoo',00H
Str7		DB			'Katto',00H
Str8		DB			'Bilibili',00H
Str9		DB			'Pandas',00H
Str10		DB			'Shell',00H	
DATA1		ENDS

CODE1		SEGMENT		PARA
			ASSUME		CS:CODE1,	DS:DATA1,	SS:STACK1
			
MAIN		PROC		FAR
			MOV			AX,DATA1
			MOV			DS,AX
			MOV			AX,STACK1
			MOV			SS,AX
			MOV			SP,STACK_BTM
			
			CALL		LOAD_ADDR
			;下面进行排序
			CALL		DICT_SORT
			;排序结果显示
			CALL		OUTCOME
			
			MOV			AX,4C00H
			INT			21H
MAIN		ENDP

;加载十个字符串首地址到数组中去
LOAD_ADDR	PROC
			MOV			AX,OFFSET	Str1
			MOV			StrArr,AX
			
			MOV			AX,OFFSET	Str2
			MOV			StrArr+2,AX
			
			MOV			AX,OFFSET	Str3
			MOV			StrArr+4,AX
			
			MOV			AX,OFFSET	Str4
			MOV			StrArr+6,AX
			
			MOV			AX,OFFSET	Str5
			MOV			StrArr+8,AX
			
			MOV			AX,OFFSET	Str6
			MOV			StrArr+10,AX
			
			MOV			AX,OFFSET	Str7
			MOV			StrArr+12,AX
			
			MOV			AX,OFFSET	Str8
			MOV			StrArr+14,AX
			
			MOV			AX,OFFSET	Str9
			MOV			StrArr+16,AX
			
			MOV			AX,OFFSET	Str10
			MOV			StrArr+18,AX
			RET
LOAD_ADDR	ENDP			
			
OUTCOME		PROC
			MOV			SI,OFFSET	StrArr
			MOV			CX,StrArrLen
LOOP2:		PUSH		SI
			MOV			SI,[SI]
			CALL		DISPLAY
			CALL		NEWLINE
			POP			SI
			ADD			SI,2
			LOOP		LOOP2
			
			RET
OUTCOME		ENDP

;字典排序函数
DICT_SORT		PROC
LP1:
			MOV			BX,1
			MOV			CX,StrArrLen
			DEC			CX
			MOV			SI,OFFSET	StrArr
LP2:
			PUSH		SI
			PUSH		DI
			MOV			AX,[SI]
			MOV			DI,[SI+2]
			MOV			SI,AX
			CALL		STRCMP
			POP			DI
			POP			SI
			CMP			AX,1
			JB			CONTINUE
			MOV			AX,[SI]
			XCHG		AX,[SI+2]
			MOV			[SI],AX
			MOV			BX,0
CONTINUE:
			ADD			SI,2
			LOOP		LP2
			CMP			BX,1
			JZ			SORT_EXIT
			JMP			LP1
SORT_EXIT:
			RET
DICT_SORT	ENDP

;STRCMP,字符串1首地址在SI中,字符串2首地址在DI中,比较结果<或=,则返回0,>返回1,值在AX中
STRCMP		PROC
			PUSH		BX
LOOP1:		MOV			AL,BYTE	PTR[SI]
			MOV			BL,BYTE PTR[DI]
			CMP			AL,BL
			JB			SMALLER_EQUAL
			JG			BIGGER
			CMP			AL,0
			JZ			SMALLER_EQUAL
			INC			SI
			INC			DI
			JMP			LOOP1
			
SMALLER_EQUAL:			
			MOV			AX,0
			JMP			CMP_EXIT
BIGGER:
			MOV			AX,1
			JMP			CMP_EXIT
CMP_EXIT:
			POP			BX
			RET
STRCMP		ENDP

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
			END         MAIN