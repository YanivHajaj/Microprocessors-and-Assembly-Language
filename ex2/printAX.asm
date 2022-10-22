; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; printAX.asm
; 28/4/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: This code print the value of AX in yelow and blue colors :) .
;first AX=0000. next AX=FE9B. and finally AX=12B4
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small
.stack 100h
.code
START:
mov ax, 0b800h   ;screen memory
mov es, ax       ;set es to print at screen memory

mov ax,0000    ;we want to print 0 
mov bp,000fh     ;init with  0000 0000 0000 1111(take last digit with and)
mov cl,4d         ;we do shift right 4 times with cl

mov ch,4d  ;loop counter. start loop 4 times
mov bx,0  ;offset of print to screen
L1_0:	    		
	mov dx,ax          ;dx=ax . dx is temporary ax every iteration
	and dx,bp 	       ;take one hex digit ,put in dx (now dx contain 1/2/3../f hex digit)	   
	cmp	dx,9d          ;digit =? 09 
    ja bigger_then_ten_0  ;digit>10
					   ;(if digit<10) its 1-9 digit (digit<10 section)
	add dx,'0'    	   ;(start from 0 in ascii table)
	jmp smaller_then_ten_0;skip digit>=10 section
	bigger_then_ten_0:	   ;else (digit>=10)
	add dx,55d     	   ;start from A-10 in the ascii table (55d+10d=55d+Ah='A')
	
	smaller_then_ten_0:
	mov dh,8eh       ;blinking yellow as color
mov es:[bx+152d],dx  ;print to the end of first row(places 152,154,156,158 on screen) 
shr ax,cl ;shift right ax 4 times
add bx,2
dec ch
jnz L1_0	

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;357d=0000 0001 0110 0101b -> -357d=1111 1110 1001 1010+1
;=1111 1110 1001 1011 = FE9B 
;=0FE9B (need to add 0 because F is letter)
;mov ax, 0FE9Bh 
mov ax,0FE9Bh    ;we want to print FE9B 
mov bp,000fh     ;init with  0000 0000 0000 1111(take last digit with and)
mov cl,4d         ;we do shift right 4 times with cl

mov ch,4d  ;loop counter. start loop 4 times
mov bx,6  ;6,4,2,0 options to offset when print (one for each letter)
L1_357:	    		
	mov dx,ax              ;dx=ax . dx is temporary ax every iteration
	and dx,bp 	           ;take one hex digit ,put in dx (now dx contain 1/2/3../f hex digit)	   
	cmp	dx,9d              ;digit =? 09 
    ja bigger_then_ten_357  ;digit>10
					       ;(if digit<10) its 1-9 digit (digit<10 section)
	add dx,'0'    	       ;(start from 0 in ascii table)
	jmp smaller_then_ten_357;skip digit>=10 section
	bigger_then_ten_357:	   ;else (digit>=10)
	add dx,55d     	       ;start from A-10 in the ascii table (55d+10d=55d+Ah='A')
	
	smaller_then_ten_357:
mov dh,81h           ;blinking blue as color
mov es:[bx+312d],dx  ;print to the end of second row(places 312,314,316,318 on screen) 

shr ax,cl ;shift right ax 4 times
sub bx,2
dec ch
jnz L1_357

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mov ax,12B4h    ;we want to print 12B4 
mov bp,000fh     ;init with  0000 0000 0000 1111(take last digit with and)
mov cl,4d         ;we do shift right 4 times with cl

mov ch,4d  ;loop counter. start loop 4 times
mov bx,6  ;6,4,2,0 options to offset when print (one for each letter)
L1_12B4:	    		
	mov dx,ax              ;dx=ax . dx is temporary ax every iteration
	and dx,bp 	           ;take one hex digit ,put in dx (now dx contain 1/2/3../f hex digit)	   
	cmp	dx,9d              ;digit =? 09 
    ja bigger_then_ten_12B4  ;digit>10
					       ;(if digit<10) its 1-9 digit (digit<10 section)
	add dx,'0'    	       ;(start from 0 in ascii table)
	jmp smaller_then_ten_12B4;skip digit>=10 section
	bigger_then_ten_12B4:	   ;else (digit>=10)
	add dx,55d     	       ;start from A-10 in the ascii table (55d+10d=55d+Ah='A')
	
	smaller_then_ten_12B4:
mov dh,8eh           ;blinking yellow as color 
mov es:[bx+160d*3-8],dx  ;print to the end of third row

shr ax,cl ;shift right ax 4 times
sub bx,2
dec ch
jnz L1_12B4


;return to OS
mov ax,4c00h
int 21h

End START