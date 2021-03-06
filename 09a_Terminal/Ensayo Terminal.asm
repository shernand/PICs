;******************************************************************************
;	Ensayo de comunicaci�n por el canal SCI 
;                                                                   
;******************************************************************************
;                                                                     
;    Nombre del archivo:	Terminal                                           
;    Fecha:					Septiembre del 2010                                                            
;    Versi�n:				2.0                                                    
;    Autor:					Sergio Fco. Hern�ndez Machuca                                                          
;    Instituci�n:			IDEAS
;******************************************************************************
;                                                                     
;    Archivos requeridos:	Ninguno.                                                                                                                       
;                                                                     
;******************************************************************************
;
;    Notas:					Se debe ensamblar con la opci�n "Quickbuild" de "Project".
;
;******************************************************************************
;----------------------------------------------------------------------------------------------------------------------
;-----[ AJUSTES ]-----

	LIST 		P = PIC16F877	; Identificaci�n del uC en donde se ensamblar�.
								; Debe coincidir con lo seleccionado con: "Configure" --> "Select Device"
	#INCLUDE 	p16f877.inc		; Se usar�n las variables y constantes proporcionadas por Microchip
				
	RADIX		dec				;La base num�rica es Decimal
	variable	SFHM=57			;Versi�n

	ERRORLEVEL	-302			; Evitar las advertencias de cambios de bancos

; La siguiente directiva es empleada para configurar dentro del mismo programa  en lenguaje ensamblador (internamente)
; los "fusibles" que determinan el comportamiento del uC en distintas cuestiones.
; Se debe consultar la hoja de datos para identificar cada una de las opciones.
 
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _WRT_ENABLE_ON & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
;======================================================================================================================
;     ---- ETIQUETAS ----
;======================================================================================================================

; === IDENTIFICADORES GEN�RICOS ===

; === IDENTIFICADORES de y para este NODO ===

; === COMANDOS ===

;				=== Comandos b�sicos del Sistema de Red ===

; === IDENTIFICADORES DE LETREROS DEL SISTEMA ===

Let_Principal:	EQU			0x00			; Identificaci�n del Sistema.
Let_Prompt:		EQU			0x01			; "Prompt" del sistema.
Let_Aviso:		EQU			0x02			; Aviso al usuario.
Let_03:			EQU			0x03			; -----
Let_04:			EQU			0x04			; -----
Let_05:			EQU			0x05			; -----
Let_06:			EQU			0x06			; -----
Let_07:			EQU			0x07			; -----
Let_08:			EQU			0x08			; -----
Let_09:			EQU			0x09			; -----

Let_Error:		EQU			0x0A			; Error gen�rico.

;==================================================================================================
;     ---- Variables ----
;
; Las variables se definen en bloques. Primero se establece la direcci�n inicial de cada zona.
;==================================================================================================

BANCO_0			EQU			0x020			; Inicio de Bancos para localidades RAM.
BANCO_1			EQU			0x0A0			; Se da la direcci�n absoluta, para emplear la
BANCO_2			EQU			0x110			; directiva PAGESEL.
BANCO_3			EQU			0x190

ZonaTrabajo:	EQU			0x050			; Zona donde se encuentran las variables empleadas
											; por esta plataforma (Comunicaciones, Control de Red,
											; procesaiento de comandos, etc.)
ZonaComun:		EQU			0x070			; Zona de variables Globales. Son 16 localidades.	

;=========================[ ESTRUCTURAS de DATOS ]=========================

;----[ Banderas del Sistema ]----

EnvioMensaje	EQU			0x00			; Bandera que indica que est� en tr�nsito un mensaje
											; Cuando est� en "1", se est� recibiendo parte del mensaje
ReciboMensaje	EQU			0x01			; Bandera que indica que est� en tr�nsito un mensaje.
											; Cuando est� en "1", se est� enviando parte del mensaje.

