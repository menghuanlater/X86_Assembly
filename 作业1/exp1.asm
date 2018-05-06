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
            JZ      EXIT
            JMP     SHORT LP1

EXIT:       MOV     AX,4C00H
            INT     21H
MAIN        ENDP
CODE1       ENDS
            END     MAIN