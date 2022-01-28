; <rstr.asm>
; Bailey Jia-Tao Brown
; 2022
;    Assembler: NASM
;       Syntax: Intel
;       Format: elf32
;       Kernel: Ubuntu (64-bit)
; Architecture: i386

;***** MACRO SECTION *****
%define fbw 10		; framebuffer width
%define fbh 10		; framebuffer height
%define fbd fbw * fbh	; framebuffer dimensions

;***** DATA SECTION *****
section .data
dba: DD 0		; data buffer A
dbb: DD 0		; data buffer B
clr: DB 11		; clear character
fbf: times fbd DB '='	; framebuffer

;***** EXEC SECTION *****
section .text

; [ render routine ]
; no params
; no return value
render:
  PUSH ebp
  MOV ebp, esp
  PUSHA					; push all regs

  MOV dword eax, 0			; eax = Y counter

  .lpy:					; Y loop
    MOV ebx, 0				; ebx = X counter

    .lpx:				; X loop
      PUSH eax				; param 2: y
      PUSH ebx				; param 1: x
      CALL drawpix			; draw X, Y
      CALL drawpix
      ADD esp, 8			; clear stack

      INC ebx				; increment x counter
      CMP ebx, fbw			; if <= width
      JL  .lpx				; repeat x loop

    PUSH eax				; push eax
    PUSH ebx				; push ebx

    MOV eax, 4				; output a newline
    MOV ebx, 1
    MOV dword [dba], 10
    MOV ecx, dba
    MOV edx, 1
    INT 0x80

    POP ebx				; restore ebx
    POP eax				; restore eax

    INC eax				; increment y counter
    CMP eax, fbh				; if <= fb height
    JL  .lpy				; repeat y loop

  POPA					; restore all regs
  MOV esp, ebp
  POP ebp
  RET

; [ drawpix routine ]
; param 1: pixel x
; param 2: pixel y
; no return value
drawpix:
  PUSH ebp
  MOV ebp, esp
  PUSHA

  ; Get the pixel index
  ; Index is calculated as: (y * h) + x
  ; Store index in eax
  MOV eax, [ebp + 12]		; eax = param 2
  MOV ebx, [ebp + 8 ]		; ebp = param 1
  MOV ecx, fbh			; ecx = fb height
  MUL ecx			; eax *= height
  ADD eax, ebx			; eax += height

  ADD eax, fbf			; offset index by fb
  MOV ebx, [eax]
  MOV [esp - 4], ebx		; save write data at 4

  CMP dword [esp - 4], 0
  JZ  .nullprint

  MOV eax, 4			; write
  MOV ebx, 1			; stdout
  MOV ecx, esp
  SUB ecx, 4
  MOV edx, 1
  INT 0x80			; int kernel
  JMP .end

  .nullprint:			; if value == 0 print '-'
  MOV eax, 4
  MOV ebx, 1
  MOV dword [dba], '-'
  MOV ecx, dba
  MOV edx, 1
  INT 0x80

  .end:
  POPA
  MOV esp, ebp
  POP ebp
  RET

; [ _dbgprt routine ]
; param 1: val to rpint
; returns nothing
_dbgprt:
PUSH ebp
MOV ebp, esp
PUSHA

MOV eax, [ebp + 8]		; get param 1
MOV [dbb], eax			; set dbb to param 1

MOV eax, 4			; print value
MOV ebx, 1
MOV ecx, dbb
MOV edx, 1
INT 0x80

POPA
MOV esp, ebp
POP ebp
RET

; [ setpix routine ]
; param 1: x val
; param 2: y val
; param 3: draw char
setpix:
PUSH ebp
MOV ebp, esp
PUSHA

; get fb index
MOV eax, [ebp + 12]		; eax = param 2
MOV ebx, [ebp + 8]		; ebx = param 1
MOV ecx, [ebp + 16]		; ecx = drawchar
MOV edx, fbh			; edx = h
MUL edx				; eax *= 8
ADD eax, ebx			; eax += ebx

MOV ebx, eax			; ebx = index
MOV eax, ecx			; eax = drawchar
MOV [fbf + ebx], al		; 1 byte set framebuffer

POPA
MOV esp, ebp
POP ebp
RET

; [ setrect routine ]
; param 1: X
; param 2: Y
; param 3: W
; param 4: H
; param 5: drawchar
setrect:
PUSH ebp
MOV ebp, esp
PUSHA

; { routine stack layout }
; ebp - 8  = X counter
; ebp - 4  = Y counter
; === ebp ============
; ebp + 4  = jmp
; ebp + 8  = X
; ebp + 12 = Y
; ebp + 16 = W
; ebp + 20 = H
; ebp + 24 = drawchar
SUB esp, 8			; allocate 4 32bit vars

MOV dword [ebp - 4], 0		; [ebp-4] = y counter
NOP				; [ebp-8] = x counter (to be assigned)

.lpy:				; Y axis loop

  MOV dword [ebp - 8], 0	; reset X counter

  .lpx:				; X axis loop

    MOV eax, [ebp + 24]		; get drawchar param
    PUSH eax			; push drawchar param

    MOV eax, [ebp - 4]		; get Y counter
    ADD eax, [ebp + 12]		; offset by Y
    PUSH eax			; push Y param

    MOV eax, [ebp - 8]		; get X counter
    ADD eax, [ebp + 8]		; offset by X
    PUSH eax			; push X param

    CALL setpix			; setpixel
    ADD esp, 12			; clean stack

    INC dword [ebp - 8]		; increment X coord
    MOV eax, [ebp + 16]		; mov W limit to register
    CMP [ebp - 8], eax		; cmp X coord w/ W limit
    JL  .lpx			; if less, loop

  INC dword [ebp - 4]		; increment Y coord
  MOV eax, [ebp + 20]		; mov H limit to register
  CMP [ebp - 4], eax		; compare w/ H limit
  JL  .lpy 			; if less, repeat

ADD esp, 8			; clean stack

POPA
MOV esp, ebp
POP ebp
RET

; [ main routine ]
global _start
_start:

PUSH 48
PUSH 4
PUSH 5
CALL setpix
ADD esp, 12

PUSH '8'
PUSH 3
PUSH 3
PUSH 5
PUSH 5
CALL setrect
ADD esp, 24

CALL render
CALL exit

; [ exit routine ]
exit:
MOV eax, 1
MOV ebx, 0
INT 0x80
