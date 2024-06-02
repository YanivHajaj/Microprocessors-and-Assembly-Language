; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; clocklTSR.asm
; 22/06/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: CHANGE IVT and print clock
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model tiny
.code
public CHANGE_IVT_TABLE
org 100h
extern BackToPrint:near
public TSR_START
public TSR_END
Timer db 0d
min dw 0d

sec dw 0d
mili dw 0d


PairityFlag  db 0d


TSR_START:
jmp CHANGE_IVT_TABLE ;go to IVT replace

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc1 Description: change inturpt 1c
;inputs:
	;none
;output:
	;none
ISR_New_int_1c proc uses dx es bx ax


	mov bx, 0b800h   ;screen memory
	mov es, bx       ;set es to print at screen memory 
	
	add mili,55d
	cmp mili, 1000d
	jb Cmp_min ;less then 1000 check min
	add sec,1 ;above 1000 inc sec
	mov mili,0 ;init mili
	add PairityFlag,1
	;cmp PairityFlag,0d
	;jz MakeFlag1
	;mov PairityFlag,0d
	
	;MakeFlag1:
	;mov PairityFlag,1d
	
	Cmp_min: ;below 1000 jump here
	
	cmp sec,60d ;if sec=10 inc min
	jb PRINTCLK ;sec<10? if yes jump
	
	add min,1 ;inc min
	mov sec,0 ;init sec
	
	PRINTCLK:
	
	mov dl,PairityFlag
	and dl,1
	jz PairityFlag_1
	
	;cmp PairityFlag,1d
	;jz PairityFlag_1
	
	;PairityFlag_0:
	mov ax,mili
	mov dx,0
	mov bx,10
	div word ptr bx ;ax=result (upper 2 digits)
	
	mov dx,0
	mov bh,10
	div bh ;ax/10 al=result ah=resedue
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,ah 		;ah=resedue
	add bl,bh
	mov bh,63h      ;color
	mov es:[258],bx ;print sec
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,al 		;ah=resedue
	add bl,bh
	mov bh,63h      ;color
	mov es:[256],bx ;print sec

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sec	
	mov dx,0
	mov ax,sec
	mov bh,10
	div bh ;ax/10 al=result ah=resedue
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,ah 		;bx=sec
	add bl,bh
	mov bh,63h      ;color
	mov es:[252],bx ;print sec
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,al 		;bx=sec
	add bl,bh
	mov bh,63h      ;color
	mov es:[250],bx ;print sec
	
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~min	
	mov dx,0
	mov ax,min
	mov bh,10
	div bh ;ax/10 al=result ah=resedue
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,ah 		;bx=min
	add bl,bh
	mov bh,63h      ;color
	mov es:[246],bx ;print sec
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,al 		;bx=min
	add bl,bh
	mov bh,63h      ;color
	mov es:[244],bx ;print sec
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~min
	
	jmp prev_isr
	
	
	PairityFlag_1:
	mov ax,mili
	mov dx,0
	mov bx,10
	div word ptr bx ;ax=result (upper 2 digits)
	
	mov dx,0
	mov bh,10
	div bh ;ax/10 al=result ah=resedue
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,ah 		;ah=resedue
	add bl,bh
	mov bh,61h      ;color
	mov es:[258],bx ;print sec
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,al 		;ah=resedue
	add bl,bh
	mov bh,61h      ;color
	mov es:[256],bx ;print sec

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sec	
	mov dx,0
	mov ax,sec
	mov bh,10
	div bh ;ax/10 al=result ah=resedue
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,ah 		;bx=sec
	add bl,bh
	mov bh,61h      ;color
	mov es:[252],bx ;print sec
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,al 		;bx=sec
	add bl,bh
	mov bh,61h      ;color
	mov es:[250],bx ;print sec
	
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~min	
	mov dx,0
	mov ax,min
	mov bh,10
	div bh ;ax/10 al=result ah=resedue
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,ah 		;bx=min
	add bl,bh
	mov bh,61h      ;color
	mov es:[246],bx ;print sec
	
	mov bl,'0'    	       ;(start from 0 in ascii table)
	mov bh,al 		;bx=min
	add bl,bh
	mov bh,61h      ;color
	mov es:[244],bx ;print sec
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~min

	
	
	prev_isr:
	int 80h ;use the old interupt 1c
	iret
ISR_New_int_1c endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	;update IVT table
	
	
CHANGE_IVT_TABLE:
	push es
	
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
	
	pop es
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	jmp BackToPrint
	
	
	TSR_END:
	
	mov dx,offset CHANGE_IVT_TABLE ;save all instruction above SAVE_ABOVE lable 
	int 27h
	
end
