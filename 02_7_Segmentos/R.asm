;  Este archivo contiene subrutinas que podrán ser empleadas por otros programas.
;  Para poder usar estas subrutinas se debe incluir este archivo en el programa que
; les invoque, se emplea la directiva INCLUDE.
;
; Se sugiere que este archivo sea inluido al final del código que se esté ensayando.
;
; Las siguientes rutina generan retardos de 1, 10, 100 y 500 milisegundos.
;
;	D1: 1 milisegundo 			--> (0.0010002 s)
;	D10: 10 milisegundos		--> (0.0100006 s)
;	D100: 100 milisegundos		--> (0.1000004 s)
;	D500: 500 milisegundos		--> (0.5000006 s)
; 	
; Los valores calculados son para Osc = 20.000000 MHz
;------------------------------------------------------------------------------
;	Habrá que dar de alta variables TEMPORALES. Para esto se igualan a
; variables temporales que se hubieran definido GLOBALMENTE.

CntA	EQU		Temp0
CntB	EQU		Temp1
CntC	EQU		Temp2

;------------------------------------------------------------------------------

D1:
		movlw	D'7'
		movwf	CntB

		movlw	D'124'
		movwf	CntA
D1_1:
		decfsz	CntA, f
		goto	D1_1
		decfsz	CntB,1
		goto	D1_1
	
		retlw	0
;------------------------------------------------------------------------------

D10:
		movlw	D'65'
		movwf	CntB

		movlw	D'238'
		movwf	CntA
D10_1:
		decfsz	CntA, f
		goto	D10_1
		decfsz	CntB, f
		goto	D10_1
	
		retlw	0

;------------------------------------------------------------------------------

D100:
		;PIC Time Delay = 0.1000004 s with Osc = 20.000000 MHz
		movlw	D'3'
		movwf	CntC

		movlw	D'140'
		movwf	CntB

		movlw	D'83'
		movwf	CntA
D100_1:
		decfsz	CntA, f
		goto	D100_1
		decfsz	CntB, f
		goto	D100_1
		decfsz	CntC, f
		goto	D100_1
	
		retlw	0

;------------------------------------------------------------------------------


D500:
		movlw	D'13'
		movwf	CntC

		movlw	D'187'
		movwf	CntB

		movlw	D'170'
		movwf	CntA
D500_1:
		decfsz	CntA,1
		goto	D500_1
		decfsz	CntB,1
		goto	D500_1
		decfsz	CntC,1
		goto	D500_1

		retlw	0

;------------------------------------------------------------------------------