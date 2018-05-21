STACK1		SEGMENT		PARA	STACK
STACK_AREA	DB			100H	DUP(?)
STACK_BTM	EQU			$-STACK_AREA
STACK1		ENDS

DATA1		SEGMENT		PARA
FuncArr		DW			7 		DUP(?)
;字符串空间区域
InitialStr	DB			30		DUP(0)
InitialStrArr	DB		10		DUP(30	DUP(0));二维数组,提供字典排序服务
ArrLen		DW			0;二维数组存储了多少个字符串,初始化0
ObjStr		DB			10		DUP(0)
SrcStr		DB			10		DUP(0)
Empty		DB			100		DUP(0);辅助
;定义输出菜单等字符串
MainMenu	DB			'1.UpToLow',9,'2.LowToUp',9,'3.Insert Str',9,'4.Delete Str',9,'5.Search Str',9,'6.Dict Sort',9,'7.Replace',9,'0.Exit',00H
InfoChoice	DB			'Please Input Your Choice:',00H
InfoExit	DB			'Procesure Exit Successfully.',00H
InfoInitialStr	DB		'Please Input the initial String:',00H
InfoInsertStr	DB		'Please Input the str you need to insert:',00H
InfoDelStr	DB			'Please Input the str you need to delete:',00H
InfoSearchStr	DB		'Please Input the str you need to search:',00H
InfoSubStrExist	DB		'The SubStr Exists.',00H
InfoSubStrLack	DB		'The SubStr Not Exist.',00H
InfoDictSort	DB		'Please Input each string divide by one space(no more than 10):',00H
InfoReplaceObj	DB		'Please Input the obj str:',00H
InfoReplaceSrc	DB		'Please Input the src str:',00H
InfoOutcome		DB		'Outcome is:',00H
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
			MOV			AX,OFFSET	H_UP_TO_LOW
			MOV			[SI],AX
			
			MOV			AX,OFFSET	H_LOW_TO_UP
			MOV			[SI+2],AX
			
			MOV			AX,OFFSET	H_INSERT_STR
			MOV			[SI+4],AX
			
			MOV			AX,OFFSET	H_DEL_SUBSTR
			MOV			[SI+6],AX
			
			MOV			AX,OFFSET	H_SEARCH_EXIST
			MOV			[SI+8],AX
			
			MOV			AX,OFFSET	H_DICT_SORT
			MOV			[SI+10],AX
			
			MOV			AX,OFFSET	H_REPLACE
			MOV			[SI+12],AX
			
			;使用一个while循环接受键盘的输入,如果是0,则退出
MENU_WHILE:
			MOV			SI,OFFSET	MainMenu
			CALL		DISPLAY
			CALL		NEWLINE
			
			MOV			SI,OFFSET	InfoChoice
			CALL		DISPLAY
			
			CALL		GETNUM
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

;大写转小写
H_UP_TO_LOW	PROC
			;压栈
			PUSH		SI
			
			MOV			SI,OFFSET	InfoInitialStr
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr	
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			PUSH		SI
			CALL		UP_TO_LOW
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			
			MOV			SI,OFFSET	InitialStr
			CALL		DISPLAY
			
			CALL		NEWLINE
			
			;弹栈
			POP			SI
			RET
H_UP_TO_LOW	ENDP

UP_TO_LOW	PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
				
			MOV			SI,[BP+4]
LOOP1:
			MOV			AL,BYTE PTR[SI]
			CMP			AL,0
			JZ			Exit1
			CMP			AL,'a'
			JGE			Next1
			ADD			AL,32
			MOV			BYTE PTR[SI],AL
Next1:
			INC			SI
			JMP			LOOP1

Exit1:			
			POP			SI
			POP			BP
			RET			2
UP_TO_LOW	ENDP

;小写转大写
H_LOW_TO_UP	PROC
			;压栈
			PUSH		SI
			
			MOV			SI,OFFSET	InfoInitialStr
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr	
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			PUSH		SI
			CALL		LOW_TO_UP
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			
			MOV			SI,OFFSET	InitialStr
			CALL		DISPLAY
			
			CALL		NEWLINE
			
			;弹栈
			POP			SI
			RET
H_LOW_TO_UP	ENDP

