.MODEL SMALL
.STACK 100H

.DATA
    password DB 20 DUP(?)    
    passLen DW ?            
    msg1 DB 'Set your password (max 20 chars): $'
    msg2 DB 0DH,0AH,'Password strength: $'
    msg3 DB 0DH,0AH,'Weak password! Try again$'
    msg4 DB 0DH,0AH,'Strong password! Saved successfully$'
    msg5 DB 0DH,0AH,'Enter password to continue: $'
    msg6 DB 0DH,0AH,'Incorrect password! Tries left: $'
    msg7 DB 0DH,0AH,'Access denied! Too many failed attempts$'
    msg8 DB 0DH,0AH,'Failed to set strong password in 3 attempts$' 
    ENDPROMPT DB 0DH,0AH,'THANK YOU FOR YOUR TIME. VISIT US AGAIN.$'
    attempts DB 3
    hasUpper DB 0
    hasLower DB 0
    hasDigit DB 0
    hasSpecial DB 0

    MENU_1 DB "DO YOU WANT TO ENCRYPT A STRING? $"
    MENU_6 DB 13, 10, "PRESS 1 IF YOU WANT TO ENCRYPT AND ANY OTHER KEY TO EXIT : $"
    ENC_MENU_1 DB 13, 10, "1. Make Uppercase.$"
    ENC_MENU_2 DB 13, 10, "2. Make Lowercase.$"
    ENC_MENU_3 DB 13, 10, "3. Reverse String.$"
    ENC_MENU_4 DB 13, 10, "4. Encrypt with Special Characters.$"
    ENC_MENU_5 DB 13, 10, "5. Apply All Options.$"
    ENC_MENU_6 DB 13, 10, "SELECT ENCRYPTION METHOD: $"
    MSG_1 DB 13, 10, "ENTER THE LENGTH OF YOUR STRING (1-9): $"
    MSG_2 DB 13, 10, "ENTER YOUR STRING: $"
    MSG_3 DB 13, 10, "YOUR OUTPUT IS: $"
    MSG_4 DB 13, 10, "DECRYPTED STRING IS: $"
    MSG_INVALID_LENGTH DB 13, 10, "Wrong key pressed. Press number between 0-9: $"
    MSG_INVALID_OPTION DB 13, 10, "Wrong key pressed. Please select from the existing options: $"
    MSG_INVALID_STRING DB 13, 10, "Wrong string pressed! Give the correct string: $"
    DECRYPT_PROMPT DB 13, 10, "DO YOU WANT TO SEE THE DECRYPTED VERSION? (Y/N): $"
    STRING_LENGTH DB ?
    STRING_ARRAY DB 20 DUP(0)
    ENC_STRING_ARRAY DB 20 DUP(0)
    RAND_SEED DW 1234h
    TEMP DB ?
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL SetPassword       
    
    CMP attempts, 0        
    JE EXIT_PROGRAM
    
    CALL CheckPassword     
    
    CMP attempts, 0        
    JE EXIT_PROGRAM  
    
    MOV AH,2
    MOV DL,0DH
    INT 21h
    MOV DL,0AH
    INT 21h
    
    MOV AH,2
    MOV DL,0DH
    INT 21h
    MOV DL,0AH
    INT 21h
    
    LEA DX, MENU_1
    MOV AH, 09H
    INT 21H 
    
    MOV AH, 2      
    MOV DL, 0DH 
    INT 21h
    MOV DL, 0AH
    INT 21h  
    
    LEA DX, MENU_6
    MOV AH, 09H
    INT 21H   

    MOV AH, 01H
    INT 21H     
    SUB AL, 30H
    CMP AL, 1
    JE ENCRYPTION
    JMP EXIT_PROGRAM

ENCRYPTION:  
    LEA DX, MSG_1
    MOV AH, 09H
    INT 21H

GET_LENGTH:
    MOV AH, 01H
    INT 21H
    
    CMP AL, '0'
    JL INVALID_LENGTH
    CMP AL, '9'
    JG INVALID_LENGTH
    
    SUB AL, 30H
    MOV STRING_LENGTH, AL
    JMP VALID_LENGTH

INVALID_LENGTH:
    LEA DX, MSG_INVALID_LENGTH
    MOV AH, 09H
    INT 21H
    JMP GET_LENGTH

VALID_LENGTH:
    LEA DX, MSG_2
    MOV AH, 09H
    INT 21H

TAKING_INPUT:
    XOR SI, SI
    MOV CL, STRING_LENGTH
    
