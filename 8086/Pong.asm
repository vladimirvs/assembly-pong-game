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

 BALL_X DW 0Ah 		; x position of the ball
 BALL_Y DW 0Ah 		; y position of the ball
 BALL_SIZE DW 04h	; 4 on x 4 on y = 16 in total
 BALL_VELOCITY_X DW 05h ; 
 BALL_VELOCITY_Y DW 02h

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
	JMP CHECK_TIME	; after drawing check time again
		
	RET
	MAIN ENDP
	
	; Move ball
	MOVE_BALL PROC NEAR

		
		MOV AX, BALL_VELOCITY_X
		ADD BALL_X, AX
		MOV AX, WINDOW_BOUNDS
		CMP BALL_X, AX		; BALL_X < 0 (x collided)
		JL NEG_VELOCITY_X				; BALL_X > WINDOW_WIDTH (x collided)
		
		MOV AX, WINDOW_WIDTH
		SUB AX, BALL_SIZE
		SUB AX, WINDOW_BOUNDS
		CMP BALL_X, AX
		JG NEG_VELOCITY_X
		
		MOV AX, BALL_VELOCITY_Y		
		ADD BALL_Y, AX
		MOV AX, WINDOW_BOUNDS
		CMP	BALL_Y, AX		; BALL_Y < 0 (y collided)
		JL NEG_VELOCITY_Y
		MOV AX, WINDOW_HEIGHT ; BALL_Y > WINDOW_HEIGHT (y collided)
		SUB AX, BALL_SIZE
		SUB AX, WINDOW_BOUNDS
		CMP BALL_Y, AX
		JG NEG_VELOCITY_Y		
								
		RET
		
		NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X;
			RET
			
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y;
			RET
	
	MOVE_BALL ENDP
	
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

CODE ENDS
END