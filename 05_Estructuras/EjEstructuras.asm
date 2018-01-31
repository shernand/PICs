;==============================================================================
; En este archivo se encuentran ejemplos para implementar
; estructuras básicas en lenguaje ensamblador.
;==============================================================================
;-----[ AJUSTES ]-----
  LIST 	P = PIC16F877			; Identificación del uC en donde se ensamblará.
  #INCLUDE 	P16f877.INC		; Se usarán las variables de Microchip
  RADIX			Hex						; La base numérica es Hexadecimal por omisión
  
;==============================================================================
;
; Los MACROS son empleados para ampliar la potencia del lenguaje ensamblador.
; Permiten crear alias de instrucciones e incluso construir instrucciones
; a patir de secuencias de órdenes en lenguaje ensamblador.
; A diferencia de las subrutinas (invocadas por la instrucción "call"),
; cada vez que se ejecuta un MACRO se sustituye el segmento de código definido
; con los valores asignados a los parámetros que tuviera.
;------------------------------------------------------------------------------
;-----[ MACROS que se emplearán ]-----
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
;-----[ CÓDIGO que se ensaya ]-----

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
                        ; Inicio de la la zona en donde está...
  nop										; ... el proceso que se repite.
  nop										; 
                        ;
;-----
                        ; Verificación de que se llegó a la condición
  decfsz  Contador, F		; ¿El Contador está en Cero?
	goto	  Continua			;... Si NO es IGUAL a CERO, continúa.
;-----

Terminó:
	movlw	Ok							; Indica que terminó bien.
	movwf	Aviso						;
			
	sleep

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	END