LOW_TO_UP	PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
				
			MOV			SI,[BP+4]
LOOP2:
			MOV			AL,BYTE PTR[SI]
			CMP			AL,0
			JZ			Exit2
			CMP			AL,'a'
			JB			Next2
			SUB			AL,32
			MOV			BYTE PTR[SI],AL
Next2:
			INC			SI
			JMP			LOOP2
			
Exit2:
			POP			SI
			POP			BP
			RET			2
LOW_TO_UP	ENDP

;增加字符串
H_INSERT_STR	PROC
			PUSH		SI
			
			MOV			SI,OFFSET	InfoInitialStr
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			MOV			SI,OFFSET	InfoInsertStr
			CALL		DISPLAY
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			CALL		INSERT_STR
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr
			CALL		DISPLAY
			CALL		NEWLINE
			
			POP			SI
			RET
H_INSERT_STR	ENDP

INSERT_STR	PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			PUSH		DI
			
			MOV			SI,[BP+6]
			MOV			DI,[BP+4]
			
			;先移动源串指针到尾部
			PUSH		SI
			CALL		CACULATE_STR_LEN
			ADD			SI,AX
InsertLoop:
			MOV			AL,BYTE	PTR[DI]
			CMP			AL,0
			JZ			InsertExit
			MOV			BYTE PTR[SI],AL
			INC			SI
			INC			DI
			JMP			InsertLoop
InsertExit:
			MOV			BYTE PTR[SI],0;尾部补0
			POP			DI
			POP			SI
			POP			BP
			RET			4
INSERT_STR	ENDP

;删除子串
H_DEL_SUBSTR	PROC
			PUSH		SI
			
			MOV			SI,OFFSET	InfoInitialStr
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			MOV			SI,OFFSET	InfoDelStr
			CALL		DISPLAY
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			
			CALL		DEL_SUBSTR
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr
			CALL		DISPLAY
			CALL		NEWLINE
			
			POP			SI
			RET
H_DEL_SUBSTR	ENDP
			
DEL_SUBSTR	PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			PUSH		DI
			PUSH		BX
			PUSH		CX
			
			MOV			SI,[BP+6]
			MOV			DI,[BP+4]
			
			MOV			BX,0
			;第一步,先查找,找到置BX为1,否则BX为0
DelLoop1:
			MOV			AL,BYTE PTR[SI]
			CMP			AL,0
			JZ			DelLoop1Exit
			
			CMP			AL,BYTE PTR[DI]
			JZ			_DelLoop2
			INC			SI
			JMP			DelLoop1
_DelLoop2:	
			PUSH		SI
			PUSH		DI
DelLoop2:
			MOV			AL,BYTE PTR[DI]
			CMP			AL,0
			JZ			Find
			CMP			AL,BYTE PTR[SI]
			JNZ			DelLoop2Exit
			INC			SI
			INC			DI
			JMP			DelLoop2
DelLoop2Exit:
			POP			DI
			POP			SI
			INC			SI
			JMP			DelLoop1
Find:		
			;先弹栈
			POP			DI
			POP			AX;SI值不还原，是为了能够直接进行删除操作
			MOV			BX,1
DelLoop1Exit:
			;下一步进行删除
			CMP			BX,0
			JZ			DeleteExit
			MOV			DI,[BP+4]
			PUSH		DI
			CALL		CACULATE_STR_LEN
			MOV			DI,SI
			SUB        	DI,AX;DI确定,下面计算CX
			PUSH		SI
			CALL		CACULATE_STR_LEN
			MOV			CX,AX
			INC			CX;为了补0
			CLD
			REP   		MOVSB
	
DeleteExit:					
			POP			CX
			POP			BX
			POP			DI
			POP			SI
			POP			BP
			RET			4
DEL_SUBSTR	ENDP

;查找是否存在子串
H_SEARCH_EXIST	PROC
			PUSH		SI
			
			MOV			SI,OFFSET	InfoInitialStr
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			MOV			SI,OFFSET	InfoSearchStr
			CALL		DISPLAY
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			
			CALL		SEARCH_EXIST
			PUSH		AX
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			POP			AX
			CMP			AX,1
			JZ			H_SearFind
			MOV			SI,OFFSET	InfoSubStrLack
			CALL		DISPLAY		
			JMP			H_SearExit
