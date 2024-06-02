; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; GCD.asm
; 19/5/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: This code get gcd of two positive numbers, then take array and calculte gcd on each value in the array.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small
.stack 100h
.data
;input_arr dw 3d,9d,12d,18d,33d ;define dw (gcd of all 3)
;input_arr dw 42d,60d,36d,24d,66d ;define dw (gcd of all 6)
;input_arr dw 1d,1d,1d,1d,1d,1d,1d,1d,1d,1d,1d ;define dw (gcd of all 66)
input_arr dw 500d dup (4);n=500 array test
;input_arr dw 198d,462d,594d,132d,66d ;define dw (gcd of all 66)
inputlen EQU 500d
result dw 0
.code

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc1 Description: This function get gcd of two positive numbers .
;inputs:
	;ax - first number a
	;bx - first number b
;output:
	;result - get the gcd of a and b
recGCD proc uses ax bx dx cx;push the registers we used inside GCD and pop them at the end
		cmp bx,0
		je finish_b_is_zero 
		mov dx,0 ;witout init dx we got problem in CV mode when trying to div AX/BX
		
		mov cx,bx ;save bx
		div word ptr bx ;ax=ax/bx dx=ax modolo bx (resedue)
		mov bx,dx ;put resedue in bx
		mov ax,cx ;put a->b (cx is old bx)
		
		;we created loop in order to get a%b and then we realise we can use div and get the resedue
		;so it is better time moplexity with div
		;L1:	;loop to get a modulo b
		;	mov dx,bx ;save a in dx
		;	sub dx,ax;dx=bx-ax (a-b)	
		;	cmp dx,0 
		;	jl dx_less_then_zero ;dx=bx-ax < 0 ?
		;		;dx=bx-ax > 0
		;	mov bx,dx ;save dx=bx-ax in b
		;	jmp L1
			
	;dx_less_then_zero:	
	
	
	;div word ptr bx ;ax=ax/bx dx=ax modolo bx (resedue)
	;mov ax,cx
	;mov bx,dx ;save a%b
	
		
	call recGCD
	
	jmp finish_b_is_not_zero ;dont change result
	
	finish_b_is_zero:
	mov result,ax ;finished put ax inside result (memory)
	
	finish_b_is_not_zero:
	ret ;pop ip+1 (next instruction after call)
recGCD endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;proc2 Description: This function get gcd of array containing positive numbers .
;inputs:
	;none
;output:
	;result - get the gcd of array in ax register
arrGCD proc uses bx dx si;push the registers we used inside and pop them at the end
	
	cmp si,0
	je array_finished
	mov ax,result ;save the last result also in ax
	mov bx,input_arr[si-2] ;take each time a diffrent value of the array and put in ax
	call recGCD;call gcd on ax=result, bx=array[si]
	sub si,2
	call arrGCD
array_finished:
	ret ;pop ip+1 (next instruction after call)
arrGCD endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
START:
	;setting ds to data segment
	mov ax, @data
	mov ds,ax
	
	;mov  ax,2400d
	;mov  bx,300d ;gcd(2400,300)=300d  = 12c hex
	;call recGCD ;push ip 
    
	
	mov si,inputlen
	add si,si ;each array value is a word so multiply lenth by 2 
	mov dx,input_arr[si-2];canot put memmory inside memory, use dx for transfering
	mov result,dx;put the last array value inside result 
	sub si,2
	call arrGCD
	
	;return to OS
	
	mov ax,4c00h
	int 21h

End START
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
