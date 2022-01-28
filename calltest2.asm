; <calltest2.asm>
; Bailey Jia-Tao Brown
; 2022

; ***** DATA SEGMENT *****
segment .data
dba: DD 0		; data buffer A
dbb: DD 0		; data buffer B

; ***** EXEC SEGMENT *****
segment .text

; [multiply routine]
; param 1: a
; param 2: b
; returns a * b to eax
multiply:
PUSH ebp		; save ebp
MOV ebp, esp		; set ebp to stack ptr

MOV eax, [ebp + 8]	; set eax to b
MOV ecx, [ebp + 12]	; set ecx to a
MUL ecx			; multiply eax w/ ebx

MOV esp, ebp		; reset stack ptr
POP ebp			; restore ebp
RET			; jump back

; [main routine]
global _start
_start:
PUSH 7			; param b
PUSH 1			; param a
CALL multiply
ADD esp, 8		; clean stack

ADD eax, '0'		; add '0' to eax
MOV dword [dba], eax	; copy eax to dba

; [print routine]
MOV eax, 4		; syscall(4) -> write
MOV ebx, 1		; fd(1) -> stdout
MOV ecx, dba		; output -> dba
MOV edx, 1		; print 1 byte
INT 0x80		; int kernel

; [exit routine]
MOV eax, 1
MOV ebx, 0
INT 0x80
