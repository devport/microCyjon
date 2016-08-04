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
	; wyczyść DirectionFlag
	cld

	; wyświetl powitanie
	mov	si,	text_init
	call	print_16bit

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

; niezbędne procedury do informowania o ewentualnych błędach podczas działania sektora rozruchowego
%include	"bootloader/library/print_16bit.asm"

; wczytaj lokalizacje sektora rozruchowego
%push
	%defstr		%$system_locale		VARIABLE_SYSTEM_LOCALE
	%defstr		%$process_name		VARIABLE_PROGRAM_NAME
	%strcat		%$include_program_locale,	"bootloader/", %$process_name, "/locale/", %$system_locale, ".asm"
	%include	%$include_program_locale
%pop
