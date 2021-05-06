; Var
EIN1 EQU P2
DRUCKSENSOR EQU EIN1.0
WASSERHAHNSENSOR EQU EIN1.1
WASSERVERBRAUCH EQU R0


AJMP init

init:
MOV TMOD, #11H
MOV EIN1, #00H
SETB TR0
AJMP hahncheck

hahncheck:
JNB WASSERHAHNSENSOR, hahncheck
AJMP wasserberechnungstart

wasserberechnungstart:
MOV WASSERVERBRAUCH, #0D 

