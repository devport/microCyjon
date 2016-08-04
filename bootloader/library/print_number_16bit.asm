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

print_number_16bit:
	; zachowaj oryginalne rejestry
	push	ax
	push	cx
	push	dx
	push	sp
	push	bp

	; system heksadecymalny
	mov	cx,	16

	; zapamiętaj koniec bufora danych
	mov	bp,	sp

.calculate:
	; wyczść resztę/starszą część
	xor	dx,	dx

	; wylicz resztę z dzielenia
	div	cx

	; załaduj do bufora
	push	dx

	; sprawdź czy zostało jeszcze coś do przeliczenia
	cmp	ax,	VARIABLE_EMPTY
	jne	.calculate	; jeśli tak, powtórz operacje

.print:
	; pobierz z bufora najstarszą cyfre
	pop	ax

	; procedura - wyświetl znak w miejscu kursora oraz przemieszcza kursor w prawo o jeden znak
	mov	ah,	0x0E

	; zamień cyfre na kod ASCII (0..9)
	add	al,	0x30

.continue:
	; wyświetl cyfre na ekranie
	int	0x10

	; sprawdź czy zostało coś w buforze
	cmp	bp,	sp
	jne	.print	; jeśli tak, wyświetl pozostałe cyfry

	; przywróć oryginalne rejestry
	pop	bp
	pop	sp
	pop	dx
	pop	cx
	pop	ax

	; powrót z procedury
	ret
