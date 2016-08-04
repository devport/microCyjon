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

%define	VARIABLE_PROGRAM_NAME	stage1

%include	"config.asm"

; 16 bitowy kod programu
[BITS 16]

; położenie kodu programu w pamięci fizycznej 0x0000:0x7C00
[ORG VARIABLE_STAGE1_ADDRESS]

start:
	; wyłącz przerwania
	cli

	; ustaw: segment CS = 0x0000, rejestr IP = VARIABLE_STAGE1_ADDRESS + przesunięcie do etykiety .reload
	jmp	VARIABLE_EMPTY:.reload

.reload:
	; ustaw segmenty danych, ekstra i stosu na pierwsze 64 KiB pamięci fizycznej
	xor	ax,	ax
	mov	ds,	ax	; segment danych
	mov	es,	ax	; segment ekstra
	mov	ss,	ax	; segment stosu

	; ustaw wskaźnik szczytu stosu na początek kodu sektora rozruchowego
	mov	sp,	VARIABLE_STAGE1_ADDRESS

	; włącz przerwania
	sti

	; inicjalizuj tryb tekstowy 80x25, zarazem wyczyść ekran
	mov	ax,	0x0003
	int	0x10

	; sektor rozruchowy jest przygotowany
	;
	; teraz pora zlokalizować nasz sektor rozruchowy na nośniku
	; mogliśmy zostać uruchomieni z poziomu nośnika (pierwszy sektor) lub partycji!
	; 
	; wykorzystamy do tego przerwanie 0x13, procedury 0x42 BIOSu

	; czasami BIOS nie udostępnia danej procedury, jeśli o nią wpierw nie zapytamy
	mov	ah,	0x41	; sprawdź dostępne rozszerzenia
	mov	bx,	0x55AA	; wartość domyślna (wymagana przez procedurę)
	int	0x13

	; parę testów by sprawdzić czy interesująca nas procedura jest dostępna
	jc	.bios_not_supported	; podniesiona flaga CF oznacza brak dostępnej procedury
	cmp	bx,	0xAA55	; rejestry BL i BH powinny byś zamienione miejscami
	jne	.bios_not_supported
	bt	cx,	VARIABLE_BIT_0	; wyłączony bit 0 w rejestrze CL oznacza brak dostępnej procedury
	jnc	.bios_not_supported

	; wpierw sprawdzimy sektor rozruchowy nośnika
	; znajdziemy tam i tablicę partycji

	; odczytaj pierwszy sektor nośnika na którym się znajdujemy
	mov	ah,	0x42
	mov	si,	variable_stage1_packet_table	; jeśli nie wiesz co to jest => http://www.ctyme.com/intr/rb-0708.htm
	int	0x13

	; operacja wczytania danych przebiegła pomyślnie?
	jc	.read_error

	; zapamiętaj rozmiar bufora
	mov	bp,	sp

	; sprawdź czy wczytany sektor posiada sygnaturę sektora rozruchowego Omega
	mov	di,	word [si + STRUCTURE_STAGE1_PACKET.offset]
	call	.check
	jnc	.stage2	; sektor rozruchowy Omega zlokalizowany!

	; niestety sektor rozruchowy na nośniku jest inny niż oczekiwaliśmy
	; teraz będzie więcej roboty
	; zapewne Omega znajduje się na którejś z partycji, nie wiemy na której...

	; pobierzmy adresy wszystkich 4 partycji z tablicy
	push	dword [di + STRUCTURE_MBR.table + STRUCTURE_MBR_PARTITION.lba]
	push	dword [di + STRUCTURE_MBR.table + STRUCTURE_MBR_PARTITION.SIZE + STRUCTURE_MBR_PARTITION.lba]
	push	dword [di + STRUCTURE_MBR.table + STRUCTURE_MBR_PARTITION.SIZE * 0x02 + STRUCTURE_MBR_PARTITION.lba]
	push	dword [di + STRUCTURE_MBR.table + STRUCTURE_MBR_PARTITION.SIZE * 0x03 + STRUCTURE_MBR_PARTITION.lba]

.loop:
	; koniec listy partycji?
	cmp	bp,	sp
	je	.not_found

	; pobierz sektor rozruchowy jednej z partycji
	pop	dword [si + STRUCTURE_STAGE1_PACKET.lba]
	cmp	dword [si + STRUCTURE_STAGE1_PACKET.lba],	VARIABLE_EMPTY
	je	.loop	; nie, sprawdź następną partycję

	; wczytaj sektor rozruchowy partycji
	mov	ah,	0x42
	int	0x13

	; operacja wczytania danych przebiegła pomyślnie?
	jc	.read_error

	; sprawdź czy wczytany sektor posiada sygnaturę sektora rozruchowego Omega
	call	.check
	jc	.loop	; nie, przeszukaj pozostałe partycje

