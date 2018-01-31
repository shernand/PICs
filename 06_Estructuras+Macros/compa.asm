;------------------------------------------------------------------------------
;	  Ejemplos de Evaluaci�n de Condiciones
; Esta parte es relevante para compender el dise�o de las estructuras que 
; modifican el flujo de control de ejecuci�n de una aplicaci�n.
; 
; Las principales estructuras son: 
; "If - Then - Else"
; "Do - While"
; "Do - Until"
; "For - �ndice, Hasta, Actualizaci�n"
; "Switch - Case - Else case" (� "Select - Case - Else Case")
; En esta pr�ctica se presentan varias alternativas para resolver lo anterior.
; STATUS = IRP - RP1 - RP0 - T0  - PD  - Z  - DC  - C
;==============================================================================
;-----[ AJUSTES ]-----
  LIST 	P = PIC16F877			; Identificaci�n del uC en donde se ensamblar�.
  #INCLUDE 	P16F877.INC		; Se usar�n las variables de Microchip
  RADIX			HEX						; La base num�rica es Hexadecimal por omisi�n
;==============================================================================
;-----[ MACROS que se van a ensayar y Ya Est�n Construidos ]-----
	#INCLUDE "sfhm1.mac"    ; Aqu� estar�n los MACROS a ensayarse.
;==============================================================================
;-----[ MACROS que se van a Construir y para Experimentar ]-----
;-----[ Macro "SaltaSiIgual" ]-----
; Compara el valor de un "Registro" (localidad de una FSR) con una "Constante". 
; 	Si: "Registro" = Constante  -> Saltar� a la direcci�n indicada por "Salto",
;       													 La Bandera "Z" se habr� puesto a "1"
;   Si  "Registro" =! Constante -> No salta, contin�a la ejecuci�n con la 
;																	 siguiente instrucci�n.
;																	 La Bandera "Z" se habr� puesto a "0"
;-----------------------------------------------------------------------------
SaltaSiIgual	MACRO	Registro, Constante, Salto
	movlw	Constante		; Se emplea la resta para la comparaci�n.
	subwf	Registro,W	; (W)=(Registro) - Constante
	btfsc	STATUS,Z		; �Z=0?, �(W) distinto  a 0?, �(Registro) != Constante?
	goto	Salto				; Ha resultado que (Registro)=Constante ("Z" = 1)
	ENDM
;-----
	; Alias para el MACRO anterior:
	#DEFINE	JumpIfEqual SaltaSiIgual
	#DEFINE	JpEq SaltaSiIgual
;-----------------------------------------------------------------------------
;-----[ Macro Load ]-----
; Carga un valor en una variables
Load	MACRO	Var,Valor
	movlw	Valor	; Toma el valor de la literal
	movwf	Var  	; Trasl�dalo a la FSR, puede ser un Puerto, Variable, Etc.
	ENDM
	; Alias para el MACRO anterior:
	#DEFINE	Carga Load
;-----------------------------------------------------------------------------
;-----[ Variables, Apuntadores, Contadores y Otras Cosas ]-----
;
; La zona de memoria disponible para el usuario es de 0x20 - 0x7F 
; en el BANCO "0". Recuerde que de la localida 0x70 a la 0x7F se crea un
; "espejo" en relaci�n al BANCO "1", BANCO "2" y BANCO "3".
;-->
; �Cu�les son las localidades absolutas de las "localidades espejo" en los
; Bancos 1, 2, y 3?
;<--

	CBLOCK	0x20  ; Zona principal de Variables. Banco "0"
		Reg1				; Registro No. 1
		Reg2				; Registro No. 2
		Reg3				; Registro No. 3
		
		VarX
		VarY
		VarZ
		
		Estado      ; Identifica el estado en que se encuentra la Aplicaci�n.
		Concluye		; �Se Termin� la Aplicaci�n?
		Otra
	ENDC
;==============================================================================
	
	ORG	0x00

OK				EQU		0x00	; Todo Bien
Inicio		EQU		0x33	; Se INICI� la aplicaci�n.	
PasoThen	EQU		0x00	; Valor para cuando pasa por la opci�n THEN.
PasoElse 	EQU   0xFF  ; Valor para cuando pasa por la opci�n ELSE.
LlegoFin	EQU   0xAA  ; Se termin� el CICLO.
Proceso		EQU   0x55  ; Est� en etapa de PROCESAMIENTO.

K0    		EQU   .0		; Valores para pruebas
K10    		EQU   .10
K20   		EQU   .20
K50				EQU		.50

	goto		Evaluar
	
Evaluar:

;--------------------------
; Prueba para Reg1 == Reg2
;--------------------------
	Load	Estado, Inicio		; ESTADO =  0x33
	Load	Concluye, Inicio	; CONCLUYE = 0x33
	
	Load  Reg1, 0x00			; Valores inciales para una prueba
	Load	Reg2, 0x03			;
	
;-----[ ENSAYO Reg1 == Reg2 ]-----	
	movf	Reg1, W
	subwf	Reg2
	btfsc	STATUS, Z
	goto	ZonaThen
ZonaElse:
	Load	Estado, PasoElse
	goto	FinAeqB

ZonaThen:
	Load	Estado, PasoThen	

FinAeqB:
	Load	Concluye, OK
	
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=	
	sleep
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	END