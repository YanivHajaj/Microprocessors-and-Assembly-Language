; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; print.asm
; 22/06/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: print a sentence, !!! contol speed with W(inc speed),S(dec speed),Q(pause) !!!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.model small
.stack 100
.data
;input_arr db 1h, 2h, 3h, 4h, 5h
SpeedRateLoop db 0
ConstSpeedRate db 6 ; when we put this value each carecter take about a sec to appear
out_msg db "''It","'","s hardware that makes a machine fast. It","'","s software that makes a fast machine slow.''","-"," Craig Bruce", '$'
repeat3X dw 0
countUntilSix dw 0
background db 7 ;light grey
colorNumber dw 0
XCordinate db 0
ClockFlag db 1
;ClockFlag db ?

;FlagMoveIF1 db 0  
;input_arr dw 0032h, 9h, 12h, 18h, 33h
;inputlen EQU 5h
.code 
extern TSR_END:near ;declare near jump will occur
extern TSR_START:near ;declare near jump will occur
public BackToPrint ;get acces to TSR lable


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;delay Description: start with clock or not?
;inputs:
	;none
;output:
	;none
	WithORWithoutClock proc uses si dx es
	mov si,0
	;psp 81h contain the command line string
	mov al,byte ptr es:[81h+si]
	inc si
	cmp al,' ' 
	jnz withCLock ;if the charceter doesnt match go to no clock
	
	mov al,byte ptr es:[81h+si]
	inc si
	cmp al,'/' 
	jnz withCLock ;if the charceter doesnt match go to no clock
	
	mov al,byte ptr es:[81h+si]
	inc si
	cmp al,'N' 
	jnz withCLock ;if the charceter doesnt match go to no clock
	
	mov al,byte ptr es:[81h+si]
	inc si
	cmp al,'O' 
	jnz withCLock ;if the charceter doesnt match go to no clock
	
	mov al,byte ptr es:[81h+si]
	inc si
	cmp al,'C' 
	jnz withCLock ;if the charceter doesnt match go to no clock
	
	mov al,byte ptr es:[81h+si]
	inc si
	cmp al,'L' 
	jnz withCLock ;if the charceter doesnt match go to no clock
	
	mov al,byte ptr es:[81h+si]
	inc si
	cmp al,'K' 
	jnz withCLock ;if the charceter doesnt match go to no clock
	
	mov ClockFlag,0 
	jmp WitoutClock ;skip to WitoutClock
	
	withCLock:
	mov ClockFlag,1 ;if all charceter match include clock
	
	WitoutClock:
	ret ;pop ip+1 (next instruction after call)
WithORWithoutClock endp
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;delay Description: delay when called (from lecture 7)
;inputs:
	;ConstSpeedRate contain desired delay
;output:
	;none
 
delay proc 
;mov dh, 4d ;
;mul dh 
;ConstSpeedRate(120)=SpeedRateLoop(60,59,58,57...,33,...6,5,4,3)

mov AL,ConstSpeedRate
mov SpeedRateLoop,AL

OutLoop :
	
	push cx
	xor cx,cx ;cx <- 0
	chk_kbd:  ;do nothing
	
	IN AL, 64h ;user release a key(change accured).
	TEST AL, 01h ;like and(change only flags)
	JZ NoKeyBoardChanged ;no change ZF=0
	
	;------------------------------------------ polling (key changed?)
	in al,60h ;if there is a change put the key in al 
		
	;if S
	cmp al,9fh ;compare it to S (scan code) 
	jz TurnDown  ;Turn Down 
	
	;if W
	cmp al,91h ;compare it to W (scan code)
	jz TurnUP ;turn up
		
	;if Q
	cmp al,90h ;compare it to Q (scan code)
	jz PauseRun ;quit game
	
	jmp chk_kbd ;if not (W,S,P) continue
	
	;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$up
	TurnDown:
	mov al,ConstSpeedRate
	add al,ConstSpeedRate
	mov ConstSpeedRate,al
	
	jmp chk_kbd ;finish turn down
	;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$up
	
	;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$down
	TurnUP: 
	cmp ConstSpeedRate,1 ;dont put 0 in ConstSpeedRate
	je chk_kbd ;finish turn up
	mov al,ConstSpeedRate
	shr al,1
	mov ConstSpeedRate,al
	
	jmp chk_kbd ;finish turn up
	;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$down
	
	;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$pause
	PauseRun:
		Pause_And_chk_kbd: 
		IN AL, 64h ;user release a key(change accured).
		TEST AL, 01h ;like and(change only flags)
		JZ Pause_And_chk_kbd ;no change ZF=0

		in al,60h ;if there is a change put the key in al 
		
		;if Q
		cmp al,90h ;compare it to Q (scan code)
		jz Pause_And_chk_kbd ;quit game
	
	jmp chk_kbd ;finish pause
	;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$pause
	
