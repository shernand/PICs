; 	...Programa en progreso...
; 	En este m�dulo se proponen los ensayos del LCD, el teclado hexadecimal matrizado y otros 
; perif�ricos.
; 	Los elementos que se ensayan en esta aplicaci�n son �tiles para emplearse en el desarrollo
; de proyectos o laboratorios m�s elaborados.

;**************************************************************************************************
;	Esta secci�n es obligatoria para cuando usamos un PIC16F877A.

	LIST P = PIC16F877A			; Identificaci�n del uC en donde se ensamblar�.
	#INCLUDE P16F877A.INC		; Se usar�n las variables de Microchip

; Directiva para configurar los "fusibles" del uC. 
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
;**************************************************************************************************
;-----[VARIABLES]-----
; La direcci�n inical de la zona de memoria principal en el Bloque "0" es 0x20
	
	CBLOCK 0x20				; Para iniciar zona de memoria en PIC16F877A
		Temp0						; Variables temporales que se emplear�n en algunas subrutinas.
		Temp1						; Se equiparan a ellas las variables locales para cada segmento.
		Temp2						;
		Temp3						; 	Por ejemplo:
		Temp4						;VarLocal		EQU		Temp0
		Temp5						;OtraVariable	EQU		Temp2 
	ENDC
										; A partir de esta localidad de memoria (0x26) se van agregando variables
;==================================================================================================	
;-----[V E C T O R E S]-----
	ORG 0x00					; Inicio de ejecuci�n de la aplicaci�n.
	movlw	HIGH Inicio	; Parte alta de la direcci�n de Inicio.
	movwf	PCLATH			; Ajusta a la p�gina adecuada
	goto 	Inicio
;	goto Fin
;		
	ORG 0x04					; Atenci�n a Interrupciones.
	movlw	HIGH ISR		; Parte alta de la direcci�n de ISR.
	movwf	PCLATH			; Ajusta a la p�gina adecuada
	goto 	ISR

;==================================================================================================	
;-----[A T E N C I � N     A     I N T E R R U P C I O N E S]-----
ISR:
	retfie
	goto	$

;==================================================================================================	
;-----[Z O N A   D E   M E N S A J E S]-----
;
;	Debe quedar en una p�gina ALTA, para que no se salgan de la misma.
; 	Debe haber alg�n mecanismo que permita determinar cu�ndo se excedi� la zona de memoria 
; reservada para los mensajes. Se debe calcular que los mensajes no exceden de cierta direcci�n.
;
;	Es obligatorio seleccionar la p�gina adecuada antes de ejecutar estas subrutinas.
;
;	ORG	0X1000										; Se posiciona en la Tercera P�gina.

Mensajes:
	addwf	PCL,F
Mensaje0:
	DT "----- SFHM -----", 0x00		; Mensaje terminado en 0x00.
Mensaje1:
	DT "-- Bienvenidos -", 0x00		; Mensaje de Bienvenida.
Mensaje2:
	DT "                Mensaje en Movimiento                ", 0x00
FinMensajes

;==================================================================================================	
;-----[A P L I C A C I � N     Q U E     S E    E N S A Y A]-----
Inicio:
	call	LCD_Inicializa
	movlw	'S'
	call	LCD_Caracter
	movlw	'F'
	call	LCD_Caracter
	movlw	'H'
	call	LCD_Caracter
	movlw	'M'
	call	LCD_Caracter

	call	Teclado_Inicializa				; Configura las l�neas del teclado.

Principal1:

;	call	Teclado_LeeOrdenTecla			; Lee el teclado.
	call	Teclado_LeeHex						; Lectura seg�n c�digo

	btfss	STATUS,C									; �Pulsa alguna tecla?, �C=1?
	goto	Fin1											; No, por tanto sale.

	call	LCD_Nibble								; Lo pasa a BCD.
;	call	LCD_ByteCompleto					; Visualiza en pantalla.

	call	Teclado_EsperaDejePulsar	; No sale de aqu� hasta que levante el dedo.
Fin1:
	goto	Principal1

;--> ENSAYOS

	call	Teclado_Inicializa				; Configura las l�neas del teclado.
Principal:

	call	Teclado_LeeOrdenTecla			; Lee el teclado.
;	call	Teclado_LeeHex						; Lectura seg�n c�digo

	btfss	STATUS,C									; �Pulsa alguna tecla?, �C=1?
	goto	Fin												; No, por tanto sale.

	call	LCD_Nibble								; Lo pasa a BCD.
;	call	LCD_ByteCompleto					; Visualiza en pantalla.

	call	Teclado_EsperaDejePulsar 	; No sale hasta que levante el dedo.
	
	goto	$

Fin:
  call	LCD_Inicializa
	call	R_1S											; espera un tiempo
	call	LCD_Borra
	
	movlw	Mensaje0									; Carga la posici�n del mensaje.
	call	LCD_Mensaje								; Visualiza el mensaje.
	call	LCD_Linea2
	movlw	Mensaje1
	call	LCD_Mensaje

	call	R_1S

	movlw	Mensaje2
	call	LCD_MensajeMovimiento

	goto	Fin													; Aqu� te quedas...

	goto	Principal

;<-- ENSAYOS
	sleep														; Entra en modo de bajo consumo.

	#INCLUDE "Teclado.INC"					; Manejador de Teclado 4X4
	#INCLUDE "BIN_BCD.INC"					; Conversor de formato.
	#INCLUDE "LCD_4BIT.asm"					; Manejador del m�dulo LCD.
	#INCLUDE "LCD_MENS.INC"					; Impresi�n de mensajes completos
	#INCLUDE "RETARDOS.asm"					; Subrutinas de retardo.
;==================================================================================================	
	END															; Fin del programa.
