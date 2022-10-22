; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ex4.asm
; 08/06/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: this is a snake game! :) ----> 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.model small
.stack 100
.data
;27 words before __ in score array
out_msg db 'end game :( your score is : ','$' 

y dw 0
x dw 0
player_location dw 0
point_location dw 0
flagGameover dw 0

score dw 0
repeat3X dw 0
FlagMoveIF1 db 0  
;input_arr dw 0032h, 9h, 12h, 18h, 33h
;inputlen EQU 5h
.code

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc1 Description: change inturpt 1c
;inputs:
	;none
;output:
	;none
ISR_New_int_1c proc far uses ax


	;mov FlagMoveIF1,0 ;turn off flag and move player
	
	
	inc repeat3X ;add 1 to repeat3X
	cmp repeat3X,3h ; every 3 clock cycle move the player
	;if repeat3X= 1/2 dont move
	jnz prev_isr ;dont move 
	
	;else Move player And reset repeat3X
	mov FlagMoveIF1,1 ;turn on flag and move player
	mov repeat3X,0 ;init repeat3X to 0
	
	prev_isr:
	int 80h ;use the old interupt 1c
	iret
ISR_New_int_1c endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc2 Description: This function print point on new location
;inputs:
	;none
;output:
	;new point on screen
newPoint proc uses ax cx dx bx
	
	PointOnSnake:
	
	mov al,00h ;second
	out 70h,al ;tell port 70(clock)I need information
	in al,71h ;the clock return his answer through port 71 and into al
	mov ah,al ;seconds inside high (ah)
	
	mov al,02h ;minutes
	out 70h,al ;tell port 70(clock)I need information
	in  al,71h ;the clock return his answer through port 71 and into al
	;now ax contain the offset, we'll take modolou 4000 (screen size)
	
	mov bx,4000d ;we want screen size less then 4000
	mov dx,0 ;need to init dx=0 before div
	div word ptr bx ;ax=ax/bx dx=ax modolo bx (resedue)
	
	;now dx is the desired offset less then 4000
	mov bx,dx ;cannot put dx as memory offset
	test bx,01h
	jz evenNum ;if the number is odd the offset isn't correct
	sub bx,1h ;sub 1 to correct offset
	
	cmp bh,04h ;if the random point is red (on snake)
	jz PointOnSnake ;give me a new point
	
	evenNum:
	mov ch,0Eh ;yellow
	mov cl,58h ;X sign
	mov es:[bx],cx ;put a yellow X on random location.
	
	mov point_location,bx ;save the current point location
	ret ;pop ip+1 (next instruction after call)
newPoint endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc3 Description: 
;inputs:
	;al=current prresed key
;output:
	;none
printMove proc uses bx es
	
	;if Q
	cmp al,90h ;compare it to Q (scan code)
	jz QuitGame ;quit game
	
	;if A
	cmp al,9Eh ;compare it to A (scan code)
	jz TurnLeft ;turn left  <---
	
	;if D
	cmp al,0a0h ;compare it to D (scan code)
	jz TurnRifht ;Turn Rifht --->
	
	;if S
	cmp al,9fh ;compare it to S (scan code) 
	jz TurnDown  ;Turn Down                
	
	;if W
	cmp al,91h ;compare it to W (scan code)
	jz TurnUP ;turn up
	
	jmp AGAIN ; dont go inside turn left
	
	TurnLeft: 
	cmp x,0
	je AGAIN ;look for new key
	
	sub player_location,2d ;go left
	mov ah,04h ; red
	mov al,4Fh ; o in ascii
	mov bx,player_location
	mov es:[bx],ax ;print
	mov al, 32h ;' ' space in ascii code
	mov ah, 00h ;black color in ascii code
	mov bx,player_location
	mov es:[bx+2],ax ;print
	sub x,2
	jmp AGAIN
	
	TurnRifht: 
	cmp x,158
	je AGAIN ;look for new key
		
	cmp player_location,160d
	je AGAIN
	add player_location,2d ;go right
	mov ah,04h ; red
	mov al,4Fh ; o in ascii
	mov bx,player_location
	mov es:[bx],ax ;print
	mov al, 32h ;' ' space in ascii code
	mov ah, 00h ;black color in ascii code
	mov bx,player_location
	mov es:[bx-2],ax ;print
	add x,2
	jmp AGAIN
	
	TurnDown: 
	cmp y,24 ;3840
	je AGAIN ;look for new key
		
	add player_location,160d ;go down
	mov ah,04h ; red
	mov al,4Fh ; o in ascii
	mov bx,player_location
	mov es:[bx],ax ;print
	mov al, 32h ;' ' space in ascii code
	mov ah, 00h ;black color in ascii code
	mov bx,player_location
	mov es:[bx-160d],ax ;print
	add y,1
	jmp AGAIN
	
	TurnUP: ;go up
	cmp y,0
	je AGAIN ;look for new key
	
	sub player_location,160d ;go up
	mov ah,04h ; red
	mov al,4Fh ; o in ascii
	mov bx,player_location
	mov es:[bx],ax ;print
	mov al, 32h ;' ' space in ascii code
	mov ah, 00h ;black color in ascii code
	mov bx,player_location
	mov es:[bx+160],ax ;print
	sub y,1
	jmp AGAIN
	
	QuitGame:
	inc flagGameover
	
	AGAIN:

	ret ;pop ip+1 (next instruction after call)