;-----[Variables del BANCO 0]-----

				CBLOCK		BANCO_0			; Primer bloque de localidades RAM. Esta zona debe estar
				Var0						; (0x20)  disponible para emplearse. El usuario debe
				Var1						; (0x21)  "re-mapear" sus propias variables a estos 
				Var2						; (0x22)  valores, a trav�s de directivas EQU.
				Var3						; (0x23)
				Var4						; (0x24)    Por ejemplo:
				Var5						; (0x25)  
				Var6						; (0x26)   SumaH:		EQU		Var0
				Var7						; (0x27)   SumaL:		EQU		Var1
				Var8						; (0x28)
				Var9						; (0x29)
				VarA						; (0x2A)
				VarB						; (0x2B)  
				VarC						; (0x2C)  
				VarD						; (0x2D)
				VarE						; (0x2E)
				VarF						; (0x2F)
				

				PDel0 						; Variable para rutina de retardo.
				PDel1						; Variable para rutina de retardo.

				ENDC

;-----[Zona de Variables de Trabajo]-----

				CBLOCK		ZonaTrabajo		; Zona de RAM para las variables de la Plataforma
											; El usuario NO DEBE acceder a estas localidades.
											; -= Inicialmete se encuentra a partir de 0x050 =-

				Byte_Tx						;(+00) Byte a TRANSMITIR (Canal Serial ...)
				Byte_Rx						;(+01) Byte RECIBIDO (Canal Serial ...)

				HexByte						;(+02) Resultado de conversi�n

				Tempo						;(+03) ACCESO a EEPROM, FLASH-RAM
				Tempo1						;(+04) ACCESO a EEPROM, FLASH-RAM
				Direccion					;(+05) ACCESO a EEPROM, FLASH-RAM

				TempBanderas				; REVISAR!

				TipoError					;(+06) Identifica los errores. Un valor de 0x00 indica que
											;  todo est� bien, cualquier valor distinto a 0x00 indica 
											;  que ocurri� un error en alguna parte. 
											; Se van a�adiendo errores por medio de operaciones "OR"
											;  a esta cantidad.

;Variables empleadas para ENSAYOS

				Empiezo, Incremento, Fin, Contador
				
				ENDC

;-----[Zona Com�n de Variables]-----

				CBLOCK		ZonaComun		; Variables GLOBALES, comunes a todos los BANCOS
			
				Temp0						;(0x70)  = Zona de PILA (STACK), o para variables															
				Temp1						;(0x71)    espec�ficas =
				Temp2						;(0x72)
				Temp3						;(0x73)
				Temp4						;(0x74)	
				Temp5						;(0x75)
				Temp6						;(0x76)
				
				Acc							;(0x77) Registro Acumulador, Auxiliar.
				
				SP							;(0x78) Apuntador de la PILA (STACK), o Registro �ndice. 
				
				IX							;(0x79) Registro �ndice gen�rico.
				IY							;(0x7A) Registro �ndice gen�rico.
				
				ContH						;(0x7B) Contador de 16 bits, de uso gen�rico (Parte ALTA)
				ContL						;(0x7C) Contador de 16 bits, de uso gen�rico (Parte BAJA)
											; Variables de Contexto, guardadas en Interrupciones.
				TempPCLATH					;(0x7D) Valor temporal del PC
				TempStatus					;(0x7E) Valor temporal de las Banderas.
				TempW						;(0x7F) Valor temporal del registro "W".
													
				ENDC

;-----[Variables del BANCO 1]-----

				CBLOCK		BANCO_1			;Segundo bloque de RAMs
				
				PtoA						;Registros "Espejo" de los
				PtoB						; Puertos de I/O
				PtoC						;
				PtoD						;
				PtoE						;

;-----[Variables del BANCO 2]-----

				ENDC
				
				CBLOCK		BANCO_2			;Tercer bloque de localidades de memoria RAM.

				ENDC

;-----[Variables del BANCO 3]-----

				CBLOCK		BANCO_3			; Cuarto bloque de localidades de memoria RAM.
											; Aqu� se "Arma"  y "Disecta" el mensaje 
											; (Transmitido - Recibido) para establecer  
											; la comunicaci�n gen�rica con otros procesadores.
											
