;******************************************************************************
;	Ensayo de comunicación por el canal SCI                                                              
;******************************************************************************                          
;    Nombre del archivo:	Terminal                                           
;    Fecha:					Septiembre del 2010                                                            
;    Versión:				2.0                                                    
;    Autor:					Sergio Fco. Hernández Machuca                                                          
;    Institución:			IDEAS
;****************************************************************************** 
;    Archivos requeridos:	Ninguno.                                                                                                                       
;******************************************************************************
;    Notas:					Se debe ensamblar con la opción "Quickbuild" de "Project".
;******************************************************************************
;----------------------------------------------------------------------------------------------------------------------
;-----[ AJUSTES ]-----

	LIST 		P = PIC16F877	; Identificación del uC en donde se ensamblará.
								; Debe coincidir con lo seleccionado con: "Configure" --> "Select Device"
	#include 	p16f877.inc		; Se usarán las variables y constantes proporcionadas por Microchip
				
	RADIX		dec				;La base numérica es Decimal
	variable	SFHM=57			;Versión

	ERRORLEVEL	-302			; Evitar las advertencias de cambios de bancos

; La siguiente directiva es empleada para configurar dentro del mismo programa  en lenguaje ensamblador (internamente)
; los "fusibles" que determinan el comportamiento del uC en distintas cuestiones.
; Se debe consultar la hoja de datos para identificar cada una de las opciones.
 
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC & _WRT_ENABLE_ON & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
;======================================================================================================================
;     ---- ETIQUETAS ----
;======================================================================================================================

; === IDENTIFICADORES GENÉRICOS ===

	CONSTANT OK = 0x00					; Identifica que "Todo está bien".
	CONSTANT TIPO_uC = 0x00				; Tipo de uControlador:
										; 0x00 = PIC16F877	0x01 = PIC16F877A
										; 0x02 = PIC18F452	0x03 = Otro
	CONSTANT RECURSOS_uC = 0x00			; Características del uC (Recursos, Memorias, Comunicaciones, etc)
										; 0x00 = Básico (PIC)		0x01= Básico (ATMEL)
										; 0x02 = Básico (Motorola)	0x03 = Básico (Otro)
										; 0x04 = Inalámbrico (RF)	0x05 = Inalámbrico (IrDa)
	CONSTANT VERSION = .100				; Versión del software de soporte en el uC, referida
										;  como un valor de 1 a 255 (por ejemplo, V0.01 a V2.55).													

; === IDENTIFICADORES de y para este NODO ===

	CONSTANT MAESTRO =0x00				; Número del NODO Maestro, habitualmente una PC (Central).

	CONSTANT MI_NODO =0x01				; Número del nodo particular de este uC (se cambia para cada uC)

; === COMANDOS ===

;				=== Comandos básicos del Sistema de Red ===

RESPONDER:		EQU			0x00			; Responde, enviando info hacia algún Nodo.
; --> <R> <E> <Longitud> <$00> <Dato1> <Dato2>...<Dato"n"> <CheckSum>
; Longitud = Número de Datos enviados + 2.

IDENTIFICAR:	EQU			0x01			; Envía la identificación de este nodo (TIPO_uC).
; --> <R> <E> <$03> <$01> <TIPO_UC> <CheckSum>

L_MEMORIA:		EQU			0x02			; Lectura de localidad de memoria RAM (Variables o Registros)
; --> <R> <E> <$05> <$02> <Banco> <Localidad Inicial> <Número Datos> <CheckSum>

E_MEMORIA:		EQU			0x03			; Escritura a localidad de memoria RAM (Variable o Registro)
; --> <R> <E> <Longitud> <$03> <Banco> <Localidad Inicial > <Número Datos> <Val1> <Val2>...<Valn> <CheckSum>
; Longitud = Número de Datos enviados + 4.

L_EEPROM:		EQU			0x04			; Lectura de localidad de memoria EEPROM (dato)								
; --> <R> <E> <$04> <$04> <Localidad Inicial> <Número Datos> <CheckSum>

E_EEPROM:		EQU			0x05			; Escritura a localidad de memoria EEPROM	
; --> <R> <E> <Longitud> <$05> <Localidad Inicial > <Num Datos> <Val1> <Val2>...<Val"n"> <CheckSum>
; Longitud = Número de Datos enviados + 3.

L_FSR:			EQU			0x06			; Lectura de Registros del PIC)
; --> <R> <E> <$05> <$06> <Banco> <Localidad Inicial> <Número de Datos> <CheckSum>

E_FSR:			EQU			0x07			; Escribir hacia Registros del PIC.
; --> <R> <E> <Logitud> <$07> <Banco> <Localidad Inicial> <Val1> <Val2>...<Val"n"> <CheckSum>
; Longitud = Número de Datos enviados + 3.

