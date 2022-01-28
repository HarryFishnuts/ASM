; <regtest.asm>
; Bailey Jia-Tao Brown
; 2022
; Assembler: NASM
; Syntax: intel
; Machine: 32-bit ubuntu

;***** DATA SEGMENT *****
segment .data
dba: DD 0		; data buffer A
dbb: DD 0		; data buffer B
arr: times 32 DB '+'	; size 32 array of bytes

;***** EXEC SEGMENT *****
segment .text

; [ main routine ]
global _start
_start:
MOV eax, 0		; use eax as arr index
MOV ecx, 32		; use ecx as counter
.L0:			; loop 0

  MOV ebx, '!'				; do some stuff...
  ADD ebx, eax
  MOV [arr + eax], ebx
  MOVZX ebx, byte [arr + eax]
  MOV dword [dba], ebx

  PUSHA			; push all regs

  MOV eax, 4		; syscall write
  MOV ebx, 1		; fd: stdout
  MOV ecx, dba
  MOV edx, 1
  INT 0x80

  POPA			; restore all regs

  INC eax		; increment index
  DEC ecx		; decrement counter
  CMP ecx, 0		; check 0
  JG  .L0		; < 0 -> jmp .L0

; [ exit routine ]
MOV eax, 1
MOV ebx, 0
INT 0x80