; --[ Estrictura del mensaje que se translada ] --

				NodoReceptor				;Nodo al que se dirige el mensaje
				NodoEmisor					;Nodo quien remite el mensaje
				NumeroBytes					;Bytes que contiene el mensaje, a partir del siguiente
											; incluyendo el CHECKSUM
				Comando						;Orden a ejecutar
				Parametro1					;Par�metro - uno -
				Parametro2					;Par�metro - dos - ...
				Parametro3
				Parametro4
				Parametro5
				
				ENDC						
;--------------------------------------------------------------------------------------------------

;******************************************************************************
;	VECTORES de inicio de programa 
;******************************************************************************

				ORG     0x000      			; Vector de RESET del uC.
				movlw	HIGH Principal		; Parte alta de la direcci�n de Inicio.
				movwf	PCLATH				; Ajusta a la p�gina adecuada
				goto	Principal			; -- Se pueden emplear hasta 4

;******************************************************************************
;	VECTORES de inicio de Atenci�n a Interrupciones. 
;******************************************************************************
		
				ORG     0x004       		; Vector de ATENCI�N a INTERRUPCIONES del uC.
				movlw	HIGH ISR			; Parte alta de la direcci�n de Inicio.
				movwf	PCLATH				; Ajusta a la p�gina adecuada
				goto	ISR					; -- Se pueden emplear hasta 4
;******************************************************************************
; Aqu� se coloca el programa que se desea se ejecute en cada inicio del uC.

Principal:

;--[AJUSTES GENERALES del SISTEMA]--

				call	SCI_19200		; Subrutina para preparar el canal SCI. Al concluir estamos en el Banco "0"
			
				; goto	S02				; Secci�n a probar
				goto  S03

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
S01:
				movlw	'>'				; Caracter ASCII 'A' en "w"
				call	TxW				; Escribe por el canal serial.
Continua:
				call	RecepcionByte	; Espera hasta que llegue un byte por el canal serial.
				incf	Byte_Rx			; Incrementa el byte recibido
				movf	Byte_Rx, W		; Copia en "W"
				call	TxW				; Transm�telo.

				goto	Continua		; Repite lo anterior

;--[Lazo sin fin, para atrapar la salida]--
Espera:					
				goto 	Espera			; Esto se pone como una protecci�n, en caso de desbordamiento.

; >->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->
S02:
				movlw	'>'
				call	TxW
				movlw	'-'
				call	TxW
				call	TxCRLF	
				
				call	RecepcionByte	; Espera hasta que llegue un byte por el canal serial.
				;decf	Byte_Rx			; Incrementa el byte recibido
				movf	Byte_Rx, W		; Copia en "W"
				call	TxW				; Transm�telo.
				;call	TxW
				;call	TxW
				;call	TxCRLF

				goto	S02

				goto 	Espera			; Esto se pone como una protecci�n, en caso de desbordamiento.
				
S03:
        movlw 'a'
        call  TxW
        goto  S03		

;##############################################################################
;		---[Subrutinas de apoyo espec�ficas a esta aplicaci�n]---
;##############################################################################


;##############################################################################
;		---[Subrutinas de apoyo gen�ricas, se ocupan en muchas aplicaciones]---
;##############################################################################

	#include	"subs.asm"

;******************************************************************************

;******************************************************************************
; Aqu� debe estar el c�digo (ISR) que atiende a las interrupciones.
ISR:

; Debe iniciar con el siguiente segmento de c�digo.
				movwf   TempW       		; Guarda el valor actual de "w".
				movf	STATUS,w      		; Mueve contenido de"status" al registro "w".
				movwf	TempStatus			; Guarda el contenido de "status".

; Aqu� contin�a el c�digo del usuario.



; Debe concluir con el siguiente segmento:
				movf    TempStatus,w    	; Restaura la copia de "status".
				movwf	STATUS            	; Restaura el contenido previo.
				swapf   TempW,f			; Intercambia contenidos.		
				swapf   TempW,w          	; Restaura el valor de "w".
				retfie                    	; Regresa de la atenci�n a la interrupci�n.
;
;####################################################################################################################
				END                       	; Directiva que indica "fin" del c�digo.