;				=== Comandos para el procesamiento de información en Puertos Expandidos ===

L_PUERTOS:		EQU			0x10			; Lectura de contenidos de PUERTOS de I/O expandidos.
; --> <R> <E> <$03> <$10> <Número Puertos> <CheckSum>
; El Número de Puertos debe ser mayor o igual a "1", pueden ser hasta 16 puertos contiguos.

E_PUERTOS:		EQU			0x11			; Escritura a PUERTOS de I/O expandidos.
; --> <R> <E> <Longitud> <$11> <Num Puertos> <Val1> <Val2>...<Val"n"> <CheckSum>
; Longitud = Número de Datos a enviar + 3.
; El Número de Puertos debe ser mayor o igual a "1", pueden ser hasta 16 puertos contiguos.
							  
L_UN_PUERTO:	EQU			0x12			; Lectura de contenidos de UN PUERTO expandido.
; --> <R> <E> <$03> <$12> <Número del Puerto> <CheckSum>

E_UN_PUERTO:	EQU			0x13			; Escritura a UN PUERTO expandido.
; --> <R> <E> <$04> <$13> <Número del Puerto> <Valor> <CheckSum>										

;				=== Comandos para la Ejecución de procesos ===

E_PROCESO:		EQU			0x20			; Ejecutar un Proceso en el Nodo destino.
; --> <R> <E> <Longitud> <$20> <Código del Proceso> <Parémetro 1> <Parámetro 2>...<Parámetro "n"> <CheckSum>										
; Longitud = Número de Parámtros + 3.

R_PROCESO:		EQU			0x21			; Respuesta de un Proceso ejecutado en un Nodo destino.
; --> <R> <E> <Longitud> <$21> <Código del Proceso> <Parémetro 1> <Parámetro 2>...<Parámetro "n"> <CheckSum>										
; Longitud = Número de Parámtros + 3.

; === IDENTIFICADORES DE LETREROS DEL SISTEMA ===

Let_Principal:	EQU			0x00			; Identificación del Sistema.
Let_Prompt:		EQU			0x01			; "Prompt" del sistema.
Let_Aviso:		EQU			0x02			; Aviso al usuario.
Let_03:			EQU			0x03			; -----
Let_04:			EQU			0x04			; -----
Let_05:			EQU			0x05			; -----
Let_06:			EQU			0x06			; -----
Let_07:			EQU			0x07			; -----
Let_08:			EQU			0x08			; -----
Let_09:			EQU			0x09			; -----

Let_Error:		EQU			0x0A			; Error genérico.

;==================================================================================================
;     ---- Variables ----
;
; Las variables se definen en bloques. Primero se establece la dirección inicial de cada zona.
;==================================================================================================

BANCO_0			EQU			0x020			; Inicio de Bancos para localidades RAM.
BANCO_1			EQU			0x0A0			; Se da la dirección absoluta, para emplear la
BANCO_2			EQU			0x110			; directiva PAGESEL.
BANCO_3			EQU			0x190

ZonaTrabajo:	EQU			0x050			; Zona donde se encuentran las variables empleadas
											; por esta plataforma (Comunicaciones, Control de Red,
											; procesaiento de comandos, etc.)
ZonaComun:		EQU			0x070			; Zona de variables Globales. Son 16 localidades.	

;=========================[ ESTRUCTURAS de DATOS ]=========================

;----[ Banderas del Sistema ]----

EnvioMensaje	EQU			0x00			; Bandera que indica que está en tránsito un mensaje
											; Cuando está en "1", se está recibiendo parte del mensaje
ReciboMensaje	EQU			0x01			; Bandera que indica que está en tránsito un mensaje.
											; Cuando está en "1", se está enviando parte del mensaje.

;-----[Variables del BANCO 0]-----

				CBLOCK		BANCO_0			; Primer bloque de localidades RAM. Esta zona debe estar
				Var0						; (0x20)  disponible para emplearse. El usuario debe
				Var1						; (0x21)  "re-mapear" sus propias variables a estos 
				Var2						; (0x22)  valores, a través de directivas EQU.
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

				HexByte						;(+02) Resultado de conversión

				Tempo						;(+03) ACCESO a EEPROM, FLASH-RAM
				Tempo1						;(+04) ACCESO a EEPROM, FLASH-RAM
				Direccion					;(+05) ACCESO a EEPROM, FLASH-RAM

				TempBanderas				; REVISAR!

				TipoError					;(+06) Identifica los errores. Un valor de 0x00 indica que
											;  todo está bien, cualquier valor distinto a 0x00 indica 
											;  que ocurrió un error en alguna parte. 
											; Se van añadiendo errores por medio de operaciones "OR"
											;  a esta cantidad.

