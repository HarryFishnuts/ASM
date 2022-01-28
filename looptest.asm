; <looptest.asm>
; Bailey Jia-Tao Brown
; 2022

; ***** DATA SEGMENT *****
segment .data
dba: DD 0		; data buffer A
dbb: DD 0		; data buffer B

; ***** EXEC SEGMENT *****
segment .text

; [ prntloop routine ]
; param 1: loopcount
; param 2: printchar
; doesn't return
prntloop:
PUSH ebp			; push ebp
MOV ebp, esp		; set ebp to esp

MOV ecx, [ebp + 8]		; set ecx to param 1
MOV edx, [ebp + 12]		; set edx to param 2
MOV dword [dba], edx		; set dba to edx

lin:				; inner loop
	PUSHA				; push all registers
	MOV eax, 4			; syscall(4)
	MOV ebx, 1			; fd(1)
	MOV ecx, dba		; print dba
	MOV edx, 1			; print 1 byte
	INT 0x80			; int kernel
	POPA				; restore all registers
	DEC ecx			; decrement ecx
	CMP ecx, 0			; compare to 0
	JG  lin			; if greater, loop

MOV esp, ebp		; clean stack
POP ebp			; restore ebp
RET				; end

; [ main routine ]
global _start
_start:

PUSH '0'		; param 2
PUSH 7		; param 1
CALL prntloop
ADD esp, 8		; clean stack

PUSH '1'		; param 2
PUSH 20		; param 1
CALL prntloop
ADD esp, 8		; clean stack

; [ exit routine ]
MOV eax, 1
MOV ebx, 0
INT 0x80
