; <checker.asm>
; Bailey Jia-Tao Brown
; 2022

;==== DATA SEGMENT ====
segment .data
tba: DD 0		; data buffer A
tbb: DD 0		; data buffer B
sba: times 64 DB 0	; string buffer A
sbb: times 64 DB 0	; string buffer B
iter: DD 64

;==== EXEC SEGMENT ====
segment .text
global _start
_start:

MOV eax, 0		; set eax to 0
MOV ebx, 0		; set ebx to 0

; == loop ==
loop:			; loop
INC eax			; increment eax (used as counter)
MOV [tba], eax		; save eax to tba

; == perform div operation ==
MOV edx, 0		; clear edx
MOV ecx, 3		; set divisor (eax is dividend)
DIV ecx			; call divide (eax has result, edx has remainder)
MOV [tbb], edx		; save remainder to tbb

; == if tbb is 0, print 0, else, print 1
CMP dword [tbb], 0		; check if 0
JZ setzero			; on 0, jump to print
MOV byte [sba], '1'		; setchar to '1'
JMP print			; jump to print

setzero:
MOV byte [sba], '0'		; setchar to '0'

; == print (call write) ==
print:
MOV eax, 4		; syscall 4 (write)
MOV ebx, 1		; fd 1 (stdout)
MOV ecx, sba		; string buffer
MOV edx, 1		; print size
INT 0x80

MOV eax, [tba]		; restore eax
CMP eax, [iter]		; cmp 64
JL loop			; if less than 64, loop

; == system exit ==
MOV eax, 1
MOV ebx, 0
INT 0x80

