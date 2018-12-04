
TITLE DrawLine Program              (Pixel1.asm)

; This program draws a straight line, using INT 10h
; function calls.
; Last update: 12/14/01

INCLUDE Irvine16.inc
INCLUDE macros.inc
;------------ Video Mode Constants -------------------
Mode_06 = 6		; 640 X 200,  2 colors
Mode_0D = 0Dh		; 320 X 200, 16 colors
Mode_0E = 0Eh		; 640 X 200, 16 colors
Mode_0F = 0Fh		; 640 X 350,  2 colors
Mode_10 = 10h		; 640 X 350, 16 colors
Mode_11 = 11h		; 640 X 480,  2 colors
Mode_12 = 12h		; 640 X 480, 16 colors
Mode_13 = 13h		; 320 X 200, 256 colors
Mode_6A = 6Ah		; 800 X 600, 16 colors



.data

first PROTO
Write PROTO, buffer:WORD
__Read__ proto
AddPro PROTO, val1:WORD,val2:WORD
SubPro PROTO, val1:WORD,val2:WORD
MulPro PROTO, val1:WORD,val2:WORD
DivPro PROTO, val1:WORD,val2:WORD
KeyBoard PROTO
DrawSquareC PROTO,
	XaxisX:WORD,	YaxisY:WORD,	 XaxisLength:WORD, 	YaxisLength:WORD, color:BYTE

DrawSquare PROTO,
	XaxisX:WORD,	YaxisY:WORD, XaxisLength:WORD, YaxisLength:WORD

DrawVerticalLine PROTO

DrawHorizLine PROTO
 
saveMode BYTE ?
squarel BYTE 14

	opt BYTE ?
	opt1 BYTE ?
	comb1 BYTE ? 
	comb2 BYTE ?
	input1 BYTE ?
	input2 BYTE ?
	temp WORD ?
	count BYTE ?
	x BYTE 14


; In 2-color modes, white = 1
; In 16-color modes, blue = 1
;-----------------------------------------------
ESCkey = 1Bh
GreetingMsg BYTE "Press Esc to quit",0dh,0ah,0
StatusLine  BYTE "Left button:                              "
	        BYTE "Mouse position: ",0
blanks      BYTE "                ",0
Xcoordinate WORD 0	; current X-position
Ycoordinate WORD 0	; current Y-position
Xclick      WORD 0	; X-pos of last button click
Yclick      WORD 0	; Y-pos of last button click

MouseInput WORD ?
MouseInput1 WORD ?
Operator BYTE ?


.code
main PROC
	mov ax,@data
	mov ds,ax

; Save the current video mode
	mov  ah,0Fh
	int  10h
	mov  saveMode,al

; Switch to a graphics mode
	mov  ah,0h; set video mode
	mov  al,Mode_12
	int  10h


	
	call DrawD
	call first
	call DrawCal 	
	Call HideCursor1
	Call ShowMousePointer
	
	call clear	
	mov x,14
	mov dl,10
	mov dh,14
	call gotoxy
	
	call KeyBoard
	mov ax,250
	call delay
	call clear
L1:	
	
	;call gotoxy
	
	call ShowMousePosition
	call LeftButtonClick		; check for button click
	mov  ah,11h			; key pressed already?
	int  16h
	jz   L2         	 	; no, continue the loop
	mov  ah,10h			; remove key from buffer
	int  16h
				  	; yes. Is it the ESC key?
	je   quit       	 	; yes, quit the program
L2: jmp  L1          















quit:	

; Wait for a keystroke
	mov  ah,0
	int  16h
	
ext::

; Restore the starting video mode
	mov  ah,0	   	; set video mode
	mov  al,saveMode   	; saved video mode
	int  10h 
	

	exit
main ENDP

Write proc,	buffer1:WORD
.data
BufSize = 5000
outfile   BYTE "1file.txt",0
outHandle WORD ?
;buffer    BYTE buffer1
bytesRead WORD 8


.code
pushad
pushf

