;------------------------------------------------------------------------------
;	Demo_LCD.asm
; Prueba del funcionamiento de la LCD en PORTB [Para tarjeta dt106]
; NOTAS: Para la tarjeta dt106, Se usarán 
;   PORTB<4:7> para LCD<4:7>
;   PORTB<1> para LCD<RS>, PORTB<2> para LCD<R/W> y PORTB<3> para LCD<E>
;------------------------------------------------------------------------------
	
;-----[ Tipo de uC y  Librería ]-----
	LIST 		P = PIC16F877A			;
	INCLUDE <P16F877A.INC>			; Etiquetas de registros, constantes del uC
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
;-----[ MACROS ]-----
	#INCLUDE "SelBank.mac"			; MACRO para la mejor selección de BANCOS.
	#INCLUDE "Macros_LCD.mac"
	
	IFNDEF LCD_4Bits_PORTB.h
		#INCLUDE "LCD_4Bits_PORTB.h"
	ENDIF
	
;-----[ Variables ]-----

	CBLOCK		0x20		; Omitir el "0x20" para el manejo de estas subrutinas.
		Var							; Variable para sacar información hacia la LCD.
		Point						; Apuntador para Tablas.
		Select					; Copia del bit asociado con RS en la LCD.
		OutCod					; Variable Temporal para el código de salida.
		LCD_Dato
		LCD_GuardaDato
		LCD_GuardaTRISB
		LCD_Auxiliar1
		LCD_Auxiliar2
	ENDC
	
;-----[ CONSTANTES ]----- 
;------------------------------------------------------------------------------
;-----[ INICIO ]----- 
 
	ORG		0x00				; Inicio del código [Para Ensayos y Pruebas]
	
	goto	Ensayo			; Salto al programa principal [En PRUEBA]  
	
	;goto  Otra_Prueba ; Otro ensayo
;------------------------------------------------------------------------------ 
;	Tablas de caracteres a enviar, deberá estar en Programa Principal. 
Line1:	
	addwf	PCL,F							; Modifica el Contador del Programa [PC]
	DT "0123456789012345", 0x00
Line2:
	addwf	PCL,F							; Modifica el Contador del Programa [PC]
	DT "abcdefghijklmnop", 0x00
	 
; Envío de un mensaje fijo a la LCD [Estará en el Programa Principal]
OutMes:
	clrf			Point					; Reinicio del Apuntador de la Tabla
	bsf				Select,Pin_RS	; Selección del MODO de DATOS; RS <- "1" 
Mess1:
	movf			Point,W				; Carga el dato apuntado... 
	call			Line1					; Obtén el código ASCII apuntado en la tabla 
	call			LCD_Char			; ... Envíalo a la LCD 
	incf			Point,F				; Apunta al próximo caracter 
	movf			Point,W				; y carga el apuntador
	sublw			D'16'					; Verifica si ya se enviaron todos los caracteres 
	btfss			STATUS,Z			; ... concluye si ya se enviaron 16
	goto			Mess1					; Continuúa...

	LCD_GoTo  0,1						; Pasa a la columna "0", Línea "1"
	clrf			Point					; Reinicia el Apuntador de la Tabla. 
Mess2:
	movf			Point,W				; Carga el dato apuntado... 
	call			Line2					; Obtén el código ASCII apuntado en la tabla 
	bsf				Select,Pin_RS	; Select command mode 
	call			LCD_Char			; ... Envíalo a la LCD  
	incf			Point,F				; Apunta al próximo caracter 
	movf			Point,W				; y carga el apuntador 
	sublw			D'16'					; Verifica si ya se enviaron todos los caracteres 
	btfss			STATUS,Z			; ... concluye si ya se enviaron 16
	goto			Mess2					; Continuúa...
	
	return									; Listo
	
;-----[ Programa Principal ]-----
 
Ensayo:	

  LCD_Init      ; ESTE ES el MACRO que se usará
  call T1S      ; Retardo de tiempo
  call T1S
  call T1S
  
	call	OutMes  ; Muestra los letreros
	call T1S      ; Espera un tiempo...
	call T1S
	
	LCD_Off       ; Apaga la pantalla
	call T1S      ; Retardo de tiempo
	
	LCD_On        ; Enciende la pantalla
	call T1S      ; Retardo de tiempo
	
	LCD_Cursor E_LCD_CURSOR_ON_BLINK	; Cursor parpadeando 
	LCD_GoTo 9,1  ; en esta posición 
	
	goto $        ; Nos esperamos en este punto.

Otra_Prueba:

  LCD_Init      ; ESTE ES el MACRO que se usará
  call T1S      ; Retardo de tiempo
	
	LCD_Off
	call T1S
	
	LCD_Home
	LCD_On
	LCD_Cursor E_LCD_CURSOR_ON_BLINK	; Cursor parpadeando 
	
	call T1S
	LCD_Cursor_Right
	call T1S
	LCD_Cursor_Right
	call T1S
	LCD_Cursor_Right
	call T1S
	LCD_Cursor_Right
	
	call T1S
	call T1S
	
	LCD_Cursor_Left
	call T1S
	LCD_Cursor_Left
	call T1S
	
	LCD_Scroll_Right
	call T1S
	LCD_Scroll_Right
	call T1S
	LCD_Scroll_Left
	call T1S
	
	LCD_Cursor E_LCD_CURSOR_OFF
	LCD_GoTo 6,1
	bsf				Select,Pin_RS	; Selección del MODO de DATOS; RS <- "1" 
	movlw 'S'
	call  LCD_Char
	                  ; Inprime un letrero en lugar de una letra...
	                  ; Realiza una SUBRUTINA GENÉRICA para imprimir letreros
	
	
	
Ciclo:
	goto Ciclo
;------------------------------------------------------------------------------
;-----[ Subrutinas ]-----
	#INCLUDE "LCD_4Bits_PORTB.inc"	; Manejador de la LCD.
  #INCLUDE "Tiempo.inc"						; Retardos y temporizados.
;------------------------------------------------------------------------------  
	END															;
