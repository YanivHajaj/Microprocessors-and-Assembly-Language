; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; exPrefix.asm
; 19/5/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: This code take hexa number and print it recorsively dropping a digit every iteration 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small
.stack 100h
.data

.code


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc1 Description: This function print to
;inputs:
	;number inside ax (in hexadecimal)
;output:
	;print to screen ax number decimal value 
print proc uses ax dx si bx;push the registers we used inside and pop them at the end
	mov bx,10d ;each L1 loop devided by 10
	mov si,0 ;counter for the screen printing
	add si,cx ;strat form row number (0,1,2...)
	L1:
	cmp ax,0 ;the number is 0 finsh printing
	je finish_print
	mov dx,0 ;witout init dx we got problem in CV mode when trying to div AX/BX
	div word ptr bx ;ax=ax/bx dx=ax modolo bx (resedue)
	add dl,'0'
	add dh,8eh
	mov es:[si+158d],dx  ;print to the end of first row(places 152,154,156,158 on screen) 
	sub si,2 ;dec si by 2 in order to print the next letter in other location
	
	jmp L1 ;continue to next digit
	
	finish_print:
	ret ;pop ip+1 (next instruction after call)
print endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc2 Description: This function get the hexa and send it to for printing
;inputs:
	;number from the stack (ax)
	;cx=0 counter the current row
;output:
	;printing to screen
numPrefix proc uses ax bx dx cx;push the registers we used inside GCD and pop them at the end
	
	mov bp,sp ;pin the sp adress 
	mov ax,[bp+10] ;+10 because stack contain (rerurn h,rerurn l,ah,al,bh,bl,dh,dl,ch,cl)
	call print
	cmp ax,10 ;ax is less then 10 (one digit we already printed) finsh printing
	jb finish_number_is_zero ;ax is 0 finsh printing
	
	mov bx,10d
	mov dx,0 ;witout init dx we got problem in CV mode when trying to div AX/BX

	div word ptr bx ;ax=ax/bx dx=ax modolo bx (resedue)
	push ax
	add cx,160d ;go to the next row
	call numPrefix
	
	finish_number_is_zero:

	ret 2;pop return value and then move sp +2 because we to clear the value inside stack (from last call))
numPrefix endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
START:
    ;mov cx,3
	;L2:
	;mov dx,1
	;push dx
	;loop L2
	
	;mov cx,3
	;L3:
	;mov dx,1
	;pop dx
	;loop L3
	
	;setting ds to data segment
	mov ax, @data
	mov ds,ax
	
	mov ax, 0b800h   ;screen memory
	mov es, ax       ;set es to print at screen memory
	
	mov ax,3132h  ;3132 are the first digits of our id
	;mov ax,0015d  ;0015 test
	push ax
	mov cx,0
	call numPrefix 
	
	;return to OS
	mov ax,4c00h
	int 21h

End START
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