; Create the output file
	mov ax,716Ch   	; extended create or open
	mov bx,1      	; mode = write-only
	mov cx,0	; normal attribute
	mov dx,12h	; action: create/truncate
	mov si,OFFSET outfile
	int 21h       	; call MS-DOS
	jc  quit	; quit if error
	mov outHandle,ax	; save handle

; Write buffer to new file
	mov ah,40h		; write file or device
	mov bx,outHandle	; output file handle
	mov cx,bytesRead	; number of bytes
	mov dx,buffer1		; buffer pointer
	int 21h
	jc  quit	; quit if error

; Close the file
	mov  ah,3Eh   	 	; function: close file
	mov  bx,outHandle	; output file handle
	int  21h       		; call MS-DOS

quit:

popf
popad    



ret


Write endp


KeyBoard PROC



;#################
		;La:
		xor eax,eax
		xor ebx,ebx
		;mov ah,10h
		;int 16h
		
	;	mov count,al
		mov comb1,0
		mov comb2,0
		mov temp,0
	;@@@@@@@@@@  ====>>> 1st Input  @@@@@@@@@@@@@@@@
		;call ClrScr
		L1:
		xor eax,eax
		xor ebx,ebx
		
		mov dh,10
		mov dl,x
		call Gotoxy
		mov ah,10h		;input from keyboard
		int 16h
		inc x
		
		.if al == 2Bh || al == 5Fh || al == 2Ah || al == 3Fh || al == 25h
			
			.if al == 2Bh
			
			mov opt,2Bh
			
			pushad
			call clear
			popad
				mov ah,2 
				mov bh,0
				mov dh,7
				mov dl,64
				int 10h
				mov ax , '+' 						
				call writechar
			mov x,14
			
			jmp next
			
			
			.elseif al == 5Fh
			
			mov opt,5Fh
			call clear
				mov ah,2 
				mov bh,0
				mov dh,7
				mov dl,64
				int 10h
				mov ax , '-' 						
				call writechar				
			
			mov x,14
			
			jmp next
			
			
			.elseif al == 2Ah
			mov opt,2Ah
			call clear
				mov ah,2 
				mov bh,0
				mov dh,7
				mov dl,64
				int 10h
				mov ax , '*' 						
				call writechar			
			
			mov x,14

			jmp next
			
			.elseif al == 3Fh
			mov opt,3Fh
			call clear
				mov ah,2 
				mov bh,0
				mov dh,7
				mov dl,64
				int 10h
				mov ax , '/' 						
				call writechar			
			mov x,14
			
			jmp next
			
			.elseif al == 25
			mov opt,25
			call clear
			mov x,14
		
			jmp next
			.endif
		jmp next
		.else
			mov dl,al
			call writechar		;ah=scan ,al=ascii
			and al,11001111b
			or comb1,al
			shl comb1,1
			
		mov al,dl
		jmp L1
		.endif
		
		next:
		shr comb1,1
		

	;############## 2ND INPUT ========>>>> ##############
		;call ClrScr
		xor eax,eax
		xor ebx,ebx
		L2:
		mov dh,10
		mov dl,x
		call Gotoxy
		mov ah,10h		;input from keyboard
		int 16h
		inc x
		
		.if al == 3Dh || al == 2Bh || al == 5Fh || al == 2Ah || al == 3Fh || al == 25h
			.if al == 3Dh
			mov opt1,3Dh
				mov ah,2 
				mov bh,0
				mov dh,7
				mov dl,64
				int 10h
				mov ax , '=' 						
				call writechar			
			.endif
			jmp nextz
		.else
		mov dl,al
			call writechar		;ah=scan ,al=ascii
			and al,11001111b	;Converting From ASCII to Binary
			or comb2,al		;Moving Each Binary Value to Comb2
			shl comb2,1
			
		mov al,dl
		jmp L2
		.endif
	
	nextz:	
		shr comb2,1
		call crlf
		
	xor eax,eax
	xor ebx,ebx
		mov al,comb1
		;mwrite<"The 1ST Input is ",0>
		;call writebin
		;call crlf
		mov input1,al
		mov al,comb2
		;mwrite<"The 2ND Input is ",0>
		;call writebin
		mov input2,al
		;call crlf
		; Here the function on the basis of "OPT" is called 
		.if opt == 2Bh && opt1 == 3Dh
			; add procedure is called
			INVOKE AddPro,input1,input2		
		.elseif opt == 5Fh && opt1 == 3Dh
			; sub procedure is called
			INVOKE SubPro,input1,input2
			
		.elseif opt == 2Ah && opt1 == 3Dh
			;Mul procedure is called
			INVOKE MulPro,input1,input2
		
		.elseif opt == 3Fh && opt1 == 3Dh
			;Divion procedure is called
			INVOKE DivPro,input1,input2
		
		.endif
		;xor eax,eax
		;xor ebx,ebx
		;mov al,count
		;cmp al,1Bh
		;jne La
	
