; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;-------------------------------------------------------------------------------

; Use:
; nasm - http://www.nasm.us/

; 16 Bitowy kod programu
[BITS 16]

disable_pic:
	; wyłączamy wszystkie przerwania sprzętowe (PIC)
	mov	al,	11111111b
	out	0xA1,	al	; IRQ 8-15
	out	0x21,	al	; IRQ 0-7

	; powrót z procedury
	ret
