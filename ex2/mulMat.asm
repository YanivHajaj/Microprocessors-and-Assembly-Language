; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; mulMat.asm
; 28/4/2022
; yaniv hajaj  316411578
; ori glam   322573452
; Description: This code multiply matrix with another matrix.
; basiclly we took the mulvec idea and expend it to mat1*mat2.
; we created an outer loop, and now each iteration we take mat1 with different vector of mat2 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
N EQU 3 
.model small
.stack 100h
.data
   MAT1 db 2h,2h,2h,0fdh,0fdh,0fdh,77h,77h,77h ;define byte (array of 9)
   MAT2 db 1h,45h,0eeh,0fdh,01,21h,52h,23h,1h ;define byte (array of 3)
   RESULT dw N*N dup(?)


.code
START:
;setting ds to data segment
mov ax, @data
mov ds,ax

mov ax, 0b800h ;screen memory
mov es, ax     ;set es to print at screen memory

;init RESULT with 0's
mov bx,offset RESULT ;bx contain the relative addres of RESULT 
mov si,N*N
L1:
	mov byte ptr ds:[bx+si-1],0 ;init RESULT with 0's
	sub si,1
	jnz L1

	mov sp,0 ;help to determine result offset (starting from 0)
	mov dh,N;outer loop counter
	
	
outerloop:
mov bx,offset RESULT ;bx contain the relative addres of RESULT 

mov bp,1 ;help determine the offset from the end of matrix in order to multiply the desired row
mov dl,N ;counter of outer loop L3
add bx,2*N*N-2 ;we want to start from the end of result vector
sub bx,sp ;
sub bx,sp ;decrease result offset by 2sp(2*sp=0/2N/4N/6N...2N*2N-2N)
L3:
	;the general idea is to go from the end to start
    ;every L3 loop we pick a row to sum
    ;at the end of L2 loop we finhised summing up a specific row
	mov si,offset MAT1 ;si contain the relative addres of MAT1 
	mov di,offset MAT2 ;di contain the relative addres of MAT2 

	add si,N*N ;go to the end of matrix
	sub si,bp  ;decrease 1/2/3.../n in order to get the current row (in 3x3 example 3*3-1=8 the end of matrix)
	mov ch,N   ;counter of inner loop L2
	add di,N*N-1 ;go to the end of the vector
	sub di,sp ;decrease MAT2 offset by sp(sp=0/N/2N/3N...N*N-N)
    
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
		dec ch ;decrese counter by 1

		jnz L2
		
	inc bp	;help decrease 1/2/3.../n in order to get the current row 
	sub bx,2	;go to next place in result vector
	dec dl  ;decrease counter of outer loop L3
	jnz L3
	
	add sp,N ;help to take the desired ~vector~ we want to addres inside MAT2 or inside RESULT (every outer loop we take MAT1*MAT2(vector) and get result(vector))
dec dh ;decrese outer loop counter by 1
jnz outerloop	


;return to OS
mov ax,4c00h
int 21h

End START