ret
KeyBoard ENDP
clear proc
.data
	xaxis BYTE 14
.code
	pushad
	mov cx,40
	mov xaxis, 14
l1:
		mov dh,10
		mov dl,xaxis
		call Gotoxy
		mov ax,' '
		call writechar
		
		inc xaxis
	loop l1		
	popad
	ret
clear endp

AddPro PROC, val1:WORD,val2:WORD
	pushad

	mov ax,val1
	mov bx,val2
	add ax,bx
	mov dl,14
	mov dh,10
	call gotoxy
	
	call writebin
		

	mov temp,ax
	invoke write,temp
	;mov ax,buffer

	

		;call crlf



	popad
ret
AddPro ENDP

SubPro PROC, val1:WORD,val2:WORD
	pusha
	mov ax,val1
	mov bx,val2
	sub ax,bx
	mov temp,ax
	
	mov dl,14
	mov dh,10
	call gotoxy
	
	call writebin
	;call crlf	
	popa
ret
SubPro ENDP

MulPro PROC, val1:WORD,val2:WORD
	pusha
	mov ax,val1
	mov bx,val2
	mul bx
	mov temp,ax
	mov dl,14
	mov dh,10
	call gotoxy
	
	call writebin
	;call crlf
	popa
ret
MulPro ENDP

DivPro PROC, val1:WORD,val2:WORD
	pusha
	mov ax,val1
	mov bx,val2
	mov dl,0
	div bx
	mov temp,ax
	mov dl,14
	mov dh,10
	call gotoxy
	
	call writebin
	
	;call crlf
	popa
ret
DivPro ENDP

;------------------------------------------------------
DrawHorizLine PROC
;
; Draws a horizontal line starting at position X,Y with
; a given length and color.
; Receives: CX = X-coordinate, DX = Y-coordinate,
;           AX = length, and BL = color
; Returns: nothing
;------------------------------------------------------
.data
currX WORD ?

.code
	pusha
	mov  currX,cx	; save X-coordinate
	mov  cx,ax	; loop counter

DHL1:
	push cx	; save loop counter
	mov  al,bl	; color
	mov  ah,0Ch	; draw pixel
	mov  bh,0	; video page
	mov  cx,currX	; retrieve X-coordinate
	int  10h
	inc  currX	; move 1 pixel to the right
	pop  cx	; restore loop counter
	Loop DHL1

	popa
	ret
DrawHorizLine ENDP

;------------------------------------------------------
DrawVerticalLine PROC
;
; Draws a vertical line starting at position X,Y with
; a given length and color.
; Receives: CX = X-coordinate, DX = Y-coordinate,
;           AX = length, BL = color
; Returns: nothing
;------------------------------------------------------
.data
currY WORD ?

.code
	pusha
	mov  currY,dx	; save Y-coordinate
	mov  currX,cx	; save X-coordinate
	mov  cx,ax	; loop counter

DVL1:
	push cx	; save loop counter
	mov  al,bl	; color
	mov  ah,0Ch	; function: draw pixel
	mov  bh,0	; set video page
	mov  cx,currX	; set X-coordinate
	mov  dx,currY	; set Y-coordinate
	int  10h	; draw the pixel
	inc  currY	; move down 1 pixel
	pop  cx	; restore loop counter
	Loop DVL1

	popa
	ret
