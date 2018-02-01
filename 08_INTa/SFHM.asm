;--------------------------------------------------------------------------------------------------
;-----[ AJUSTES ]-----
;--------------------------------------------------------------------------------------------------
	LIST			P = PIC16F877	; Identificación del uC sobre el cual se ensamblará.
	#INCLUDE <P16F877.INC>	; Etiquetas de registros, constantes del uC
				
	RADIX			DEC						; La base numérica por omisión es Decimal
	VARIABLE	SFHM=57				; Versión, para pruebas
	ERRORLEVEL	-302				; Quitar las advertencias de cambios de bancos
; Fusibles del uC 
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _WRT_ENABLE_ON & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
;--------------------------------------------------------------------------------------------------
;-----[ MACROS ]-----
	#INCLUDE "SelBanco.mac"				; Macro para la selección de BANCOS.
	#INCLUDE "Macros_LCD.mac"			; Macros para el manejo de la LCD
	#INCLUDE "Vars.mac"						; Macros para la administración de Variables.
	
	; Inicio de parámetros para ZONAS de MEMORIA y APUNTADORES para administrar variables. 
	IniVarsComunes
	IniVarsBanco0
	IniVarsBanco1
	IniVarsBanco2
	IniVarsBanco3
	
	; Para ajustar las constantes de RECURSOS que se emplean en la aplicación.
	IFNDEF LCD_4Bits_PORTB.h
		#INCLUDE "LCD_4Bits_PORTB.h"
	ENDIF
;--------------------------------------------------------------------------------------------------	
;-----[ ETIQUETAS ]-----
;--------------------------------------------------------------------------------------------------
; === IDENTIFICADORES GENÉRICOS ===
	CONSTANT OK = 0x00					; Identifica que "Todo está bien".
	CONSTANT TIPO_uC = 0x00			; Tipo de uControlador:
															; 0x00 = PIC16F877	0x01 = PIC16F877A
															; 0x02 = PIC18F452	0x03 = Otro
	CONSTANT RECURSOS_uC = 0x00	; Características del uC (Recursos, Memorias, Comunicaciones, etc)
															; 0x00 = Básico (PIC)		0x01= Básico (ATMEL)
															; 0x02 = Básico (Motorola)	0x03 = Básico (Otro)
															; 0x04 = Inalámbrico (RF)	0x05 = Inalámbrico (IrDa)
	CONSTANT VERSION = .100			; Versión del software de soporte en el uC, referida
															;  como un valor de 1 a 255 (por ejemplo, V0.01 a V2.55).													
;--------------------------------------------------------------------------------------------------
; === IDENTIFICADORES de y para esta APLICACIÓN ===
	CONSTANT MAESTRO =0x00			; Número del NODO Maestro, habitualmente una PC (Central).
	CONSTANT MI_NODO =0x01			; Número del nodo particular de este uC (se cambia para cada uC)
;--------------------------------------------------------------------------------------------------	
; === COMANDOS ===
;--------------------------------------------------------------------------------------------------
;-----[	VECTORES del PROGRAMA ]----- 
;--------------------------------------------------------------------------------------------------
	ORG   0x000      			; Vector de RESET del uC.
	movlw	HIGH Principal	; Parte alta de la dirección de Inicio.
	movwf	PCLATH					; Ajusta a la página adecuada
	goto	Principal				; Salta a la APLICACIÓN...
;--------------------------------------------------------------------------------------------------
;	VECTORES de inicio de Atención a Interrupciones. 
;--------------------------------------------------------------------------------------------------
	ORG   0x004       		; Vector de ATENCIÓN a INTERRUPCIONES del uC.
	movlw	HIGH ISR				; Parte alta de la dirección de Inicio.
	movwf	PCLATH					; Ajusta a la página adecuada
	goto	ISR							; Salta a la Atención a las INTERRUOCIONES...
;--------------------------------------------------------------------------------------------------
;-----[ VARIABLES ]-----

; --> ZONA COMÚN, aquí se alojan variables accesibles desde cualquier BANCO <--
	AgregarVarComun Temp_W, 1						; Variable TEMPORAL para "W"
	AgregarVarComun	Temp_STATUS, 1			; Variable TEMPORAL para "STATUS"	
	AgregarVarComun	Temp0, 1						; Otras variables Temporales
	AgregarVarComun	Temp1, 1
	AgregarVarComun	Temp2, 1
	AgregarVarComun	Temp3, 1
	AgregarVarComun	Temp4, 1

; --> VARIABLES que estarán en el BANCO 0 <--
	AgregarVarBanco0	Var,1
	AgregarVarBanco0	Point,1
	AgregarVarBanco0	Select,1
	AgregarVarBanco0	OutCod,1
	AgregarVarBanco0	LCD_Dato,1
	AgregarVarBanco0	LCD_GuardaDato,1
	AgregarVarBanco0	LCD_Auxiliar1,1
	AgregarVarBanco0	LCD_Auxiliar2,1

; --> VARIABLES que estarán en el BANCO 1 <--
	AgregarVarBanco1	Var_1,1

; --> VARIABLES que estarán en el BANCO 2 <--
	AgregarVarBanco1	Var_2,1

; --> VARIABLES que estarán en el BANCO 3 <--
	AgregarVarBanco1	Var_3,1

;--------------------------------------------------------------------------------------------------
;-----[ SUBRUTINAS que Manejan RECURSOS ]-----
  #INCLUDE	"Teclado.INC"					; Subrutinas de control del teclado.
	#INCLUDE  "Bin_BCD.INC"					; Conversión a código BCD
	#INCLUDE 	"LCD_4Bits_PORTB.inc"	; Manejador de la LCD.
  #INCLUDE 	"Tiempo.inc"					; Retardos y Temporizados.
;--------------------------------------------------------------------------------------------------  
	;END														; Aquí ¡NO se USA el fin de archivo, esto continúa...!
;-------------------------------------------------------------------------------------------------- 