;Variables empleadas para ENSAYOS

				Empiezo, Incremento, Fin, Contador
				
				ENDC

;-----[Zona Común de Variables]-----

				CBLOCK		ZonaComun		; Variables GLOBALES, comunes a todos los BANCOS
			
				Temp0						;(0x70)  = Zona de PILA (STACK), o para variables															
				Temp1						;(0x71)    específicas =
				Temp2						;(0x72)
				Temp3						;(0x73)
				Temp4						;(0x74)	
				Temp5						;(0x75)
				Temp6						;(0x76)
				
				Acc							;(0x77) Registro Acumulador, Auxiliar.
				
				SP							;(0x78) Apuntador de la PILA (STACK), o Registro Índice. 
				
				IX							;(0x79) Registro Índice genérico.
				IY							;(0x7A) Registro Índice genérico.
				
				ContH						;(0x7B) Contador de 16 bits, de uso genérico (Parte ALTA)
				ContL						;(0x7C) Contador de 16 bits, de uso genérico (Parte BAJA)
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
											; Aquí se "Arma"  y "Disecta" el mensaje 
											; (Transmitido - Recibido) para establecer  
											; la comunicación genérica con otros procesadores.
											
; --[ Estrictura del mensaje que se translada ] --

				NodoReceptor				;Nodo al que se dirige el mensaje
				NodoEmisor					;Nodo quien remite el mensaje
				NumeroBytes					;Bytes que contiene el mensaje, a partir del siguiente
											; incluyendo el CHECKSUM
				Comando						;Orden a ejecutar
				Parametro1					;Parámetro - uno -
				Parametro2					;Parámetro - dos - ...
				Parametro3
				Parametro4
				Parametro5
				
				ENDC						
;--------------------------------------------------------------------------------------------------

;******************************************************************************
;	VECTOR de inicio del programa 
;******************************************************************************

				ORG     0x000      			; Vector de RESET del uC.
				movlw	HIGH Principal		; Parte alta de la dirección de Inicio.
				movwf	PCLATH				; Ajusta a la página adecuada
				goto	Principal			; -- Se pueden emplear hasta 4 instrucciones --

;******************************************************************************
;	VECTOR de inicio de Atención a Interrupciones. 
;******************************************************************************
		
				ORG     0x004       		; Vector de ATENCIÓN a INTERRUPCIONES del uC.
				movlw	HIGH ISR			; Parte alta de la dirección de Inicio.
				movwf	PCLATH				; Ajusta a la página adecuada
				goto	ISR					; 
;******************************************************************************
; Aquí se coloca el programa que se desea se ejecute en cada inicio del uC.

Principal:

;--[AJUSTES GENERALES del SISTEMA]--

				call	SCI_19200		; Subrutina para preparar el canal SCI. Al concluir estamos en el Banco "0" 

				movlw	'A'				; Caracter ASCII 'A' en "w"
				call	TxW				; Escribe por el canal serial.
Continua:
				call	RecepcionByte	; Espera hasta que llegue un byte por el canal serial.
				incf	Byte_Rx,F		; Incrementa el byte recibido
				movf	Byte_Rx, W		; Copia en "W"
				call	TxW				; Transmítelo.

				goto	Continua		; Repite lo anterior

;--[Lazo sin fin, para atrapar la salida]--
Espera:					
				goto 	Espera			; Esto se pone como una protección, en caso de desbordamiento.

;##############################################################################
;		---[Subrutinas de apoyo específicas a esta aplicación]---
;##############################################################################


;##############################################################################
;		---[Subrutinas de apoyo genéricas, se ocupan en muchas aplicaciones]---
;##############################################################################

	#include	"subs.asm"

;******************************************************************************

;******************************************************************************
; Aquí debe estar el código (ISR) que atiende a las interrupciones.
ISR:

; Debe iniciar con el siguiente segmento de código.
				movwf   TempW       		; Guarda el valor actual de "w".
				movf	STATUS,w      		; Mueve contenido de"status" al registro "w".
				movwf	TempStatus			; Guarda el contenido de "status".

; Aquí continúa el código del usuario.



; Debe concluir con el siguiente segmento:
				movf    TempStatus,w    	; Restaura la copia de "status".
				movwf	STATUS            	; Restaura el contenido previo.
				swapf   TempW,f			; Intercambia contenidos.		
				swapf   TempW,w          	; Restaura el valor de "w".
				retfie                    	; Regresa de la atención a la interrupción.
;
;####################################################################################################################
				END                       	; Directiva que indica "fin" del código.