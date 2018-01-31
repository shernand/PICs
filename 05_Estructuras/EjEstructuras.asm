;==============================================================================
; En este archivo se encuentran ejemplos para implementar
; estructuras b�sicas en lenguaje ensamblador.
;==============================================================================
;-----[ AJUSTES ]-----
  LIST 	P = PIC16F877			; Identificaci�n del uC en donde se ensamblar�.
  #INCLUDE 	P16f877.INC		; Se usar�n las variables de Microchip
  RADIX			Hex						; La base num�rica es Hexadecimal por omisi�n
  
;==============================================================================
;
; Los MACROS son empleados para ampliar la potencia del lenguaje ensamblador.
; Permiten crear alias de instrucciones e incluso construir instrucciones
; a patir de secuencias de �rdenes en lenguaje ensamblador.
; A diferencia de las subrutinas (invocadas por la instrucci�n "call"),
; cada vez que se ejecuta un MACRO se sustituye el segmento de c�digo definido
; con los valores asignados a los par�metros que tuviera.
;------------------------------------------------------------------------------
;-----[ MACROS que se emplear�n ]-----
Carga	MACRO Localidad, Dato
  movlw	Dato
	movwf	Localidad
ENDM
;==============================================================================

;-----[ ETIQUETAS e IDENTIFICADORES ]-----

Inicio:		EQU		0x00    ;
Final:		EQU		0x10    ; 
Dato1:		EQU		0x12    ; Valor inicial del Dato 1
Dato2:		EQU		0x23    ; Valor inicial del Dato 2
Diez:			EQU		0x0A    ;
Ok:				EQU		0x55    ;

;==============================================================================

;-----[ VARIABLES ]-----
  CBLOCK		0x20		; Incio de la zona para variables GENERALES
	  Contador				; Se aloja en la localidad 0x020
	  Apuntador				; En localida 0x21
	  Var1						; En la 0x22
	  Var2						; En la 0x23
	  Var3						; En la 0x24
	  Aviso						; En la 0x25...
  ENDC
;==============================================================================
;-----[ C�DIGO que se ensaya ]-----

  ORG		0x000
  
  Carga Aviso, 0xAA     ; Para identificar que no se ha llegado al FIN.

  movlw	Dato1
  movwf	Var1

  movlw	Dato2
  movwf	Var2

Estructura1:
;-----
  movlw	Diez						; Valor INICIAL del Contador
	movwf	Contador				; 
	;Carga	Contador, Diez
;-----
Continua:
                        ; Inicio de la la zona en donde est�...
  nop										; ... el proceso que se repite.
  nop										; 
                        ;
;-----
                        ; Verificaci�n de que se lleg� a la condici�n
  decfsz  Contador, F		; �El Contador est� en Cero?
	goto	  Continua			;... Si NO es IGUAL a CERO, contin�a.
;-----

Termin�:
	movlw	Ok							; Indica que termin� bien.
	movwf	Aviso						;
			
	sleep

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	END

