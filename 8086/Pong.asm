STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS

; Data segment
; DW - Define Word (16 bit)
DATA SEGMENT PARA 'DATA'

 WINDOW_WIDTH DW 140h	; 320 pixels (width)
 WINDOW_HEIGHT DW 0C8h	; 200 pixels (height)
 WINDOW_BOUNDS DW 06h	; variable to check collisions early

 TIME_AUX DB 0		; Variable to check if the time has changed
 
 BALL_ORIGINAL_X DW 0A0h
 BALL_ORIGINAL_Y DW 64h

 BALL_X DW 0A0h 		; x position of the ball
 BALL_Y DW 64h 		; y position of the ball
 BALL_SIZE DW 04h	; 4 on x 4 on y = 16 in total
 BALL_VELOCITY_X DW 05h ; 
 BALL_VELOCITY_Y DW 02h
 
 PADDLE_LEFT_X DW 0Ah;
 PADDLE_LEFT_Y DW 0Ah
 
 PADDLE_RIGHT_X DW 130h
 PADDLE_RIGHT_Y DW 0Ah
 
 PADDLE_WIDTH DW 05h;
 PADDLE_HEIGHT DW 1Fh;

 PADDLE_VELOCITY DW 05h

	
DATA ENDS

CODE SEGMENT PARA 'CODE'
	MAIN PROC FAR
	;Tell assembly where our variables are
	;CS - Code Segment name
	;DS - Data Segment name
	;SS - Stack Segment name
	ASSUME CS:CODE, DS:DATA, SS:STACK
	
	PUSH DS 		; push to the stack the DS segment
	SUB AX, AX 		; Clean accumulator
	PUSH AX 		; Push AX to the stack
	MOV AX, DATA	; Save on the AX data content 
	MOV DS,AX		; Save on DS, the contents of AX
	POP AX			; Release top of stack to the AX register
	POP AX			; Release top of stack to the AX register
	

	CHECK_TIME:
	
	MOV AH, 2Ch		; Get system time
	INT 21h			; Return: CH = hour CL = minute DH = second DL = 1/100 seconds
		
	CMP DL, TIME_AUX; if the current time == to prev (TIME_AUX) ?
	JE CHECK_TIME	; if it is the same, check again
	
	; reach this if time is different
	MOV TIME_AUX, DL 	; update time
			
	CALL CLEAR_SCREEN
	CALL MOVE_BALL
		
	CALL CLEAR_SCREEN
	CALL DRAW_BALL
	
	
	
	CALL MOVE_PADDLES
	CALL DRAW_PADDLES
	
	
	
	
	JMP CHECK_TIME	; after drawing check time again
		
	RET
	MAIN ENDP
	
	
	
	; Draw paddles
	DRAW_PADDLES PROC NEAR
		MOV CX, PADDLE_LEFT_X
		MOV DX, PADDLE_LEFT_Y
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			mov AH,0Ch ; set config to write pixel
			mov AL,0Bh ; green
			mov BH,00h ; page number
			int 10h
			
			INC CX		
			MOV AX,CX			
			SUB AX,PADDLE_LEFT_X
			CMP AX, PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
		
		
			MOV CX, PADDLE_LEFT_X	; the CX register back to initial ball_x
			INC DX			; advance line
			
			MOV AX, DX				
			SUB AX, PADDLE_LEFT_Y
			CMP AX, PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			
			; Right paddle
			MOV CX, PADDLE_RIGHT_X
			MOV DX, PADDLE_RIGHT_Y
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			mov AH,0Ch ; set config to write pixel
			mov AL,0Bh ; green
			mov BH,00h ; page number
			int 10h
			
			INC CX		
			MOV AX,CX			
			SUB AX,PADDLE_RIGHT_X
			CMP AX, PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
		
		
			MOV CX, PADDLE_RIGHT_X	; the CX register back to initial ball_x
			INC DX			; advance line
			
			MOV AX, DX				
			SUB AX, PADDLE_RIGHT_Y
			CMP AX, PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
		
	RET
	DRAW_PADDLES ENDP
	
	; Move ball
	MOVE_BALL PROC NEAR

		
		MOV AX, BALL_VELOCITY_X
		ADD BALL_X, AX
		MOV AX, WINDOW_BOUNDS
		CMP BALL_X, AX		; BALL_X < 0 (x collided)
		JL RESET_POSITION				; BALL_X > WINDOW_WIDTH (x collided)
		
		MOV AX, WINDOW_WIDTH
		SUB AX, BALL_SIZE
		SUB AX, WINDOW_BOUNDS
		CMP BALL_X, AX
		JG RESET_POSITION
		
		MOV AX, BALL_VELOCITY_Y		
		ADD BALL_Y, AX
		MOV AX, WINDOW_BOUNDS
		CMP	BALL_Y, AX		; BALL_Y < 0 (y collided)
		JL RESET_POSITION
		MOV AX, WINDOW_HEIGHT ; BALL_Y > WINDOW_HEIGHT (y collided)
		SUB AX, BALL_SIZE
		SUB AX, WINDOW_BOUNDS
		CMP BALL_Y, AX
		JG RESET_POSITION		
								
		RET
		
		RESET_POSITION:
			CALL RESET_BALL_POS
			RET
	
	MOVE_BALL ENDP
	
	
	MOVE_PADDLES PROC NEAR
	;left paddle move
	
	; check if any key is pressed if not check other paddle
	MOV AH, 01h
	INT 16h
	JZ CHECK_RIGHT_PADDLE_MOVEMENT ; if ZF - Zero Flag is set JZ jump if Zero
	
	; check which key is being pressed (AL will contain the ASCII code)
	MOV AH, 00h
	INT 16h
	; if it is 'w' up move up
	CMP AL, 057h ; W
	JE MOVE_LEFT_PADDLE_UP
	CMP AL, 077h ; w
	JE MOVE_LEFT_PADDLE_UP

	
	; if it is 's' move down
	CMP AL, 053h ; S
	JE MOVE_LEFT_PADDLE_DOWN
	CMP AL, 073h ; s
	JE MOVE_LEFT_PADDLE_DOWN

	JMP CHECK_RIGHT_PADDLE_MOVEMENT
	
	
	MOVE_LEFT_PADDLE_UP:
		MOV AX, PADDLE_VELOCITY
		SUB PADDLE_LEFT_Y, AX
		
		MOV AX, WINDOW_BOUNDS
		CMP PADDLE_LEFT_Y, AX
		JL FIX_LEFT_PADDLE_TOP
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		FIX_LEFT_PADDLE_TOP:
			MOV AX, WINDOW_BOUNDS
			MOV PADDLE_LEFT_Y, AX
		
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
	MOVE_LEFT_PADDLE_DOWN:
		MOV AX, PADDLE_VELOCITY
		ADD PADDLE_LEFT_Y, AX
		
		MOV AX,WINDOW_HEIGHT
		SUB AX, WINDOW_BOUNDS
		SUB AX, PADDLE_HEIGHT
		CMP PADDLE_LEFT_Y, AX
		JG FIX_LEFT_PADDLE_BOTTOM
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		FIX_LEFT_PADDLE_BOTTOM:
			MOV PADDLE_LEFT_Y, AX
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
	
	;right paddle move
	CHECK_RIGHT_PADDLE_MOVEMENT:
	
	
	;if it is 'o' or 'O' move up
			CMP AL,6Fh ;'o'
			JE MOVE_RIGHT_PADDLE_UP
			CMP AL,4Fh ;'O'
			JE MOVE_RIGHT_PADDLE_UP
			
			;if it is 'l' or 'L' move down
			CMP AL,6Ch ;'l'
			JE MOVE_RIGHT_PADDLE_DOWN
			CMP AL,4Ch ;'L'
			JE MOVE_RIGHT_PADDLE_DOWN
			JMP EXIT_PADDLE_MOVEMENT

	
	
	
	MOVE_RIGHT_PADDLE_UP:
		MOV AX, PADDLE_VELOCITY
		SUB PADDLE_RIGHT_Y, AX
		
		MOV AX, WINDOW_BOUNDS
		CMP PADDLE_RIGHT_Y, AX
		JL FIX_RIGHT_PADDLE_TOP
		JMP EXIT_PADDLE_MOVEMENT
		
		
		FIX_RIGHT_PADDLE_TOP:
			MOV AX, WINDOW_BOUNDS
			MOV PADDLE_RIGHT_Y, AX
			JMP EXIT_PADDLE_MOVEMENT
		
		
		
	MOVE_RIGHT_PADDLE_DOWN:
		MOV AX, PADDLE_VELOCITY
		ADD PADDLE_RIGHT_Y, AX
		
		MOV AX,WINDOW_HEIGHT
		SUB AX, WINDOW_BOUNDS
		SUB AX, PADDLE_HEIGHT
		CMP PADDLE_RIGHT_Y, AX
		JG FIX_RIGHT_PADDLE_BOTTOM
		JMP EXIT_PADDLE_MOVEMENT
		
		
		FIX_RIGHT_PADDLE_BOTTOM:
			MOV PADDLE_RIGHT_Y, AX
			JMP EXIT_PADDLE_MOVEMENT
			
	EXIT_PADDLE_MOVEMENT:
	
	
	RET
	MOVE_PADDLES ENDP
	
	
	; clear screen
	CLEAR_SCREEN PROC NEAR
		; clear the screen
		mov AH, 00h ; set video mode
		mov AL, 13h ; 13  320x200 256 color graphics (MCGA,VGA)
		int 10h		; execute interruption
			
		; background color
		mov AH,0Bh
		mov BH, 00h
		mov BL, 00h ; black color
		int 10h
		; 
	RET
	CLEAR_SCREEN ENDP
	
	; draw a pixel
	DRAW_BALL PROC NEAR
		mov CX,BALL_X ; initial x = 10
		mov DX,BALL_Y ; initial y = 10
		
		DRAW_BALL_HORIZONTAL:
			mov AH,0Ch ; set config to write pixel
			mov AL,0Ah ; green
			mov BH,00h ; page number
			int 10h
			
			INC CX		;CX = CX + 1
			MOV AX,CX			;CX - BALL_X > BALL_SIZE ( if true we go to the next line)
			SUB AX,BALL_X
			CMP AX, BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL ; CX - BALL_X > BALL_SIZE = false
			
			MOV CX, BALL_X	; the CX register back to initial ball_x
			INC DX			; advance line
			
			MOV AX, DX				; DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure, N -> continue)
			SUB AX, BALL_Y
			CMP AX, BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		
		RET
	DRAW_BALL ENDP
	
	RESET_BALL_POS PROC NEAR
		MOV AX, BALL_ORIGINAL_X
		MOV BALL_X, AX
		
		MOV AX, BALL_ORIGINAL_Y
		MOV BALL_Y, AX
	RET
	RESET_BALL_POS ENDP

CODE ENDS
END