H_SearFind:
			MOV			SI,OFFSET	InfoSubStrExist
			CALL		DISPLAY
H_SearExit:
			CALL		NEWLINE
			POP			SI
			RET
H_SEARCH_EXIST	ENDP

SEARCH_EXIST	PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			PUSH		DI
			
			MOV			SI,[BP+6]
			MOV			DI,[BP+4]
			
SearLoop1:
			MOV			AL,BYTE PTR[SI]
			CMP			AL,0
			JZ			SearLoop1Exit
			
			CMP			AL,BYTE PTR[DI]
			JZ			_SearLoop2
			INC			SI
			JMP			SearLoop1
_SearLoop2:	
			PUSH		SI
			PUSH		DI
SearLoop2:
			MOV			AL,BYTE PTR[DI]
			CMP			AL,0
			JZ			SearFind
			CMP			AL,BYTE PTR[SI]
			JNZ			SearLoop2Exit
			INC			SI
			INC			DI
			JMP			SearLoop2
SearLoop2Exit:
			POP			DI
			POP			SI
			INC			SI
			JMP			SearLoop1
SearFind:		
			;先弹栈
			POP			DI
			POP			SI
			MOV			AX,1
			JMP			SearExit
SearLoop1Exit:
			MOV			AX,0
SearExit:
			POP			DI
			POP			SI
			POP			BP
			RET			4
SEARCH_EXIST	ENDP

;排序
H_DICT_SORT	PROC
			;压栈
			PUSH		SI
			PUSH		CX
			PUSH		DX
			
			MOV			SI,OFFSET	InfoDictSort
			CALL		DISPLAY
			CALL		GET_SERIES_STRS
			
			;参数栈传参,第一个参数数组首地址,第二个参数字符串个数
			MOV			AX,OFFSET	InitialStrArr
			PUSH		AX
			MOV			AX,ArrLen
			PUSH		AX
			CALL		DICT_SORT
			
			;输出数组
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			
			MOV			SI,OFFSET	InitialStrArr
			MOV			CX,ArrLen
H_DictLoop:
			CALL		DISPLAY
			MOV			DL,' '
			MOV			AH,2
			INT 		21H
			ADD			SI,30
			LOOP		H_DictLoop
			
			CALL		NEWLINE
			;弹栈
			POP         DX
			POP			CX
			POP			SI
			RET
H_DICT_SORT	ENDP

DICT_SORT	PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			PUSH		DI
			PUSH		BX
			PUSH		CX
			;使用冒泡排序
LP1:
			MOV			BX,1
			MOV			CX,[BP+4]
			DEC			CX
			MOV			SI,[BP+6]
LP2:
			PUSH		SI
			MOV			AX,SI
			ADD			AX,30
			PUSH		AX
			CALL		STRCMP
			CMP			AX,1
			JB			CONTINUE
			PUSH		SI
			MOV			AX,SI
			ADD			AX,30
			PUSH		AX
			CALL		STR_XCHG
			MOV			BX,0
CONTINUE:
			ADD			SI,30
			LOOP		LP2
			CMP			BX,1
			JZ			SORT_EXIT
			JMP			LP1
SORT_EXIT:
			;弹栈
			POP			CX
			POP			BX
			POP			DI
			POP			SI
			POP			BP
			RET			4
DICT_SORT	ENDP

;替换
H_REPLACE	PROC
			;压栈
			PUSH		SI
			MOV			SI,OFFSET	InfoInitialStr
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			MOV			SI,OFFSET	InfoReplaceObj
			CALL		DISPLAY
			MOV			SI,OFFSET	ObjStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			MOV			SI,OFFSET	InfoReplaceSrc
			CALL		DISPLAY
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			CALL		GET_SINGLE_STR
			
			MOV			SI,OFFSET	InitialStr
			PUSH		SI
			MOV			SI,OFFSET	ObjStr
			PUSH		SI
			MOV			SI,OFFSET	SrcStr
			PUSH		SI
			CALL		REPLACE
			
			MOV			SI,OFFSET	InfoOutcome
			CALL		DISPLAY
			MOV			SI,OFFSET	InitialStr
			CALL		DISPLAY
			CALL		NEWLINE
			;弹栈
			POP			SI
			RET
