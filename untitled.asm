; Var
INPUT EQU P0 
DRUCKSENSOR EQU INPUT.0
WASSERHAHNSENSOR EQU INPUT.1
WARMWASSERVENTIL EQU INPUT.2
KALTWASSERVENTIL EQU INPUT.3
WARNTON EQU INPUT.4
FANFARE EQU INPUT.5
WASSERZAEHLER EQU P1
SEGMENTWERT EQU P2
SEGMENTZIFFER EQU P3

TIMERWERT EQU R0
WASSERVERBRAUCH EQU R1
WASSERVERBRAUCH2 EQU R2
WASSERVERBRAUCH3 EQU R3
DISPLAYWERT EQU R4

AJMP init

init:
MOV TMOD, #11H
MOV TIMERWERT, #00H
MOV WASSERVERBRAUCH, #00H
MOV WASSERVERBRAUCH2, #00H
MOV WASSERVERBRAUCH3, #00H
MOV DISPLAYWERT, #00H
MOV INPUT, #00H
MOV DPTR, #table 
AJMP startcheck

startcheck:
JNB DRUCKSENSOR, startcheck
JNB WASSERHAHNSENSOR, startcheck
SETB WARMWASSERVENTIL
SETB KALTWASSERVENTIL
AJMP wasserberechnungstart

wasserberechnungstart:
MOV WASSERVERBRAUCH, #0D
MOV TH0, #00H
MOV A, #1D
MOVC A, @A+DPTR
MOV TL0, A
SETB TR0

berechnungsstep:
MOV R0, TH0
CJNE R0, #04H, berechnungsstep
;Timer zurücksetzen
MOV TH0, #00H
MOV A, #11D
MOVC A, @A+DPTR
MOV TL0, A
SETB TR0
;addiere Wassersensor Wert auf Wasserverbrauch 
CLR C
MOV A, WASSERZAEHLER
ADD A, WASSERVERBRAUCH
MOV WASSERVERBRAUCH, A
JC ueberlaufberechnung1
AJMP ausgabe

abbruchbedingungen:
;Wasser max erreicht
CLR C
CJNE R4, #100D, notequal
AJMP wassermax
notequal:
JNC wassermax
;hat dusche verlassen
JNB DRUCKSENSOR, duscheverlassen 
AJMP berechnungsstep

ueberlaufberechnung1:
MOV A, WASSERVERBRAUCH2
CLR C
INC A
MOV WASSERVERBRAUCH2, A
JC ueberlaufberechnung2
AJMP ausgabe

ueberlaufberechnung2:
MOV A, WASSERVERBRAUCH3
CLR C
INC A
MOV WASSERVERBRAUCH3, A
AJMP ausgabe

ausgabe:
;displaywert aus wasservebrauch auf 1 byte kürzen
MOV B, wasserverbrauch2

MOV C, B.2
MOV A.0, C

MOV C, B.3
MOV A.1, C

MOV C, B.4
MOV A.2, C

MOV C, B.5
MOV A.3, C

MOV C, B.6
MOV A.4, C

MOV C, B.7
MOV A.5, C

MOV B, WASSERVERBRAUCH3

MOV C, B.0
MOV A.6, C

MOV C, B.1
MOV A.7, C

MOV DISPLAYWERT, A

;1.(vorderste) Ziffer setzen - immer 0
MOV A, #0D
MOVC A, @A+DPTR
MOV segmentwert, A 
MOV segmentziffer, #0111B
MOV segmentziffer, #1111B

;2. Ziffer setzen
MOV A, DISPLAYWERT
MOV B, #100D
DIV AB
MOVC A, @A+DPTR
MOV segmentwert, A
MOV displaywert, B
MOV segmentziffer, #1011B
MOV segmentziffer, #1111B

;3. Ziffer setzen
MOV A, DISPLAYWERT
MOV B, #10D
DIV AB
MOVC A, @A+DPTR
MOV segmentwert, A
MOV displaywert, B
MOV segmentziffer, #1101B
MOV segmentziffer, #1111B

;4. Ziffer setzen
MOV A, DISPLAYWERT
MOVC A, @A+DPTR
MOV segmentwert, A
MOV segmentziffer, #1110B
MOV segmentziffer, #1111B

AJMP abbruchbedingungen

;Abbruchbedingungen:
duscheVerlassen:
JB WASSERHAHNSENSOR, duscheVerlassenWarnung
SETB FANFARE
CLR FANFARE
AJMP init

duscheVerlassenWarnung:
SETB WARNTON
CLR WARNTON
AJMP init

wasserMax:
SETB WARNTON
CLR WARNTON
CLR warmwasserventil

wasserMaxLoop:
JB drucksensor, wassermaxloop
AJMP init

table:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b
db 100D
db 00011000B

END