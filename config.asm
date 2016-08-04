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

;===============================================================================
; GLOBAL Variables                                                             =
;===============================================================================

%define	VARIABLE_SYSTEM_VERSION			"0.671"
%define	VARIABLE_SYSTEM_LOCALE			en_US.ASCII

VARIABLE_SECTOR_SIZE_DEFAULT			equ	512	; Bajtów

VARIABLE_EMPTY					equ	0x00

VARIABLE_TRUE					equ	0x01
VARIABLE_FALSE					equ	0x00

VARIABLE_ASCII_CODE_TERMINATOR			equ	0x00
VARIABLE_ASCII_CODE_ENTER			equ	0x0D
VARIABLE_ASCII_CODE_NEWLINE			equ	0x0A
VARIABLE_ASCII_CODE_BACKSPACE			equ	0x08
VARIABLE_ASCII_CODE_TAB				equ	0x09
VARIABLE_ASCII_CODE_ESCAPE			equ	0x1B
VARIABLE_ASCII_CODE_SPACE			equ	0x20
VARIABLE_ASCII_CODE_NUMBER			equ	0x30
VARIABLE_ASCII_CODE_TILDE			equ	0x7E
VARIABLE_ASCII_CODE_DELETE			equ	0x7F

%define	VARIABLE_ASCII_CODE_RETURN		VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, VARIABLE_ASCII_CODE_TERMINATOR

VARIABLE_BIT_0					equ	0

VARIABLE_QWORD_SIZE				equ	8
VARIABLE_DWORD_SIZE				equ	4
VARIABLE_DWORD_MASK				equ	0xFFFFFFFF
VARIABLE_WORD_SIZE				equ	2
VARIABLE_WORD_MASK				equ	0xFFFF
VARIABLE_BYTE_SIZE				equ	1
VARIABLE_BYTE_MASK				equ	0xFF

VARIABLE_QWORD_HIGH				equ	0x04
VARIABLE_DWORD_HIGH				equ	0x02
VARIABLE_WORD_HIGH				equ	0x01

VARIABLE_QWORD_SIGN				equ	63
VARIABLE_DWORD_SIGN				equ	31
VARIABLE_WORD_SIGN				equ	15
VARIABLE_BYTE_SIGN				equ	7

VARIABLE_DIVIDE_BY_2				equ	1
VARIABLE_DIVIDE_BY_4				equ	2
VARIABLE_DIVIDE_BY_8				equ	3
VARIABLE_DIVIDE_BY_16				equ	4
VARIABLE_DIVIDE_BY_32				equ	5
VARIABLE_DIVIDE_BY_64				equ	6
VARIABLE_DIVIDE_BY_128				equ	7
VARIABLE_DIVIDE_BY_256				equ	8
VARIABLE_DIVIDE_BY_512				equ	9
VARIABLE_DIVIDE_BY_1024				equ	10
VARIABLE_DIVIDE_BY_2048				equ	11
VARIABLE_DIVIDE_BY_4096				equ	12

VARIABLE_MULTIPLE_BY_2				equ	1
VARIABLE_MULTIPLE_BY_4				equ	2
VARIABLE_MULTIPLE_BY_8				equ	3
VARIABLE_MULTIPLE_BY_512			equ	9
VARIABLE_MULTIPLE_BY_4096			equ	12

VARIABLE_SHIFT_BY_2				equ	2
VARIABLE_SHIFT_BY_4				equ	4

VARIABLE_MOVE_HIGH_EAX_TO_AX			equ	16
VARIABLE_MOVE_HIGH_RAX_TO_EAX			equ	32

;===============================================================================
; STAGE1&2 Variables                                                           =
;===============================================================================
VARIABLE_STAGE1_ADDRESS				equ	0x7C00
VARIABLE_STAGE1_BOOTSECTOR_OMEGA_MAGIC		equ	0x544F4F42	; "BOOT"
VARIABLE_STAGE1_BOOTSECTOR_MAGIC		equ	0xAA55

struc	STRUCTURE_STAGE1_PACKET
	.size		resb	1
	.reserved	resb	1
	.count		resb	2
	.offset		resb	2
	.segment	resb	2
	.lba		resb	8
endstruc

struc	STRUCTURE_MBR
	.code		resb	440
	.id		resb	6
	.table		resb	64	; 4 partycje postawowe
	.signature	resb	2
endstruc

struc	STRUCTURE_MBR_PARTITION
	.active		resb	1	; na partycji znajduje się sektor rozruchowy/system operacyjny?
	.chs_start	resb	3	; cylinder/ścieżka, głowica, sektor początku partycji
	.type		resb	1	; typ partycji (mało ważne, sterownik powinien sam rozpoznać czy to jego)
	.chs_stop	resb	3	; koniec partycji
	.lba		resb	4	; początek partycji wg. pozycji sektora w LBA
	.size		resb	4	; rozmiar partycji w sektorach
	.SIZE		resb	1
endstruc

VARIABLE_STAGE2_ADDRESS				equ	0x8000
VARIABLE_STAGE2_MEMORY_MAP			equ	0x1000
