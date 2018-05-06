STACK1 SEGMENT PARA STACK
STACK_AREA  DW  100H DUP(?)
STACK_BTM   EQU $-STACK_AREA
STACK1 ENDS

DATA1 SEGMENT
TABLE_LEN   DW  16
CX_TMP      DW  ?   ;CX循环计数器的临时保存点
TABLE       DW  200,300,400,10,20,0,1,8
            DW  41H,40,42H,50,60,0FFFH,2,3
CharArr     DB  10 DUP(?)
Count       DW  0;循环除法计数器
DATA1   ENDS

CODE1 SEGMENT
        ASSUME  CS:CODE1, DS:DATA1, SS:STACK1

MAIN    PROC    FAR
        MOV     AX,STACK1
        MOV     SS,AX
        MOV     SP,STACK_BTM
        MOV     AX,DATA1
        MOV     DS,AX

LP1:    MOV     BX,1
        MOV     CX,TABLE_LEN
        DEC     CX
        MOV     SI,OFFSET TABLE
LP2:    MOV     AX,[SI]
        CMP     AX,[SI+2]
        JGE     CONTINUE
        XCHG    AX,[SI+2]
        MOV     [SI],AX
        MOV     BX,0
CONTINUE:   ADD     SI,2
            LOOP    LP2
            CMP     BX,1
            JZ      PRINT
            JMP     SHORT LP1

PRINT:      MOV     CX,TABLE_LEN        ;打印处理
            MOV     SI,OFFSET TABLE

PRINT_INNER_LOOP:
            MOV     CX_TMP,CX
            MOV     AX,[SI]

            MOV     BX,10 ;循环除以10
            MOV     DX,0
            MOV     Count,0;计数器清0
DIV_TEN_WHILE:
            DIV     BX
            ADD     DX,48
            MOV     DI,Count
            ADD     DI,OFFSET CharArr
            ADD     Count,1;计数器加一
            MOV     BYTE PTR[DI],DL

            ;下面判断商是否为0，为0则退出循环
            MOV     DX,0
            CMP     AX,0
            JNE     DIV_TEN_WHILE

            ;进行反向字符输出
            MOV     CX,Count
OutScreen:
            MOV     DI,CX
            SUB     DI,1
            ADD     DI,OFFSET CharArr
            MOV     DL,BYTE PTR[DI]
            MOV     AH,2
            INT     21H
            LOOP    OutScreen

            MOV     AH,2
            MOV     DL,9
            INT     21H

            ADD     SI,2
            MOV     CX,CX_TMP
            LOOP    PRINT_INNER_LOOP
            JMP     EXIT

EXIT:       MOV     AX,4C00H
            INT     21H
MAIN        ENDP
CODE1       ENDS
            END     MAIN