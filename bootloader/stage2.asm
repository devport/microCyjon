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

%define	VARIABLE_PROGRAM_NAME	stage2

%include	"config.asm"

; 16 Bitowy kod programu
[BITS 16]

; położenie kodu programu w pamięci fizycznej 0x0000:0x1000
[ORG VARIABLE_STAGE2_ADDRESS]

;-------------------------------------------------------------------------------
; Program rozruchowy wspiera jądra systemu 32 i 64 bitowe.                     -
;-------------------------------------------------------------------------------

start:
	; wyczyść DirectionFlag, wszystkie liczniki mają "maleć" w pętlach a wskaźniki "rosnąć"
	cld

	; wyświetl powitanie
	mov	si,	text_init
	call	print_16bit

	; wyłącz wszelkie przerwania przychodzące od urządzeń: zegar, klawiatura, dyski, karty sieciowe itp.
	; i tak nie posiadamy ich obslugi w tym momencie
	call	disable_pic

	; wyświetl sukces wyłączenia kontrolera PIC
	mov	si,	text_pic
	call	print_16bit

	; sprawdź typ procesora
	; skoro system będzie w pełni 64 bitowy, to przydał by się i 64 bitowy procesor, czyż nie?
	call	check_cpu

	; wyświetl sukces rozpoznania procesora
	mov	si,	text_cpu
	call	print_16bit

	; odblokuj linię A20 (dostęp do pamięci powyżej adresu 0x00100000)
	; domyślnie powinna być zamknięta
	; istnieją BIOSy które odblokowują linię automatycznie
	; ale sprawdźmy dla świętego spokoju
	call	unlock_a20

	; wyświetl sukces odblokowania dostępu do całej pamięci RAM
	mov	si,	text_a20
	call	print_16bit

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

%include	"bootloader/library/print_16bit.asm"
%include	"bootloader/library/disable_pic.asm"
%include	"bootloader/library/check_cpu.asm"
%include	"bootloader/library/unlock_a20.asm"

; wczytaj lokalizacje sektora rozruchowego
%push
	%defstr		%$system_locale		VARIABLE_SYSTEM_LOCALE
	%defstr		%$process_name		VARIABLE_PROGRAM_NAME
	%strcat		%$include_program_locale,	"bootloader/", %$process_name, "/locale/", %$system_locale, ".asm"
	%include	%$include_program_locale
%pop