INPUT_LOOP:
    PUSH CX
    MOV AH, 01H
    INT 21H
    
    CMP AL, 'A'
    JB INVALID_CHAR
    CMP AL, 'Z'
    JBE VALID_CHAR
    CMP AL, 'a'
    JB INVALID_CHAR
    CMP AL, 'z'
    JA INVALID_CHAR
    
VALID_CHAR:
    MOV STRING_ARRAY[SI], AL
    INC SI
    POP CX
    LOOP INPUT_LOOP
    JMP CONTINUE_PROG
    
INVALID_CHAR:
    POP CX
    LEA DX, MSG_INVALID_STRING
    MOV AH, 09H
    INT 21H
    JMP TAKING_INPUT
    
CONTINUE_PROG:
    LEA DX, ENC_MENU_1
    MOV AH, 09H
    INT 21H
    LEA DX, ENC_MENU_2
    MOV AH, 09H
    INT 21H
    LEA DX, ENC_MENU_3
    MOV AH, 09H
    INT 21H
    LEA DX, ENC_MENU_4
    MOV AH, 09H
    INT 21H
    LEA DX, ENC_MENU_5
    MOV AH, 09H
    INT 21H
    LEA DX, ENC_MENU_6
    MOV AH, 09H
    INT 21H

GET_OPTION:
    MOV AH, 01H
    INT 21H
    
    CMP AL, '1'
    JL INVALID_OPTION
    CMP AL, '5'
    JG INVALID_OPTION
    
    SUB AL, 30H
    
    CMP AL, 1
    JE ENC_UPPERCASE
    CMP AL, 2
    JE ENC_LOWERCASE
    CMP AL, 3
    JE ENC_REVERSE
    CMP AL, 4
    JE ENC_SPECIAL
    CMP AL, 5
    JE ENC_ALL
    JMP EXIT_PROGRAM

INVALID_OPTION:
    LEA DX, MSG_INVALID_OPTION
    MOV AH, 09H
    INT 21H
    JMP GET_OPTION

ENC_ALL:
    MOV CH, 0
    MOV CL, STRING_LENGTH
    MOV SI, 0
TO_ALL:
    PUSH CX                 
    MOV AH, 2Ch            
    INT 21h                
    MOV AL, DL             
    MUL DH                 
    ADD AL, TEMP           
    MOV TEMP, AL          
    AND AL, 7Fh           
    ADD AL, 33            
    MOV BL, AL            
    MOV AL, STRING_ARRAY[SI]
    XOR AL, BL            
    AND AL, 7Fh           
    CMP AL, 32            
    JL MAKE_PRINTABLE
    JMP STORE_CHAR

MAKE_PRINTABLE:
    ADD AL, 33            

STORE_CHAR:
    MOV ENC_STRING_ARRAY[SI], AL
    MOV DH, BL            
    INC SI
    POP CX                
    LOOP TO_ALL
    JMP PRINT_AND_DECRYPT

ENC_UPPERCASE:
    MOV CH, 0
    MOV CL, STRING_LENGTH
    MOV SI, 0
TO_UPPERCASE:
    MOV AL, STRING_ARRAY[SI]
    AND AL, 11011111b     
    MOV ENC_STRING_ARRAY[SI], AL
    INC SI
    LOOP TO_UPPERCASE
    JMP PRINT_AND_DECRYPT

ENC_LOWERCASE:
    MOV CH, 0
    MOV CL, STRING_LENGTH
    MOV SI, 0
TO_LOWERCASE:
    MOV AL, STRING_ARRAY[SI]
    OR AL, 00100000b      
    MOV ENC_STRING_ARRAY[SI], AL
    INC SI
    LOOP TO_LOWERCASE
    JMP PRINT_AND_DECRYPT

ENC_REVERSE:
    MOV CH, 0
    MOV CL, STRING_LENGTH
    MOV SI, 0
    MOV AH, 0
    MOV AL, STRING_LENGTH
    DEC AL
    MOV DI, AX
TO_REVERSE:
    MOV AL, STRING_ARRAY[DI]
    MOV ENC_STRING_ARRAY[SI], AL
    DEC DI
    INC SI
    LOOP TO_REVERSE
    JMP PRINT_AND_DECRYPT

ENC_SPECIAL:
    MOV CH, 0
    MOV CL, STRING_LENGTH
    MOV SI, 0
TO_SPECIAL:
    PUSH CX                 
    MOV AH, 2Ch            
    INT 21h                
    MOV AL, DL             
    MUL DH                 
    AND AL, 00001111b      
    CMP AL, 5              
    JL RANGE1
    CMP AL, 10             
    JL RANGE2
    JMP RANGE3             
    
RANGE1:                    
    AND AL, 00000111b      
    ADD AL, 33
    JMP STORE_SPECIAL

