STACK1 SEGMENT PARA STACK
STACK_AREA  DW  100H DUP(?)
STACK_BTM   EQU $-STACK_AREA
STACK1 ENDS

DATA1 SEGMENT
TABLE_LEN   DW  16
TABLE       DW  200,300,400,10,20,0,1,8
            DW  41H,40,42H,50,60,0FFFH,2,3
DATA1   ENDS

CODE1 SEGMENT
        ASSUME  CS:CODE1, DS:DATA1, SS:STACK1

ByteToChar PROC
        ;首先进行高12位清零
        AND     AX,000FH
        CMP     AX,10
        JGE     Alpha
        ADD     AX,48
        MOV     DL,AL
        JMP     OutScreen
Alpha:  ADD     AX,55
        MOV     DL,AL
OutScreen:
        MOV     AH,2
        INT     21H
        RET
ByteToChar ENDP

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
            MOV     BX,CX
            MOV     AX,[SI];进行第一个4字节转字符
            MOV     CL,12
            SHR     AX,CL
            CALL    ByteToChar

            MOV     AX,[SI];第二个四字节转字符
            MOV     CL,8
            SHR     AX,CL
            CALL    ByteToChar

            MOV     AX,[SI];第三个四字节转字符
            MOV     CL,4
            SHR     AX,CL
            CALL    ByteToChar

            MOV     AX,[SI];第四个四字节转字符
            CALL    ByteToChar

            ;显示H以及\t
            MOV     AH,2
            MOV     DL,72
            INT     21H

            MOV     DL,9
            INT     21H

            ADD     SI,2
            MOV     CX,BX
            LOOP    PRINT_INNER_LOOP
            JMP     EXIT

EXIT:       MOV     AX,4C00H
            INT     21H
MAIN        ENDP
CODE1       ENDS
            END     MAIN