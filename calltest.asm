; <calltest.asm>
; Bailey Jia-Tao Brown
; 2022

;******** DATA SECTION ********
section .data
dba: DD 0			; data buffer A
dbb: DD 0 			; data buffer B
ret: DD 0			; return value buffer

;******** EXEC SECTION ********
section .text


; [main routine]
global _start
_start:


PUSH 3
CALL test
test:
MOV dword eax, [esp + 4]	; get stack ptr - 4 (should be 5)
ADD eax, '0'			; offset to ascii

; [print routine]
MOV dword [dba], eax
MOV eax, 4
MOV ebx, 1
MOV ecx, dba
MOV edx, 1
INT 0x80

; [exit routine]
MOV eax, 1
MOV ebx, 0
INT 0x80