DrawVerticalLine ENDP


;------------------------------------------------------
DrawSquare PROC,
	XaxisX:WORD,	YaxisY:WORD,	 XaxisLength:WORD, 	YaxisLength:WORD
;local sum:WORD
; Draws a Square from X to Y
; a given length and color.
; Receives: CX = X-coordinate, DX = Y-coordinate,
;           AX = length, BL = color
; Returns: nothing
;------------------------------------------------------

; Draw the X-axis
	mov  cx,XaxisX					; X-coord of start of line
	mov  dx,YaxisY					; Y-coord of start of line
	mov  ax,XaxisLength			 	; length of line
	mov  bl,white					; line color (see IRVINE16.inc)
	call DrawHorizLine				; draw the line now


; Draw the Y-axis
	 
	mov  cx,XaxisX			; X-coord of start of line
	mov  dx,YaxisY			; Y-coord of start of line
	mov  ax,YaxisLength		; length of line
	mov  bl,white			; line color
	call DrawVerticalLine		; draw the line now
	
; Draw the X-axis
	push ax
	mov  ax,YaxisY
	add  ax,YaxisLength
	mov  cx,XaxisX			; X-coord of start of line
	mov  dx,ax			; Y-coord of start of line
	mov  ax,XaxisLength	 	; length of line
	mov  bl,white			; line color (see IRVINE16.inc)
	call DrawHorizLine		; draw the line now
	pop ax

; Draw the Y-axis

	push ax
	mov  bx,XaxisX
	add  bx,XaxisLength
	mov  cx,bx			; X-coord of start of line
	mov  dx,YaxisY			; Y-coord of start of line
	mov  ax,YaxisLength		; length of line
	mov  bl,white			; line color
	call DrawVerticalLine		; draw the line now
	pop ax


	ret
DrawSquare ENDP

DrawCircle proc
	push eax
	push ebx
	
	mov ah,4Dh
	mov DI,50
	mov BP,50
	mov BX,10
	
	
	pop ebx
	pop ebx
	

DrawCircle endp