H_REPLACE	ENDP
;参数说明,第一个参数是原字符串地址，第二个参数是需要替换的子串地址，第三个参数是提供的子串地址
REPLACE		PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			PUSH		DI
			PUSH		BX
			PUSH		CX
			;首先进行子串对比查找，找到替换点
			MOV			SI,[BP+8]
			MOV			DI,[BP+6]
			MOV			BX,0
			
ReplaceLoop1:
			MOV			AL,BYTE PTR[SI]
			CMP			AL,0
			JZ			ReplaceLoop1Exit
			CMP			AL,BYTE PTR[DI]
			JZ			_ReplaceLoop2
			INC			SI
			JMP			ReplaceLoop1
_ReplaceLoop2:
			PUSH		SI
			PUSH		DI
ReplaceLoop2:
			MOV			AL,BYTE PTR[DI]
			CMP			AL,0
			JZ			ReplaceFind
			CMP			AL,BYTE PTR[SI]
			JNZ			ReplaceLoop2Exit
			INC			SI
			INC			DI
			JMP			ReplaceLoop2
ReplaceLoop2Exit:
			POP			DI
			POP			SI
			INC			SI
			JMP			ReplaceLoop1
ReplaceFind:
			MOV			BX,1
			POP			DI
			POP			AX;SI值不改

ReplaceLoop1Exit:
			;查找结束,进行替换
			CMP			BX,0
			JZ			ReplaceExit
			MOV			AX,[BP+6]
			PUSH		AX
			CALL		CACULATE_STR_LEN
			MOV			BX,AX
			MOV			AX,[BP+4]
			PUSH		AX
			CALL		CACULATE_STR_LEN
			CMP			BX,AX
			JB			M_C;先移动后替换
			;进行先替换后移动
			PUSH		SI
			SUB			SI,BX;SI置为复制起点
			SUB			BX,AX
			PUSH		BX;差值保存
			MOV			DI,[BP+4]
			XCHG		SI,DI
			MOV			CX,AX
			CLD
C_M_LOOP1:
			LODSB
			STOSB
			LOOP		C_M_LOOP1
			;移动
			POP			AX
			POP			SI
			MOV			DI,SI
			SUB			DI,AX
			PUSH		SI
			CALL		CACULATE_STR_LEN
			MOV			CX,AX
			INC			CX
			CLD
C_M_LOOP2:
			LODSB
			STOSB
			LOOP		C_M_LOOP2
			JMP 		ReplaceExit
			
M_C:
			SUB			AX,BX
			PUSH		AX
			PUSH		SI
			CALL		CACULATE_STR_LEN
			MOV			BX,AX
			POP			AX
			PUSH		SI;SI很重要,作为替换串替换起始点的计算媒介
			ADD			SI,BX
			INC			BX;为了补0而增加以此循环
			MOV			CX,BX;
			MOV			BX,AX
M_C_LOOP1:
			MOV			AL,BYTE PTR[SI]
			MOV			BYTE PTR[BX+SI],AL
			DEC			SI
			LOOP		M_C_LOOP1
			;循环结束进行复制
			POP			SI
			MOV			AX,[BP+6]
			PUSH		AX
			CALL		CACULATE_STR_LEN
			SUB			SI,AX;SI置为复制起点
			MOV			AX,[BP+4]
			PUSH		AX
			CALL		CACULATE_STR_LEN
			MOV			CX,AX
			MOV			DI,[BP+4]
			XCHG		SI,DI
			CLD
M_C_LOOP2:
			LODSB
			STOSB
			LOOP		M_C_LOOP2
ReplaceExit:
			;弹栈
			POP			CX
			POP			BX
			POP			DI
			POP			SI
			POP			BP
			RET			6
REPLACE		ENDP

;两个字符串交换,压栈传参
STR_XCHG	PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			PUSH		DI
			PUSH		CX
			
			MOV			SI,[BP+4]
			MOV			DI,[BP+6]
			
			MOV			CX,30
XchgLoop:
			MOV			AL,BYTE PTR[SI]
			XCHG		AL,BYTE PTR[DI]
			XCHG		AL,BYTE PTR[SI]
			INC			SI
			INC			DI
			LOOP		XchgLoop
			
			POP			CX
			POP			DI
			POP			SI
			POP			BP
			RET			4