.stage2:
	; usuń zmienne lokalne z bufora
	mov	sp,	bp

	; pozostało nam już tylko wczytanie dalszej części programu rozruchowego Omega

	; oblicz rozmiar programu rozruchowego
	mov	ecx,	end
	sub	ecx,	include_stage2
	; zamień rozmiar na ilość sektorów
	shr	ecx,	VARIABLE_DIVIDE_BY_512

	; aktualizuj pakiet o rozmiar danych w sektorach do odczytania
	mov	word [si + STRUCTURE_STAGE1_PACKET.count],	cx

	; program rozruchowy znajduje się za sektorem rozruchowym
	inc	dword [si + STRUCTURE_STAGE1_PACKET.lba]

	; załaduj program rozruchowy do pamięci fizycznej
	mov	ah,	0x42
	int	0x13

	; operacja wczytania danych przebiegła pomyślnie?
	jc	.read_error

	; posprzątaj po sobie
	xor	eax,	eax
	xor	ebx,	ebx
	xor	ecx,	ecx
	xor	edx,	edx
	xor	ebp,	ebp
	xor	esi,	esi
	xor	edi,	edi

	; skocz do załadowanego programu rozruchowego
	jmp	VARIABLE_EMPTY:VARIABLE_STAGE2_ADDRESS

.check:
	; UWAGA, wykonuję tu pewien trik!
	; kto wie jaki? :> i potrafi wyjaśnić ]:>

	; sprawdź sygnaturę
	cmp	dword [di + .check - VARIABLE_STAGE1_ADDRESS + 0x06],	VARIABLE_STAGE1_BOOTSECTOR_OMEGA_MAGIC

	; powrót z procedury
	ret

.bios_not_supported:
	; wyświetl informacje o braku możliwości załadowania drugiej części programu rozruchowego
	mov	si,	text_error_bios_not_supported
	call	print_16bit

	; zatrzymaj dalsze wykonywanie kodu -----------------------------------!
	jmp	$

.read_error:
	; wystąpił błąd podczas wczytywania pliku stage2
	mov	si,	text_error_read
	call	print_16bit

	; pozostaw w rejestrze EAX sam kod błedu
	movzx	eax,	ah
	call	print_number_16bit

	; zatrzymaj dalsze wykonywanie kodu -----------------------------------!
	jmp	$	

.not_found:
	; nie znaleziono programu rozruchowego Omega, wyświetl błąd
	mov	si,	text_not_found
	call	print_16bit

	; zatrzymaj dalsze wykonywanie kodu -----------------------------------!
	jmp	$

; niezbędne procedury do informowania o ewentualnych błędach podczas działania sektora rozruchowego
%include	"bootloader/library/print_16bit.asm"
%include	"bootloader/library/print_number_16bit.asm"

; pakiet danych wykorzystywany przez procedurę rozszerzonego odczytu danych z nośnika
; procedura 0x42, przerwania 0x13 BIOSu
variable_stage1_packet_table:
	db	0x10	; rozmiar struktury
	db	VARIABLE_EMPTY	; zarezerwowane
	dw	0x0001	; ilość sektorów do odczytania
	; gdzie zapisać odczytane dane
	dw	VARIABLE_STAGE2_ADDRESS
	dw	VARIABLE_EMPTY	; segment
	; bezwzględny (LBA, liczony od zera) numer sektora do odczytu
	dq	VARIABLE_EMPTY

; wczytaj lokalizacje sektora rozruchowego
%push
	%defstr		%$system_locale		VARIABLE_SYSTEM_LOCALE
	%defstr		%$process_name		VARIABLE_PROGRAM_NAME
	%strcat		%$include_program_locale,	"bootloader/", %$process_name, "/locale/", %$system_locale, ".asm"
	%include	%$include_program_locale
%pop

; BRAK TABLICY PARTYCJI

; uzupełniamy sektor rozruchowy do końca
times	510 - ( $ - $$ )	db	VARIABLE_EMPTY
				dw	VARIABLE_STAGE1_BOOTSECTOR_MAGIC	; znacznik sektora rozruchowego

include_stage2:	incbin	"build/stage2.bin"	; dołącz program rozruchowy

; wyrównaj cały kod do pełnego sektora
align	VARIABLE_SECTOR_SIZE_DEFAULT

; koniec
end:
