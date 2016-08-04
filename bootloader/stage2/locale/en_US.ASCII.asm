; ok
text_init		db	"Omega loader init.", VARIABLE_ASCII_CODE_RETURN
text_pic		db	"Devices, disabled.", VARIABLE_ASCII_CODE_RETURN
text_cpu		db	"Processor type, compatible.", VARIABLE_ASCII_CODE_RETURN
text_a20		db	"Gate A20, unlocked.", VARIABLE_ASCII_CODE_RETURN

; fail
text_error_no_cpu	db	"No 64 Bit instructions available on this CPU!", VARIABLE_ASCII_CODE_TERMINATOR
text_no_a20		db	"Gate A20 unlock, fail.", VARIABLE_ASCII_CODE_TERMINATOR