STR_XCHG	ENDP

;STRCMP比较结果<或=,则返回0,>返回1,值在AX中
STRCMP		PROC
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			PUSH		DI
			PUSH		BX
			
			MOV			SI,[BP+6]
			MOV			DI,[BP+4]
STRCMP_LOOP1:		
			MOV			AL,BYTE	PTR[SI]
			MOV			BL,BYTE PTR[DI]
			CMP			AL,BL
			JB			SMALLER_EQUAL
			JG			BIGGER
			CMP			AL,0
			JZ			SMALLER_EQUAL
			INC			SI
			INC			DI
			JMP			STRCMP_LOOP1
			
SMALLER_EQUAL:			
			MOV			AX,0
			JMP			CMP_EXIT
BIGGER:
			MOV			AX,1
			JMP			CMP_EXIT
CMP_EXIT:
			POP			BX
			POP			DI
			POP			SI
			POP			BP
			RET			4
STRCMP		ENDP

;获取一个字符串,通过堆栈传参形式告知目的地址
GET_SINGLE_STR	PROC
			;压栈
			PUSH		BP
			MOV			BP,SP
			PUSH		SI
			
			MOV			SI,[BP+4]
SingleWhile:
			MOV			AH,1
			INT			21H
			CMP			AL,0DH
			JZ			SingleWhileExit
			MOV			BYTE PTR[SI],AL
			INC			SI
			JMP			SingleWhile
SingleWhileExit:
			MOV			BYTE PTR[SI],0;字符串末尾\0
			;弹栈
			POP			SI
			POP			BP
			RET			2
GET_SINGLE_STR	ENDP
;获取一系列字符串,以空格分隔,由于只给字典排序使用,不使用堆栈传参
GET_SERIES_STRS	PROC
			;进行计数器清0
			MOV			ArrLen,0
			;压栈
			PUSH		SI
			PUSH		DI
			MOV			SI,OFFSET	InitialStrArr
			MOV			DI,SI

SeriesWhile:
			MOV			AH,1
			INT			21H
			CMP			AL,0DH
			JZ			SeriesExit
			CMP			AL,' '
			JZ			DiviseSi
			MOV			BYTE PTR[DI],AL
			INC			DI
			JMP			SeriesWhile
DiviseSi:
			INC			ArrLen
			MOV			BYTE PTR[DI],0
			ADD			SI,30
			MOV			DI,SI
			JMP			SeriesWhile
SeriesExit:
			INC			ArrLen
			MOV			BYTE PTR[DI],0
			POP			DI
			POP			SI
			;弹栈
			RET	
GET_SERIES_STRS	ENDP
;getnumber
GETNUM		PROC
			;寄存器入栈
			PUSH		SI
			PUSH		BX
			PUSH		CX
			MOV			SI,0
			MOV			BX,10
GET_LOOP:
			MOV			AH,1
			INT			21H
			CMP			AL,0DH
			JZ			GET_EXIT
			SUB			AL,48
			MOV			CX,0
			MOV			CL,AL
			MOV			AX,SI
			MUL			BX
			ADD			AX,CX
			MOV			SI,AX
			JMP			GET_LOOP
GET_EXIT:
			MOV			AX,SI;返回值
			POP			CX
			POP			BX
			POP			SI
			RET
GETNUM	ENDP

;打印一个字符串
DISPLAY		PROC
			PUSH		SI
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
			POP			SI
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

;计算字符串长度
CACULATE_STR_LEN	PROC
			PUSH	BP
			MOV		BP,SP
			PUSH	SI
			PUSH	BX
			
			MOV		BX,0
			MOV		SI,[BP+4]
CaculateLoop:
			MOV		AL,BYTE PTR[SI]
			CMP		AL,0
			JZ		CaculateLoopExit
			INC		SI
			INC		BX
			JMP		CaculateLoop
CaculateLoopExit:
			MOV		AX,BX
			
			POP		BX
			POP		SI
			POP		BP
			RET		2
CACULATE_STR_LEN	ENDP
			
CODE1		ENDS
END			MAIN