printMove endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



START:
	;setting ds to data segment
	mov ax,@data
	mov ds,ax
	
	;turn off keybord inturpt as mentioned in task4
	in al,21h
	or al,02h
	out 21h,al
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	;update IVT table
	
	mov ax,0h ; IVT is location is '0000' address of RAM
	mov es,ax ; put 0 in es
	cli 	; block interrupts
	;moving Int1c into IVT[080h]
	mov ax,es:[1ch*4] ;copying old ISR1c IP to free vector
	mov es:[80h*4],ax
	mov ax,es:[1ch*4+2] ;copying old ISR1c CS to free vector
	mov es:[80h*4+2],ax
	;moving ISR_New_int_1c (proc) into IVT[1c]
	mov ax,offset ISR_New_int_1c ;copying IP of ISR_New to IVT[1c]
	mov es:[1ch*4],ax ;1c contain the address lable ISR_New_int_1c
	mov ax,cs 		  ;copying CS of our ISR_New into IVT[9]
	mov es:[1ch*4+2],ax
	sti 			  ;enable interrupts
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	mov ax, 0b800h   ;screen memory
	mov es, ax       ;set es to print at screen memory
	
	mov dl,32h ;' ' space in ascii code
	mov dh, 00h ;black color in ascii code

	mov bx, 25d*158d ;the screen size (25rows*80w words *2(two byts in word))
	;loop in order to turn the screen black
	L1: 
		sub bx, 2d ;jump to next slot
		mov es:[bx],dx ;make one slot to black
		jnz l1 ;finish when bx=0 (end of screen)

	mov player_location,2000 ;init game with red O
	mov y,12d
	mov x,80d
	mov ah,04h ;RED
	mov al,4Fh ;O sign
	mov bx,player_location
	mov es:[bx],ax ;put the O red in screen
	
	
	mov score,0
	dec score ;start the counter from -1
	
	;the game begin!!!!!!!!!!!!!!!!!!
	
	addPoint:
	call newPoint ;put the first point on the screen 
	add score,1 ;the user collect a point (start from 0 in the beginning)
	
	;printNewLocation:
	;call printMove ;print the next move
	;mov FlagMoveIF1,0 ;turn off flag 
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;wait for a key or the clock has changed	
	pollKeyBoard: ;keybord changed or evety third time 
	;IN AL, 64h ;user release a key(change accured).
	;TEST AL, 01h ;like and(change only flags)
	mov cx,player_location
	cmp cx,point_location ;new point if the player and the snake on the same spot
	jz addPoint ;add a different point
	
	in al,60h ;if there is a change put the key in al 
	
	cmp al,90h ;compare it to Q (scan code)
	jz EndGame ;quit game
	
	cmp FlagMoveIF1,0
	je pollKeyBoard ;if flag=0 see if al changed
	
	;else FlaGIsUp flag=1
	call printMove ;print the next move
	mov FlagMoveIF1,0 ;init flag
	
	jmp pollKeyBoard ;no change oucured
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EndGame:
	;1c (moveIF1=0),1c(moveIF1=0), 1c(moveIF1=1) ,1c(moveIF1=0)
	

	











;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	;return IVT table to its default
	
	mov ax,0h ; IVT is location is '0000' address of RAM
	mov es,ax ; put 0 in es
	cli 	; block interrupts
	;moving Int1c into IVT[080h]
	mov ax,es:[80h*4] ;copying free vector to old ISR1c IP  
	mov es:[1ch*4],ax
	mov ax,es:[80h*4+2] ;copying free vector to old ISR1c CS  
	mov es:[1ch*4+2],ax
	
	sti 			  ;enable interrupts
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	
	
	
	
	mov ax, 0b800h   ;screen memory
	mov es, ax       ;set es to print at screen memory
	
	;print score
	;print massage
	mov dx, offset out_msg
	mov ah,9h
	int 21h ;print request
	
	
	mov ax,score ;put the score in ax
	mov bx,10d ;put 10 in bx
	mov dx,0 ;witout init dx we got problem in CV mode when trying to div AX/BX
	div word ptr bx ;ax=ax/bx dx=ax modolo bx (resedue)
	
	add ax,'0' ;add the ascii code to the digit
	add dx,'0' ;add the ascii code to the digit
	
	mov bx,dx ;bx=dx=last digit
	;ax=first digit

	;print ax first digit score
	mov dl,al
	mov ah,2h
	int 21h
	
	;print bx last digit score
	mov dl,bl
	mov ah,2h
	int 21h
		
	;return keybord to default
	mov al, 0h
	out 21h, al
	
	;return to OS
	mov ax,4c00h
	int 21h

END START
