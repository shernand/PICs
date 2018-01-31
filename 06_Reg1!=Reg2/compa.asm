;------------------------------------------------------------------------------
;	  Ejemplos de Evaluación de Condiciones
; Esta parte es relevante para compender el diseño de las estructuras que 
; modifican el flujo de control de ejecución de una aplicación.
; 
; Las principales estructuras son: 
; "If - Then - Else"
; "Do - While"
; "Do - Until"
; "For - Índice, Hasta, Actualización"
; "Switch - Case - Else case" (ó "Select - Case - Else Case")
; En esta práctica se presentan varias alternativas para resolver lo anterior.
; STATUS = IRP - RP1 - RP0 - T0  - PD  - Z  - DC  - C
;==============================================================================
;-----[ AJUSTES ]-----
  LIST 	P = PIC16F877			; Identificación del uC en donde se ensamblará.
  #INCLUDE 	P16F877.INC		; Se usarán las variables de Microchip
  RADIX			HEX						; La base numérica es Hexadecimal por omisión
;==============================================================================
;-----[ MACROS que se van a Construir y para Experimentar ]-----
;-----[ Macro Load ]-----
; Carga un valor en una variables
Load	MACRO	Var,Valor
	movlw	Valor	; Toma el valor de la literal
	movwf	Var  	; Trasládalo a la FSR, puede ser un Puerto, Variable, Etc.
	ENDM
	; Alias para el MACRO anterior:
	#DEFINE	Carga Load
;-----------------------------------------------------------------------------
;-----[ Variables, Apuntadores, Contadores y Otras Cosas ]-----
;
; La zona de memoria disponible para el usuario es de 0x20 - 0x7F 
; en el BANCO "0". Recuerde que de la localida 0x70 a la 0x7F se crea un
; "espejo" en relación al BANCO "1", BANCO "2" y BANCO "3".
;-->
; ¿Cuáles son las localidades absolutas de las "localidades espejo" en los
; Bancos 1, 2, y 3?
;<--

	CBLOCK	0x20  ; Zona principal de Variables. Banco "0"
		Reg1				; Registro No. 1
		Reg2				; Registro No. 2
		Reg3				; Registro No. 3
		
		VarX
		VarY
		VarZ
		
		Estado      ; Identifica el estado en que se encuentra la Aplicación.
		Concluye		; ¿Se Terminó la Aplicación?
		Otra
	ENDC
;==============================================================================
	
	ORG	0x00

OK				EQU		0x00	; Todo Bien
Inicio		EQU		0x33	; Se INICIÓ la aplicación.	
PasoThen	EQU		0x00	; Valor para cuando pasa por la opción THEN.
PasoElse 	EQU   0xFF  ; Valor para cuando pasa por la opción ELSE.
LlegoFin	EQU   0xAA  ; Se terminó el CICLO.
Proceso		EQU   0x55  ; Está en etapa de PROCESAMIENTO.

K0    		EQU   .0		; Valores para pruebas
K10    		EQU   .10
K20   		EQU   .20
K50				EQU		.50

;--------------------------
; Prueba para Reg1 != Reg2
;--------------------------
	Load	Estado, Inicio		; ESTADO =  0x33
	Load	Concluye, Inicio	; CONCLUYE = 0x33
	
	Load  Reg1, .15			; Valores inciales para una prueba
	Load	Reg2, .234			;
	
;-----[ ENSAYO Reg1 != Reg2 ]-----	
	movf	Reg1, W					; Primer parámetro, el contenido de Reg1
	subwf	Reg2						; Comparamos con el contenido del Reg2
	btfss	STATUS, Z				;
	goto	ZonaThen				; Salta a la condición de VERDADERO
ZonaElse:
	Load	Estado, PasoElse	; Zona de FALSO	(Ajusta a 0xFF)
	goto	FinAeqB						; Termina

ZonaThen:
	Load	Estado, PasoThen	; Zona de VERDADERO (Ajusta a 0x00)
													; Termina
FinAeqB:
	Load	Concluye, OK			; Señala que terminó el proceso
	
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=	
	sleep
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	END