GetMousePosition PROC
;
; Return the current mouse position and button status.
; Receives: nothing
; Returns:  BX = button status (0 = left button down,
;           (1 = right button down, 2 = center button down)
;           CX = X-coordinate
;           DX = Y-coordinate
;---------------------------------------------------------
	push ax
	mov  ax,3
	int  33h
	pop  ax
	ret
GetMousePosition ENDP

;---------------------------------------------------------
HideCursor proc
;
; Hide the text cursor by setting its top line
; value to an illegal value.
;---------------------------------------------------------
	mov  ah,3	; get cursor size
	int  10h
	or   ch,30h	; set upper row to illegal value
	mov  ah,1	; set cursor size
	int  10h
	ret
HideCursor ENDP

ShowCursor PROC
	mov  ah,3	; get cursor size
	int  10h
	mov  ah,1	; set cursor size
	mov  cx,0607h	; default size
	int  10h
	ret
ShowCursor ENDP

;---------------------------------------------------------
HideMousePointer PROC
;---------------------------------------------------------
	push ax
	mov  ax,2	; hide mouse cursor
	int  33h
	pop  ax
	ret
HideMousePointer ENDP

;---------------------------------------------------------
ShowMousePointer PROC
;---------------------------------------------------------
	push ax
	mov  ax,1	; make mouse cursor visible
	int  33h
	pop  ax
	ret
ShowMousePointer ENDP

;---------------------------------------------------------
LeftButtonClick PROC
;
; Check for the most recent click of the left mouse
; button, and display its location.
; Receives: BX = button number (0=left, 1=right, 2=middle)
; Returns:  BX = button press counter
;           CX = X-coordinate
;           DX = Y-coordinate
;---------------------------------------------------------

.data
	click WORD ?
	cString BYTE 219
	
	one BYTE 49
	
	zero BYTE 48
.code
	
	pusha
	mov  ah,0	; get mouse status
	mov  al,5	; (button press information)
	mov  bx,0	; specify the left button
	int  33h
	
	mov click,bx
LBC1:

; Save the mouse coordinates.
	mov  Xclick,cx
	mov  Yclick,dx
	

;"1"	
.IF (Xclick > 450 && Yclick > 200 && Xclick < 530 && Yclick < 250 && click == 1)
;	pushad
		
		OR Mouseinput,1
		shl MouseInput,1
		mov ah,2
		mov bh,0
		mov dh,10
		mov dl,squarel
		int 10h
		mov ax , '1'
		
		call writechar
		inc squarel
		mov ax,1
;	popad	
.ENDIF
;"0"
.IF (Xclick > 450 && Yclick > 260 && Xclick < 530 && Yclick < 310 && click == 1)
;	pushad		
		OR MouseInput,0
		shl MouseInput,1
		mov ah,2 
		mov bh,0
		mov dh,10
		mov dl,squarel
		int 10h
		mov ax , '0'
		
		call writechar
		inc squarel
;	popad
.ENDIF
;"+"
.IF (Xclick > 220 && Yclick > 200 && Xclick < 300 && Yclick < 250 && click == 1)
	pushad		
		shr Mouseinput,1
		mov ax,Mouseinput
		mov Mouseinput1,ax
	
		call clear
		
		mov dh,10
		mov dl,14
		call gotoxy
		mov squarel,14
		mov operator,'+'
		mov ah,2 
		mov bh,0
		mov dh,7
		mov dl,64
		int 10h
		mov ax , '+' 						
		call writechar
		
	popad
.ENDIF
;"*"
.IF (Xclick > 100 && Yclick > 200 && Xclick < 180 && Yclick < 250 && click == 1)
	pushad		
		shr Mouseinput,1
		mov ax,Mouseinput
		mov Mouseinput1,ax
		
		call clear
		mov dh,10
		mov dl,14
		call gotoxy
	
		mov operator,'*'
		mov ah,2 
		mov bh,0
		mov dh,7
		mov dl,64
		int 10h
		mov ax , '*' 					
		call writechar
		
	popad
.ENDIF
;"/"
.IF (Xclick > 100 && Yclick > 260 && Xclick < 180 && Yclick < 310 && click == 1)
	pushad		
		shr Mouseinput,1
		mov ax,Mouseinput
		mov Mouseinput1,ax
		mov operator,'/'
		call clear
		
		mov dh,10
		mov dl,14
		call gotoxy
		
		mov ah,2 
		mov bh,0
		mov dh,7
		mov dl,64
		int 10h
		mov ax , '/'
		call writechar
			
	popad
.ENDIF
;"-"
.IF (Xclick > 220 && Yclick > 260 && Xclick < 300 && Yclick < 310 && click == 1)
	pushad		
	shr Mouseinput,1
	mov ax,Mouseinput
	mov Mouseinput1,ax	
	mov operator,'-'
	;call clear
	
	mov dh,10
	mov dl,14
	call gotoxy
	
	mov ah,2 
	mov bh,0
	mov dh,7
	mov dl,64
	int 10h
	mov ax , '-'   						
	call writechar
		
	popad
.ENDIF
;"C"
.IF (Xclick > 360 && Yclick > 200 && Xclick < 440 && Yclick < 250 && click == 1)
	pushad		
		DEC squarel
		shr Mouseinput,1
		mov ah,2 
		mov bh,0
		mov dh,10
		mov dl,squarel
		int 10h
		mov ax , ' ' 						
		call writechar
		
	popad
.ENDIF
;"AC"
.IF (Xclick > 360 && Yclick > 260 && Xclick < 440 && Yclick < 310 && click == 1)
	pushad		
		DEC squarel
		shr Mouseinput,1
		mov ah,2 
		mov bh,0
		mov dh,10
		mov dl,squarel
		int 10h
		mov ax , ' '  						
		call writechar
			
	popad
.ENDIF

.IF (Xclick > 100 && Yclick > 320 && Xclick < 300 && Yclick < 360 && click == 1)
	.IF (Operator == '+')
		shr Mouseinput1,1
		mov dl,10
		mov dh,14
		call gotoxy
		mov squarel,14
		INVOKE Addpro,Mouseinput,Mouseinput1
	.ENDIF
	.IF (Operator == '-')
		shr Mouseinput1,1
		mov dl,10
		mov dh,14
		call gotoxy
		mov squarel,14
		INVOKE Subpro,Mouseinput,Mouseinput1
	.ENDIF
	.IF (Operator == '*')
		shr Mouseinput1,1
		mov dl,10
		mov dh,14
		call gotoxy
		mov squarel,14
		INVOKE Mulpro,Mouseinput,Mouseinput1
	.ENDIF
	.IF (Operator == '/')
		shr Mouseinput1,1
		mov dl,10
		mov dh,14
		call gotoxy
		mov squarel,14
		INVOKE Divpro,Mouseinput,Mouseinput1
	.ENDIF
.ENDIF
.IF (Xclick > 480 && Yclick > 70 && Xclick < 500 && Yclick < 90 && click == 1)
	INVOKE __read__
.ENDIF

.IF (Xclick > 520 && Yclick > 70 && Xclick < 540 && Yclick < 90 && click == 1)
	jmp ext
.ENDIF

	popa
	ret
LeftButtonClick ENDP

;---------------------------------------------------------
SetMousePosition PROC
;
; Set the mouse's position on the screen.
; Receives: CX = X-coordinate
;           DX = Y-coordinate
; Returns:  nothing
;---------------------------------------------------------
	mov  ax,4
	int  33h
	ret
SetMousePosition ENDP

;---------------------------------------------------------
ShowMousePosition PROC
;
; Get and show the mouse corrdinates at the
; bottom of the screen.
; Receives: nothing
; Returns:  nothing
;---------------------------------------------------------
	pusha
	call GetMousePosition

; Exit proc if the coordinates have not changed.
	cmp  cx,Xcoordinate
	jne  SMP1
	cmp  dx,Ycoordinate
	je   SMP_exit

SMP1:
	mov  Xcoordinate,cx
	mov  Ycoordinate,dx

; Position the cursor, clear the old numbers.
	mov  dh,29               	; screen row
	mov  dl,60     		   	; screen column
	call Gotoxy
	push dx
	mov  dx,OFFSET blanks
	call WriteString
	pop  dx

; Show the mouse coordinates.
	call Gotoxy	; (24,60)
	mov  ax,Xcoordinate
	call WriteDec
	mov  dl,65        	; screen column
	call Gotoxy
	mov  ax,Ycoordinate
	call WriteDec

SMP_exit:
	popa
	ret
ShowMousePosition ENDP

DrawCal proc
;-----------------------------------------------
INVOKE DrawSquareC, 90,70,450,20,1
INVOKE DrawSquareC, 520,70,20,20,4
		mov ah,2 
		mov bh,0
		mov dh,5
		mov dl,66
		int 10h
		mov ax , 'X'
		call writechar
INVOKE DrawSquareC, 500,70,20,20,1
INVOKE DrawSquare, 500,70,20,20
INVOKE DrawSquareC, 480,70,20,20,1
INVOKE DrawSquare, 480,70,20,20

;------------Calculator's Fram-------------------
INVOKE DrawSquareC, 90,90,450,350,8
INVOKE DrawSquare, 90,90,450,350
INVOKE DrawSquareC, 90,90,450,100,8
INVOKE DrawSquare, 90,90,450,100
INVOKE DrawSquareC, 100,100,430,80,0
INVOKE DrawSquare, 100,100,430,80

;------------Operation Keys's-------------------
INVOKE DrawSquareC, 100,200,80,50,0
INVOKE DrawSquareC, 220,200,80,50,0
INVOKE DrawSquareC, 100,260,80,50,0
INVOKE DrawSquareC, 220,260,80,50,0
INVOKE DrawSquareC, 100,320,200,50,0
;------------Operator Key's--------------------
INVOKE DrawSquareC, 450,200,80,50,0
INVOKE DrawSquareC, 450,260,80,50,0
;------------C & CE key--------------------
INVOKE DrawSquareC, 360,200,80,50,0
INVOKE DrawSquareC, 360,260,80,50,0
;---------------------------------
	push ax
;---------0---------------------	
	mov dl,61
	mov dh,18
	call gotoxy
	mov ah,2
	mov al,'0'
	call writechar
;--------1-----------------	
	mov dl,61
	mov dh,14
	call gotoxy
	mov al,'1'
	call writechar
	
	mov dl,50
	mov dh,14
	call gotoxy
	mov al,'C'
	call writechar
	
	mov dl,50
	mov dh,18
	call gotoxy
	mov al,'A'
	call writechar
	
	mov dl,17
	mov dh,14
	call gotoxy
	mov al,'*'
	call writechar
	
	mov dl,17
	mov dh,18
	call gotoxy
	mov al,'/'
	call writechar
	

	mov dl,32
	mov dh,14
	call gotoxy
	mov al,'+'
	call writechar
	
	mov dl,32
	mov dh,18
	call gotoxy
	mov al,'='
	call writechar
	

	mov dl,22
	mov dh,21
	call gotoxy
	mov al,'-'
	call writechar
		
	mov dl,23
	mov dh,21
	call gotoxy
	mov al,'-'
	call writechar
	
	mov dl,24
	mov dh,21
	call gotoxy
	mov al,'-'
	call writechar
		
	mov dl,25
	mov dh,21
	call gotoxy
	mov al,'-'
	call writechar
	
	mov dl,26
	mov dh,22
	call gotoxy
	mov al,'-'
	call writechar	

		mov dl,26
		mov dh,21
		call gotoxy
		mov al,'-'
	call writechar	
		mov dl,27
		mov dh,21
		call gotoxy
		mov al,'-'
	call writechar	
	
	mov dl,22
	mov dh,22
	call gotoxy
	mov al,'-'
	call writechar
		
	mov dl,23
	mov dh,22
	call gotoxy
	mov al,'-'
	call writechar
	mov dl,24
	mov dh,22
	call gotoxy
	mov al,'-'
	call writechar
	mov dl,25
	mov dh,22
	call gotoxy
	mov al,'-'
	call writechar
	mov dl,26
	mov dh,22
	call gotoxy
	mov al,'-'
	call writechar
	mov dl,27
	mov dh,22
	call gotoxy
	mov al,'-'
	call writechar
	
;-----------------------------------	
	pop ax
;-----------Restore Cursor--------------	
	mov dl,0
	mov dh,0
call gotoxy

ret

DrawCal endp

DrawD proc
.data

.code
INVOKE DrawSquareC,0,460,640,20,1
INVOKE DrawSquareC,0,460,60,20,10


ret
DrawD endp


DrawSquareC proc,
	XaxisX:WORD,	YaxisY:WORD,	 XaxisLength:WORD, 	YaxisLength:WORD, color:BYTE


INVOKE DrawSquare,
	XaxisX,	YaxisY,	 XaxisLength, 	YaxisLength

	pusha
	add XaxisX,1
	add YaxisY,1
	mov cx,YaxisLength
@loop:

	push cx
	mov  cx,XaxisX			; X-coord of start of line
	mov  dx,YaxisY			; Y-coord of start of line
	INC YaxisY
	mov  ax,XaxisLength			 	; length of line
	mov  bl,color					; line color (see IRVINE16.inc)
	call DrawHorizLine				; draw the line now


	pop cx
loop @loop

	popa

	ret
DrawSquareC endp

;===============================
HideCursor1 PROC
		mov ah,3
		int 10h
		or ch,30h
		mov ah,1
		int 10h
	ret
HideCursor1 ENDP
;===============================
ShowCursor1 PROC
		mov ah,3
		int 10 
		mov ah,1
		mov cx,0607h
		int 10h
	ret
ShowCursor1 ENDP
;===============================

AdvanceCursor PROC
;
; Advances the cursor n columns to the right.
; Receives: CX = number of columns
; Returns: nothing
;--------------------------------------------------
	pusha
L1:
	push cx	; save loop counter
	mov  ah,3      	; get cursor position
	mov  bh,0	; into DH, DL
	int  10h	; changes CX register!
	inc  dl        	; increment column
	mov  ah,2      	; set cursor position
	int  10h
	pop  cx	; restore loop counter
	loop L1	; next column

	popa
	ret
AdvanceCursor ENDP



__Read__ proc
.data
BufSize = 5000
infile    BYTE "file1.txt",0
inHandle  WORD ?
buffer    BYTE BufSize DUP(?)
bytesRead1 WORD ?

.code
    mov  ax,@data
    mov  ds,ax

; Open the input file
	mov ax,716Ch   	; extended create or open
	mov bx,0      	; mode = read-only
	mov cx,0	; normal attribute
	mov dx,1	; action: open
	mov si,OFFSET infile
	int 21h       	; call MS-DOS
	jc  quit	; quit if error
	mov inHandle,ax

; Read the input file
	mov ah,3Fh	; read file or device
	mov bx,inHandle	; file handle
	mov cx,BufSize	; max bytes to read
	mov dx,OFFSET buffer	; buffer pointer
	int 21h
	jc  quit	; quit if error
	mov bytesRead1,ax

; Display the buffer
	mov ah,40h	; write file or device
	mov bx,1	; console output handle
	mov cx,bytesRead1	; number of bytes
	mov dx,OFFSET buffer	; buffer pointer
	mov dl,14
	mov dh,10
	call gotoxy
	int 21h
	jc  quit	; quit if error

; Close the file
	mov  ah,3Eh    	; function: close file
	mov  bx,inHandle	; input file handle
	int  21h       	; call MS-DOS
	jc  quit	; quit if error

quit:
	call Crlf
    



ret
__Read__ endp




;-----------------------------------------------


first proc
.data
	instruct BYTE "Binary Calculator Made By ",0
	Instruct1 BYTE "Raza AND Mustafa",0
	button BYTE "Start",0
	temp1 WORD ?
.code

		mov cx,lengthof instruct                     ;mov dx, offset tac
	        dec cx
		mov si, 0		   ;call writestring
		mov dl, 1
lable_14:
		mov temp1 , cx
		mov ah, 9                              ;Function
		mov al, instruct[si]                        ;Assign value
		mov bh, 0                              ;Vedio page
		mov bl, 0ah                            ;For Color
		mov cx, 1                              ;Loop
		int 10h                                ;interrupts
		mov ah,2                               ;gotoxy
		mov dh,0	                           ;row
		mov bh,0                               ;video page
		int 10h
		inc dl 		                           ;inc col
		inc si                              ;show var
		mov cx , temp1
		mov ax, 100
		;call Delay
loop lable_14

		mov cx,lengthof instruct1                     ;mov dx, offset tac
	        
		mov si, -1		   ;call writestring
		mov dl, 10
lable_01:
		mov temp1 , cx
		mov ah, 9                              ;Function
		mov al, instruct1[si]                        ;Assign value
		mov bh, 0                              ;Vedio page
		mov bl, 0ah                            ;For Color
		mov cx, 1                              ;Loop
		int 10h                                ;interrupts
		mov ah,2                               ;gotoxy
		mov dh,2	                           ;row
		mov bh,0                               ;video page
		int 10h
		inc dl 		                           ;inc col
		inc si                              ;show var
		mov cx , temp1
		mov ax, 100
		;call Delay
loop lable_01

		mov cx,lengthof button                    ;mov dx, offset tac
	        
		mov si, -1		   ;call writestring
		mov dl, 1
lable_02:
		mov temp1 , cx
		mov ah, 9                              ;Function
		mov al, button[si]                        ;Assign value
		mov bh, 0                              ;Vedio page
		mov bl, 0ah                            ;For Color
		mov cx, 1                              ;Loop
		int 10h                                ;interrupts
		mov ah,2                               ;gotoxy
		mov dh,29	                           ;row
		mov bh,0                               ;video page
		int 10h
		inc dl 		                           ;inc col
		inc si                              ;show var
		mov cx , temp1
		mov ax, 100
		;call Delay
loop lable_02

ret
first endp

END main


