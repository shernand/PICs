;------------------------------------------------------------------------------
; CONSTANTES EMPLEADAS en el manejador de la LCD.
;------------------------------------------------------------------------------
;-----[ CONSTANTES para el manejo de la LCD ]-----

	#DEFINE Hileras 4
	;#DEFINE Columnas 16
	#DEFINE Columnas 20
		
; --> Los siguientes son valores para usar PORTB <--
PORT_LCD	EQU	PORTB	; Puerto que maneja al LCD 
TRIS_LCD	EQU	TRISB	; Direcciones del Puerto del LCD

	#DEFINE	RS PORTB,1
	#DEFINE	Pin_RS 1
	#DEFINE	RW PORTB,2
	#DEFINE	E PORTB,3

; --> Los siguientes valores para emplear PORTD <--	
;PORT_LCD	EQU	PORTD	; Puerto 	que maneja al LCD
;TRIS_LCD	EQU	TRISD	; Direcciones del Puerto del LCD

	;#DEFINE	RS PORT_LCD,1
	;#DEFINE	Pin_RS 1
	;#DEFINE	E PORT_LCD,2
	;#DEFINE	RW PORT_LCD,0													
;##############################################################################

#DEFINE LCD_4Bits_PORTB.h