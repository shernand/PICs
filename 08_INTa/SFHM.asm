;--------------------------------------------------------------------------------------------------
;-----[ AJUSTES ]-----
;--------------------------------------------------------------------------------------------------
	LIST			P = PIC16F877	; Identificaci�n del uC sobre el cual se ensamblar�.
	#INCLUDE <P16F877.INC>	; Etiquetas de registros, constantes del uC
				
	RADIX			DEC						; La base num�rica por omisi�n es Decimal
	VARIABLE	SFHM=57				; Versi�n, para pruebas
	ERRORLEVEL	-302				; Quitar las advertencias de cambios de bancos
; Fusibles del uC 
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _WRT_ENABLE_ON & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
;--------------------------------------------------------------------------------------------------
;-----[ MACROS ]-----
	#INCLUDE "SelBanco.mac"				; Macro para la selecci�n de BANCOS.
	#INCLUDE "Macros_LCD.mac"			; Macros para el manejo de la LCD
	#INCLUDE "Vars.mac"						; Macros para la administraci�n de Variables.
	
	; Inicio de par�metros para ZONAS de MEMORIA y APUNTADORES para administrar variables. 
	IniVarsComunes
	IniVarsBanco0
	IniVarsBanco1
	IniVarsBanco2
	IniVarsBanco3
	
	; Para ajustar las constantes de RECURSOS que se emplean en la aplicaci�n.
	IFNDEF LCD_4Bits_PORTB.h
		#INCLUDE "LCD_4Bits_PORTB.h"
	ENDIF
;--------------------------------------------------------------------------------------------------	
;-----[ ETIQUETAS ]-----
;--------------------------------------------------------------------------------------------------
; === IDENTIFICADORES GEN�RICOS ===
	CONSTANT OK = 0x00					; Identifica que "Todo est� bien".
	CONSTANT TIPO_uC = 0x00			; Tipo de uControlador:
															; 0x00 = PIC16F877	0x01 = PIC16F877A
															; 0x02 = PIC18F452	0x03 = Otro
	CONSTANT RECURSOS_uC = 0x00	; Caracter�sticas del uC (Recursos, Memorias, Comunicaciones, etc)
															; 0x00 = B�sico (PIC)		0x01= B�sico (ATMEL)
															; 0x02 = B�sico (Motorola)	0x03 = B�sico (Otro)
															; 0x04 = Inal�mbrico (RF)	0x05 = Inal�mbrico (IrDa)
	CONSTANT VERSION = .100			; Versi�n del software de soporte en el uC, referida
															;  como un valor de 1 a 255 (por ejemplo, V0.01 a V2.55).													
;--------------------------------------------------------------------------------------------------
; === IDENTIFICADORES de y para esta APLICACI�N ===
	CONSTANT MAESTRO =0x00			; N�mero del NODO Maestro, habitualmente una PC (Central).
	CONSTANT MI_NODO =0x01			; N�mero del nodo particular de este uC (se cambia para cada uC)
;--------------------------------------------------------------------------------------------------	
; === COMANDOS ===
;--------------------------------------------------------------------------------------------------
;-----[	VECTORES del PROGRAMA ]----- 
;--------------------------------------------------------------------------------------------------
	ORG   0x000      			; Vector de RESET del uC.
	movlw	HIGH Principal	; Parte alta de la direcci�n de Inicio.
	movwf	PCLATH					; Ajusta a la p�gina adecuada
	goto	Principal				; Salta a la APLICACI�N...
;--------------------------------------------------------------------------------------------------
;	VECTORES de inicio de Atenci�n a Interrupciones. 
;--------------------------------------------------------------------------------------------------
	ORG   0x004       		; Vector de ATENCI�N a INTERRUPCIONES del uC.
	movlw	HIGH ISR				; Parte alta de la direcci�n de Inicio.
	movwf	PCLATH					; Ajusta a la p�gina adecuada
	goto	ISR							; Salta a la Atenci�n a las INTERRUOCIONES...
;--------------------------------------------------------------------------------------------------
;-----[ VARIABLES ]-----

; --> ZONA COM�N, aqu� se alojan variables accesibles desde cualquier BANCO <--
	AgregarVarComun Temp_W, 1						; Variable TEMPORAL para "W"
	AgregarVarComun	Temp_STATUS, 1			; Variable TEMPORAL para "STATUS"	
	AgregarVarComun	Temp0, 1						; Otras variables Temporales
	AgregarVarComun	Temp1, 1
	AgregarVarComun	Temp2, 1
	AgregarVarComun	Temp3, 1
	AgregarVarComun	Temp4, 1

; --> VARIABLES que estar�n en el BANCO 0 <--
	AgregarVarBanco0	Var,1
	AgregarVarBanco0	Point,1
	AgregarVarBanco0	Select,1
	AgregarVarBanco0	OutCod,1
	AgregarVarBanco0	LCD_Dato,1
	AgregarVarBanco0	LCD_GuardaDato,1
	AgregarVarBanco0	LCD_Auxiliar1,1
	AgregarVarBanco0	LCD_Auxiliar2,1

; --> VARIABLES que estar�n en el BANCO 1 <--
	AgregarVarBanco1	Var_1,1

; --> VARIABLES que estar�n en el BANCO 2 <--
	AgregarVarBanco1	Var_2,1

; --> VARIABLES que estar�n en el BANCO 3 <--
	AgregarVarBanco1	Var_3,1

;--------------------------------------------------------------------------------------------------
;-----[ SUBRUTINAS que Manejan RECURSOS ]-----
  #INCLUDE	"Teclado.INC"					; Subrutinas de control del teclado.
	#INCLUDE  "Bin_BCD.INC"					; Conversi�n a c�digo BCD
	#INCLUDE 	"LCD_4Bits_PORTB.inc"	; Manejador de la LCD.
  #INCLUDE 	"Tiempo.inc"					; Retardos y Temporizados.
;--------------------------------------------------------------------------------------------------  
	;END														; Aqu� �NO se USA el fin de archivo, esto contin�a...!
;-------------------------------------------------------------------------------------------------- 

