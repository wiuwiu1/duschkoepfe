; START: Wait loop, time: 60 ms
; Clock: 12000.0 kHz (12 / MC)
; Used registers: R0, R1
	MOV	R1, #083h
	MOV	R0, #0E3h
	NOP
	DJNZ	R0, $
	DJNZ	R1, $-5
	NOP
; Rest: 0
; END: Wait loop