;------------------------------------------ polling (key changed?)
	
	NoKeyBoardChanged:
	loop chk_kbd; takes about 0.1sec @5MHZ cx-1=ffff
	pop cx ;
	dec SpeedRateLoop ;number of times  (ConstSpeedRate*0.1sec)
	jnz OutLoop
	ret
delay ENDP
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


START:
	;setting ds to data segment
	mov ax,@data
	mov ds,ax
	
	call WithORWithoutClock ;1 with 0 witout
	;mov ClockFlag,1
	
	mov ax, 0b800h   ;screen memory
	mov es, ax       ;set es to print at screen memory
	
	mov dl,32h ;' ' space in ascii code
	mov dh, 00h ;black color in ascii code

	mov bx, 25d*158d ;the screen size (25rows*80w words *2(two byts in word))
	;loop in order to turn the screen black
	L2: 
		sub bx, 2d ;jump to next slot
		mov es:[bx],dx ;make one slot to black
	jnz l2 ;finish when bx=0 (end of screen)

	cmp ClockFlag,1
	jz TSR_START
	BackToPrint:
	;setting ds to data segment
	mov ax,@data
	mov ds,ax
	
	;turn off keybord inturpt as mentioned in task4
	in al,21h
	or al,02h
	out 21h,al
	
	;enter graphic mode
	;mov ah,00h
	;mov al,13h
	;int 10h
	
	
	;set cursor to middle of screen
	mov ah,02h
	mov bh,0 	 ;page number (0 for graphics modes)
	mov dh,12d   ;row
	mov dl,0h    ;column
	int 10h
	
	
	
	
	
	;dec XCordinate ;start from 0
	;dec XCordinate
	
	mov si, offset out_msg ;si is out_msg location
	mov cx, offset out_msg ;end of the row location
	add cx,80d ;end of the row location
 
	
	L1:
	
	
	call delay
	mov dl, ds:[si] ;put 1 charecter in dl
	cmp dl,'$' ;finish if $ (last carecter in sentence)
	je ENDPRINT

	mov ah, 02h ;print it with int 21
	int 21h	;print it with int 21
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ change color
	push cx
	;change color every 3 time
	add repeat3X,1
	cmp repeat3X,3
	jne DontChangeColor ; if not 3 continue
	;else change color
	mov repeat3X,0
	add background,10h ;move to next color
	add colorNumber,1 ;add 1 to color number
	cmp colorNumber,7
	jne DontChangeColor ;save color if 0,1,2,3,4,5
	mov colorNumber,0 ;if 7, start from the begining of color list
	sub background,70h ;start from the first color
	
	DontChangeColor:; not 3, continue
	
	
	;set cursor to last charecter of screen
	mov ah,02h
	mov bh,0 	 ;page number (0 for graphics modes)
	mov dh,12d   ;row
	mov dl,XCordinate  ;column
	int 10h
	
	
	mov ah,08h 
	mov bh,0 ;give me current charecter
	int 10h ;now al contain charecter ascii
	
	;al already contain ascii charceter
	mov ah,09h
	mov bh,0
	mov bl,background ;lsb=7=light grey , msb= background
	mov cx,1
	int 10h
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	change color
	
	inc XCordinate ;add 1 to XCordinate
	;set cursor to current charecter of screen
	mov ah,02h
	mov bh,0 	 ;page number (0 for graphics modes)
	mov dh,12d   ;row
	mov dl,XCordinate  ;column
	int 10h
	pop cx

	
	inc si ;proceed to next charecter
	
	
	cmp si,cx ;go one row down if equal
	jne NoRowReset ;if offset at the end of the screen
	
	mov XCordinate,0
	;set cursor to begining of the row
	mov ah,02h
	mov bh,0 	 ;page number (0 for graphics modes)
	mov dh,12d   ;row
	mov dl,0h    ;column
	int 10h
	NoRowReset:
	
	

	
	
	jmp L1
	

ENDPRINT:
	
	;return keybord to default
	mov al, 0h
	out 21h, al
	
	cmp ClockFlag,0
	jz TSR_END ;finish in here
	
	
	;finish here
	;return to OS
	mov ax,4c00h
	int 21h

END START


	;mov ah,08h
	;mov bh,0 	 ;page number (0 for graphics modes)
	;mov dh,12d   ;row
	;mov dl,0h    ;column
	;int 10h
