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

unlock_a20:
	; przedstawione zostały tu 4 sposoby na odblokowanie linii A20
	; jak wszystkie zawiodą, to w sumie możemy wyłączyć komputer

	; spradź czy brama a20 jest odblokowana (nie wyważaj otwartych drzwi)
	call	.check_a20
	jc	.bios	; jeśli nie, spróbuj za pomocą BIOSu

	; brama a20 odblokowana

	; powrót z procedury
	ret

;-------------------------------------------------------------------------------
.bios:
	; odblokuj brama a20 za pomocą funkcji BIOSu
	mov	ax,	0x2401
	int	0x15	; wykonaj

	; spradź czy brama a20 jest odblokowana
	call	.check_a20
	jc	.keyboard	; jeśli nie, spróbuj za pomocą kontrolera klawiatury

	; brama a20 odblokowana

	; powrót z procedury
	ret

;-------------------------------------------------------------------------------
.keyboard:
	; wyłącz przerwania
	cli

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .wait_for_keyboard_in

	; wyłącz klawiaturę
	mov	al,	0xAD
	out	0x64,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .wait_for_keyboard_in

	; poproś o możliwość odczytania danych z portu klawiatury
	mov     al,	0xD0
	out     0x64,	al

	; poczekaj, aż klawiatura będzie gotowa dać odpowiedź
	call    .wait_for_keyboard_out

	; pobierz z portu klawiatury informacje
	in      al,	0x60

	; zapamiętaj wiadomość
	push    ax

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .wait_for_keyboard_in

	; poproś o możliwość zapisania danych do portu klawiatury
	mov     al,	0xD1
	out     0x64,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .wait_for_keyboard_in

	; przywróć poprzednią wiadomość
	pop     ax

	; ustaw bit drugi rejestru AL
	or      al,	2
	out     0x60,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call	.wait_for_keyboard_in

	; włącz klawiaturę
	mov     al,	0xAE
	out     0x64,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .wait_for_keyboard_in

	; włącz przerwania
	sti

	; spradź czy brama a20 jest odblokowana
	call	.check_a20
	jc	.fastgate	; jeśli nie, spróbuj za pomocą FatGate

	; brama a20 odblokowana

	; powrót z procedury
	ret

;-------------------------------------------------------------------------------
.fastgate:
	; pobierz status z rejestru System Control Port A
	in	al,	0x92
	test	al,	2	; sprawdź czy bit drugi jest równy zero
	jnz	.fastgate_end	; jeśli nie, sprawdź

	; włącz bit 2
	or	al,	2
	and	al,	0xFE
	out	0x92,	al	; wyślij

.fastgate_end:
	; spradź czy brama a20 jest odblokowana
	call	.check_a20
	jc	.fastgate_error	; no i pies pogrzebany, nie udało się odblokować linii a20 w jakikolwiek sposób

	; brama a20 odblokowana

	; powrót z procedury
	ret

.fastgate_error:
	; wyświetl informacje o zablokowanej linii A20
	mov	si,	text_no_a20
	call	print_16bit

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

;-------------------------------------------------------------------------------
.check_a20:
	xchg	bx,bx

	; zapamiętaj adres segmentu danych
	push	ds

	; ustaw segment danych na koniec
	; będziemy mieć dostęp do pamięci fizycznej od adresu 0x000FFFF0
	mov	ax,	0xFFFF
	mov	ds,	ax

	; sprawdźmy czy za adresem 0x00100000, znajdziemy sygnaturę sektora rozruchowego :)
	; dowiemy się czy pamięć jest zapętlona
	cmp	dword [ds:0x10 + VARIABLE_STAGE1_ADDRESS + STRUCTURE_BOOTSECTOR.signature],	VARIABLE_STAGE1_BOOTSECTOR_MAGIC
	jne	.end_check_a20	; jeśli nie ma, linia a20 jest odblokowana, sukces

	; brama a20 zablokowana

	; flaga, błąd
	sti

	; koniec
	jmp	.end

.end_check_a20:
	; flaga, sukces
	clc

.end:
	; przywróć adres segmentu danych
	pop	ds

	; powrót z procedury
	ret

;-------------------------------------------------------------------------------
.wait_for_keyboard_in:
	; pobierz status bufora klawiatury do al
	in	al,	0x64
	test	al,	2	; sprawdź czy bit drugi jest równy zero

	; jeśli nie, powtórz operacje
	jnz	.wait_for_keyboard_in

	ret

;-------------------------------------------------------------------------------
.wait_for_keyboard_out:
	; pobierz status bufora klawiatury do al
	in	al,	0x64
	test	al,	1	; sprawdź czy bit pierwszy jest równy zero

	; jeśli nie, powtórz operacje
	jz	.wait_for_keyboard_out

	ret
