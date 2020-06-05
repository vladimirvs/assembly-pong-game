STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS

; Data segment
; DW - Define Word (16 bit)
DATA SEGMENT PARA 'DATA'
 BALL_X DW 0Ah 		; x position of the ball
 BALL_Y DW 0Ah 		; y position of the ball
 BALL_SIZE DW 04h	; 4 on x 4 on y = 16 in total

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
	
	
		
	mov AH, 00h ; set video mode
	mov AL, 13h ; 13  320x200 256 color graphics (MCGA,VGA)
	int 10h		; execute interruption
		
	; background color
	mov AH,0Bh
	mov BH, 00h
	mov BL, 00h ; black color
	int 10h
		
	CALL DRAW_BALL
	
		
	RET
	MAIN ENDP
	
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