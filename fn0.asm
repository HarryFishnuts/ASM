; <fn0.asm>
; Bailey Jia-Tao Brown
; 2022

section .data
; ======== BUFFER SECTION ======== 
dba: DD 0		; data buffer A
dbb: DD 0		; data buffer B
dbc: DD 0		; data buffer C
dbd: DD 0		; data buffer D
sba: times 64 DB 0	; string buffer A
sbb: times 64 DB 0	; string buffer B
abf: times 16 DD 0	; argument buffer

; ======== DATA SECTION ========
framebuffer: times 100 DD 0	; 10x10 framebuffer
dctrx: DD 0			; draw routine x counter
dctry: DD 0			; draw routine y counter

; ======== DRAW ROUTINE =======
draw:

MOV dword [dctrx], 0		; reset x counter
MOV dword [dctry], 0		; reset y counter

lout:				; outer loop
INC dword [dctry]		; increment y coordinate
MOV dword [dctrx], 0		; reset x counter

lin:				; inner loop
  INC dword [dctrx]		; increment x coordinate


  ; ecx will hold framebuffer index
  ; i = (Y * 10) + x
  PUSHA				; push all registers
  MOV dword eax, [dctry]	; set eax to y coord
  MOV dword ebx, 10		; set ebx to 10
  MUL ebx			; mul eax w/ ebx
  MOV dword ecx, [dctrx]	; set ecx to x coord
  ADD ecx, eax			; sum ecx, ebx

  ; eax is now repurposed to hold framebuffer value
  ; copy eax to dba for printing
  MOV eax, [framebuffer + ecx]	; set eax to *(fb + ecx)
  MOV dword [dba], eax		; set dba to eax

  ; if eax is 0, set dba[0] to '='
  CMP byte [dba], 0		; compare dba[0] with 0
  JNE notzero			; if not 0, skip
  MOV byte [dba], '='

  notzero:
  ; call system write
  MOV eax, 4			; syscall(4) -> write
  MOV ebx, 1			; fd(1) -> stdout
  MOV ecx, dba			; char* -> dba
  MOV edx, 1			; writesize -> 1
  INT 0x80			; signal kernel

  ; restore values
  POPA				; restore all registers


  CMP dword [dctrx], 10		; check if reached 10
  JL  lin			; if less, goto inner loop


; print newline to indicate Y axis increment
MOV byte [dba], 10		; newline
; push all
PUSHA
; print newlineA
MOV eax, 4
MOV ebx, 1
MOV ecx, dba
MOV edx, 1
INT 0x80
; restore registers
POPA

CMP dword [dctry], 10		; check if reached 10
JL  lout			; if less, goto outer loop


RET				; return


; ======== FILL ROUTINE ========
; param 0: x
; param 1: Y
; param 2: W
; param 3: H
; param 4: display char
fill:
PUSHA				; push all registers

MOV eax, [abf + 0]
MOV dword [dctrx], eax		; set draw x to arg[0]
MOV eax, [abf + 1]
MOV dword [dctry], eax		; set draw y to arg[1]

; === outer loop ===

lfilly:				; fill y loop
INC dword [dctry]		; increment Y draw position
MOV dword eax, [abf + 0]	; get X
MOV dword [dctrx], eax 		; reset draw x to X

; === inner loop ===

lfillx:

  INC dword [dctrx]		; increment X draw postition
  ; use eax, ebx & ecx to get framebuffer index
  ; i = (y * 10) + x
  MOV dword eax, [dctry]	; set eax to Y
  MOV dword ebx, 10		; set ebx to 10
  MUL ebx			; eax * ebx
  MOV ecx, [dctrx]		; set ecx to X draw pos
  ADD ecx, eax			; add eax and ecx

  MOV ebx, [abf + 4]		; set ebx to draw char
  MOV dword [framebuffer + ecx], ebx

  MOV eax, [abf + 2]		; loop if less than W
  CMP dword [dctrx], eax
  JL  lfillx

; === inner loop end ===

MOV eax, [abf + 3]
CMP dword [dctry], eax		; check if drawx < arg[2] (W)
JL  lfilly			; if less, loop

; === outer loop end ===

POPA				; restore all registers
RET				; return


; ======== MAIN ROUTINE ========
global _start
_start:			; entry point

;setup fill params
MOV dword [abf + 0], 0
MOV dword [abf + 1], 0
MOV dword [abf + 2], 1
MOV dword [abf + 3], 1
MOV dword [abf + 4], '0'

CALL fill		; call fill
CALL draw		; call draw


; ======== SYSTEM EXIT ========
exit:
MOV eax, 1
MOV ebx, 0
INT 0x80



