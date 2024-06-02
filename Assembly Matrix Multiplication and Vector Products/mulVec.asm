; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; mulvec.asm
; 28/4/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: This code multiply matrix with vector .
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
N EQU 3 
.model small
.stack 100h
.data
   MAT db 0f3h,0f3h,0f3h,3h,3h,3h,1h,1h,1h ;define byte (array of 9)
   ;MAT db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh ;define byte (array of 9)

   VEC db 03,03h,0fAh ;define byte (array of 3)
   RESULT dw N dup(?)
   
.code
START:
;setting ds to data segment
mov ax, @data
mov ds,ax

mov ax, 0b800h ;screen memory
mov es, ax     ;set es to print at screen memory

;init RESULT with 0's
mov bx,offset RESULT ;bx contain the relative addres of RESULT 
mov si,N
L1:
	mov byte ptr ds:[bx+si-1],0 ;init RESULT with 0's
	sub si,1
	jnz L1

	
mov bp,1 ;help determine the offset from the end of matrix in order to multiply the desired row
mov dx,N ;counter of outer loop L3
add bx,2*N-2 ;we want to start from the end of result vector
L3:
	;the general idea is to go from the end to start
    ;every L3 loop we pick a row to sum
    ;at the end of L2 loop we finhised summing up a specific row
	mov si,offset MAT ;si contain the relative addres of mat 
	mov di,offset VEC ;di contain the relative addres of vec 

	add si,N*N ;go to the end of matrix
	sub si,bp  ;decrease 1/2/3.../n in order to get the current row (in 3x3 example 3*3-1=8 the end of matrix)
	mov cx,N   ;counter of inner loop L2
	add di,N-1 ;go to the end of the vector
	

	L2:
		mov ax,0
		mov ax,ds:[si] ;put in ax the matrix last colomn in the desired row(determined by bp) 
		;mov ah,0 
		imul byte ptr ds:[di];AX=AL*vector(8bit*8bit=16bit)
		ADD word ptr DS:[bx],ax ;result=result+AX
		;mov dx,DS:[bx]
		sub si,N ;go 1 colomn to the left
		sub di,1 ;decrease vector offset by 1 in order to multiply next matrix colomn
		;sub bx,1
		dec cx ;decrese counter by 1

		jnz L2
		
	inc bp	;help decrease 1/2/3.../n in order to get the current row 
	sub bx,2	;go to next place in result vector	
	dec dx  ;decrease counter of outer loop L3
	jnz L3
	
	
	;mov al,ds:[di];put AL=the begining of vector 
	;mul byte ptr ds:[si] ;AX=AL*(begining of matrix)
	;ADD DS:[bx],ax;RESULT[0]=RESULT[0]+AX



mov es:[320d],ax
;mov ah,ds:[si] ;mat[0]=begining of MAT
;mov al,ds:[di] ;VEC[0]=41h=A symbol




;mov bx N
;mov cx N
;mul byte ptr [1000h]

;mov es:[320d],ax ;print first row to
;return to OS
mov ax,4c00h
int 21h

End START