RANGE2:                    
    AND AL, 00000111b      
    ADD AL, 58
    JMP STORE_SPECIAL

RANGE3:                    
    AND AL, 00000111b      
    ADD AL, 91

STORE_SPECIAL:
    MOV ENC_STRING_ARRAY[SI], AL
    INC SI
    POP CX                 
    LOOP TO_SPECIAL
    JMP PRINT_AND_DECRYPT

PRINT_AND_DECRYPT:
    LEA DX, MSG_3
    MOV AH, 09H
    INT 21H
    MOV CH, 0
    MOV CL, STRING_LENGTH
    MOV SI, 0
PRINTING:
    MOV DL, ENC_STRING_ARRAY[SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PRINTING

    LEA DX, DECRYPT_PROMPT
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    
    AND AL, 11011111b
    
    CMP AL, 'Y'
    JE DECRYPT_STRING
    JMP EXIT_PROGRAM

DECRYPT_STRING:
    LEA DX, MSG_4
    MOV AH, 09H
    INT 21H

    MOV CH, 0
    MOV CL, STRING_LENGTH
    MOV SI, 0
DECRYPT_LOOP:
    MOV AL, STRING_ARRAY[SI]    
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP DECRYPT_LOOP

EXIT_PROGRAM: 
    MOV AH,2
    MOV DL,0DH
    INT 21h
    MOV DL,0AH
    INT 21h
    
    MOV AH, 09H           
    LEA DX, ENDPROMPT           
    INT 21H 
    
    MOV AH, 4CH
    INT 21H

MAIN ENDP

SetPassword PROC
    MOV attempts, 3
    
SetPassLoop:
    LEA DX, msg1
    MOV AH, 9
    INT 21H
    
    XOR CX, CX
    LEA SI, password
    
InputLoop:
    MOV AH, 1
    INT 21H
    
    CMP AL, 0DH
    JE EndInput
    
    MOV [SI], AL
    INC SI
    INC CX
    CMP CX, 20
    JB InputLoop
    
EndInput:
    MOV passLen, CX
    
    CALL CheckStrength
    
    CMP hasUpper, 1
    JNE WeakPass
    CMP hasLower, 1
    JNE WeakPass
    CMP hasDigit, 1
    JNE WeakPass
    CMP hasSpecial, 1
    JNE WeakPass
    
    LEA DX, msg4
    MOV AH, 9
    INT 21H
    RET
    
WeakPass:
    LEA DX, msg3
    MOV AH, 9
    INT 21H
    DEC attempts
    JNZ SetPassLoop
    
    LEA DX, msg8
    MOV AH, 9
    INT 21H
    MOV attempts, 0
    RET
SetPassword ENDP

CheckStrength PROC
    PUSH SI
    PUSH CX
    
    LEA SI, password
    MOV CX, passLen
    
    MOV hasUpper, 0
    MOV hasLower, 0
    MOV hasDigit, 0
    MOV hasSpecial, 0
    
CheckLoop:
    MOV AL, [SI]
    
    CMP AL, 'A'
    JB NotUpper
    CMP AL, 'Z'
    JA NotUpper
    MOV hasUpper, 1
    JMP NextChar
    
NotUpper:
    CMP AL, 'a'
    JB NotLower
    CMP AL, 'z'
    JA NotLower
    MOV hasLower, 1
    JMP NextChar
    
NotLower:
    CMP AL, '0'
    JB NotDigit
    CMP AL, '9'
    JA NotDigit
    MOV hasDigit, 1
    JMP NextChar
    
NotDigit:
    MOV hasSpecial, 1
    
NextChar:
    INC SI
    LOOP CheckLoop
    
    POP CX
    POP SI
    RET
CheckStrength ENDP

CheckPassword PROC
    MOV attempts, 3
    
TryPassword:
    LEA DX, msg5
    MOV AH, 9
    INT 21H
    
    LEA SI, password
    MOV CX, passLen
    
CompareLoop:
    MOV AH, 1
    INT 21H
    
    CMP AL, 0DH
    JE PasswordMatch
    
    CMP AL, [SI]
    JNE WrongPassword
    INC SI
    LOOP CompareLoop
    
PasswordMatch:
    CMP CX, 0
    JE AccessGranted
    
WrongPassword:
    DEC attempts
    JZ AccessDenied
    
    LEA DX, msg6
    MOV AH, 9
    INT 21H
    
    MOV DL, attempts
    ADD DL, '0'
    MOV AH, 2
    INT 21H
    
    JMP TryPassword
    
AccessDenied:
    LEA DX, msg7
    MOV AH, 9
    INT 21H
    RET
    
AccessGranted:
    RET
CheckPassword ENDP

END MAIN