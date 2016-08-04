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

check_cpu:
	; sprawdź czy procesor obsługuje tryb 64 bitowy
	mov	eax,	0x80000000	; procedura - pobierz numer najwyższej dostępnej procedury
	cpuid	; wykonaj

	; spradź czy istnieją procedury powyżej 80000000h
	cmp	eax,	0x80000000
	jbe	.error	; jeśli nie, koniec

	; pobierz informacja o procesorze i poszczególnych funkcjach
	mov	eax,	0x80000001
	cpuid	; wykonaj

	; sprawdź czy wspierany jest tryb 64 bitowy (29 bit "lm" LongMode, rejestru edx)
	bt	edx,	29
	jnc	.error	; jeśli nie, koniec

	; procesor wspiera tryb 64-bitowy

	; powrót z procedury
	ret

.error:
	; brak procesora 64 Bitowego
	mov	si,	text_error_no_cpu
	call	print_16bit

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$
