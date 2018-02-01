;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;----[Subrutinas Generales]--------------------------------------------------------------------------------------------
; Para usar adecuadamente cualquiera de las siguientes subrutinas se parte de lo siguiente:
; - Quien invoca a la subrutina se encuentra direccionando al Banco "0".
; - Las subrutinas pueden alterar el valor del regisro "W".
; -
;----------------------------------------------------------------------------------------------------------------------
;------[Ajuste de par�metros para la Comunicaci�n Serial]------
; Descripci�n:	Ajusta a valores espec�ficos la comunicaci�n SCI.
; Entrada(s): 	Ninguna.
; Afecta a:		Registro "W", par�metros del SCI.
; Salida(s):	Registro "W".
;----------------------------------------------------------------------------------------------------------------------
SCI_19200:			
				bsf 	STATUS,RP0		; Pasar al Banco "1".
				bcf		STATUS,RP1		;

				movlw	D'64'			    ; Ajustar a 19,200 bauds @ 20 Mhz, suponiendo BRGH en "1".
				movwf  	SPBRG			  ; Deposita el valor en bauds.

;        [Bits del registro TXSTA - TRANSMIT STATUS AND CONTROL REGISTER] Se encuentra en el Banco "1".
; CSRC		H'0007'	= 0	-- 
; TX9		H'0006'	= 0	-- Comunicaci�n a 8 bits	
; TXEN		H'0005'	= 1 -- Habilita la Transmisi�n
; SYNC		H'0004'	= 0 -- Selecciona el modo "As�ncrono"
; ----		H'0003'	= 0
; BRGH		H'0002'	= 1 -- Habilita al uso de ALta Velocidad en "BAUD"
; TRMT		H'0001'	= 0
; TX9D		H'0000'	= 0 
										; Este valor puede cambiar para otras velocidades.
				movlw 	B'00100100' ; Se han puesto: BRGH (Baud Rate Alto), TXEN (Habilita Transmisi�n).
				movwf 	TXSTA			  ; Se han deshabilitado: TX9D, TRMT, SYC, TX9, CSRC.

				bcf		STATUS, RP0		; Regresamos al Banco "0".

;        [Bits del registro RCSTA] Se encuentra en el Banco "0"
; SPEN		H'0007'	= 1	-- Habilita el Puerto Serial
; RX9		H'0006'	= 0 -- Comunicaci�n a 8 bits
; SREN		H'0005'	= 0
; CREN		H'0004'	= 1	-- Habilita la Recepci�n
; ADDEN		H'0003'	= 0
; FERR		H'0002'	= 0
; OERR		H'0001'	= 0
; RX9D		H'0000'	= 0

				movlw 	B'10010000'   ; Se ponen a "1": CREN (Habilita la Recepci�n) y SPEN ... 
										          ; ... (Habilita el puerto serial completo)
				movwf 	RCSTA			    ;
;--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
				return					      ; Recordar quedar en el Banco "0"	

;----------------------------------------------------------------------------------------------------------------------
;------[Transmite un byte por el canal serial, sin manejo de Interrupciones]------
;----------------------------------------------------------------------------------------------------------------------
EnvioByte:								
				movf	Byte_Tx,w		    ; Toma el dato (Byte_Tx) para escribirlo en el canal serial. 
				
;------[ENTRADA para escribir el valor de "W"]------

TxW:
				btfss	PIR1, TXIF		  ; Espera hasta que se termine de transmitir el byte actual (USART).
				goto	$-1				      ;									
				
				movwf	TXREG			      ; Deposita el valor a escribir en el Tx (serial) 
										          ; Salta aqu� si el Buffer del Tx est� vac�o.																											
				return
;----------------------------------------------------------------------------------------------------------------------
;------[Recibe un byte por el canal serial, sin manejo de Interrupciones]------
;----------------------------------------------------------------------------------------------------------------------
RecepcionByte:								
				btfss 	PIR1, RCIF		; Espera hasta que ... 
				goto 	RecepcionByte	  ;   ... se reciba un byte.
				
				movf 	RCREG, W		    ; Toma el byte le�do.
				movwf 	Byte_Rx			  ; Deposita el dato le�do.
				
				return
;----------------------------------------------------------------------------------------------------------------------
;------[Escribe una secuencia de "LineFeed" y "CarriageReturn" hacia el buffer de Tx (Serial)]------
;----------------------------------------------------------------------------------------------------------------------
TxCRLF:								
				movlw	0x0A			    ; Caracter a escribir...
				call	TxW				    ; ...en el canal serial.

				movlw	0x0D		  	  ; Caracter a escribir...
				call	TxW				    ; ...en el canal serial.
																											
				return
;-----------------------------------------------------------------------------------------------
;Lee (dos) Bytes del Canal Serial en formato ASCII, correspondiente a (un) caracter HEXADECIMAL
;-----------------------------------------------------------------------------------------------
RxByteHex:
				call	RecepcionByte ; Lee un byte del canal serial (Hexadecimal en formato ASCII)
				addlw	0xBF			    ; Resta 'A'. (Caracter le�do) - 'A'
				btfss	STATUS, C		  ; Si el resultado fue positivo (dato entre A ... F) salta
				addlw	0x07			    ;   Si no, (dato menor a A), agrega 17 (dato le�do fue 0 ... 9) 
				addlw	0x0A			    ; De cualquier forma, agrega 10
				
				movwf	HexByte			  ; Guarda en variable
				swapf	HexByte, F		; Mueve el nibble calculado a la posici�n m�s alta

				call	RecepcionByte	; Lee un byte del canal serial (Hexadecimal en formato ASCII)
				addlw	0xBF			    ; Resta 'A'. (Caracter le�do) - 'A'
				btfss	STATUS, C		  ; Si el resultado fue positivo (dato entre A ... F) salta
				addlw	0x07			    ;   Si no, (dato menor a A), agrega 17 (dato le�do fue 0 ... 9) 
				addlw	0x0A			    ; De cualquier forma, agrega 10
				
				iorwf	HexByte, F		; Agrega el nibble alto al nibble bajo
				movf	HexByte, W		; Deja el resultado en el registro "W"
				
				return
;----------------------------------------------------------------------------------------------------------------------
;------[Conversi�n de un caracter ASCII Hex a Binario]------
; Entrada: 		Registro "W".
; Resultado:	Registro "W".
;----------------------------------------------------------------------------------------------------------------------
ASCII_Bin:	
				addlw	0xBF				  ; Resta 'A'. -> (Caracter le�do) - 'A'
				btfss	STATUS, C			; Si el resultado fue positivo (dato entre [A.. F]) salta
				addlw	0x07				  ;    Si no, (dato menor a A), agrega 17 (dato le�do fue [0..9]) 
				addlw	0x0A				  ; De cualquier forma, agrega 0x10

				return
;----------------------------------------------------------------------------------------------------------------------
;------[Lectura de Datos del EEPROM local]------
; Descripci�n:	Lectura de datos de la zona EEPROM local.
; Entrada(s): 	En la variable [Tempo] se debe proporcionar la direcci�n de la localidad EEPROM que se desea leer.
; Afecta a:		Registro "W"
; Salida(s):	Resultado de la lectura en el Registro "W".
;----------------------------------------------------------------------------------------------------------------------				
RD_EEPROM:
				bsf		STATUS, RP1		; Ajusta para apuntar al Banco 2
										        ; (Se encuentra, por omisi�n, en el BANCO 0)

				movf 	Tempo, W 		  ; Direcci�n...
				movwf 	EEADR 			; de la que se desea leer.
				
				bsf 	STATUS, RP0 	; Ajusta para apuntar al Banco 3

				bcf 	EECON1, EEPGD ; Apunta al dato en memoria EEPROM

				bsf 	EECON1, RD 		; Inicia la operaci�n de lectura

				bcf 	STATUS, RP0 	; Regresa al banco 2
				movf 	EEDATA, W 		; En W est� el dato que se desea leer (EEDATA)

				bcf		STATUS, RP1		; Regresa al Banco 0
				
				return

;----------------------------------------------------------------------------------------------------------------------
;------[Escritura de Datos hacia el EEPROM local]------
; Descripci�n:	Escritura de datos en la zona EEPROM local.
; Entrada(s): 	Se debe proporcionar en [Tempo] el dato que se desea escribir en la localidad EEPROM especificada.
; 				Se debe prooprcionar en [Tempo1] la direcci�n de la EEPROM en donde se desea escribir.
; Afecta a:		Registro "W"
; Salida(s):	Resultado de la lectura en el Registro "W".
;----------------------------------------------------------------------------------------------------------------------

WR_EEPROM:
				bsf 	STATUS, RP1 	;
				bsf 	STATUS, RP0 	; Ajusta al BANCO 3
Espera_WR_EE:				
				btfsc 	EECON1, WR 	; Espera hasta que...
				goto 	Espera_WR_EE 	; ...concluya la escitura (previa)

				bcf 	STATUS, RP0 	; Vamos al BANCO 2

				movf 	Tempo1, W 		; Esta es la direcci�n...
				movwf 	EEADR 			; ...hacia la cual se escribe.
				
				movf 	Tempo, W 		  ; Este es el...
				movwf 	EEDATA 			; ...dato a escribir.
				
				bsf 	STATUS, RP0 	; Vamos al BANCO 3

				bcf 	EECON1, EEPGD ; Se apunta a la localidad en donde se depositar� el dato.
				bsf 	EECON1, WREN 	; Se habilita la escritura.
										        ; Solamente se deshabilitan las interrupciones...
				bcf 	INTCON, GIE 	; ...Si previamente fueron habilitadas.

				movlw 	0x55 			  ; Secuencia espec�fica a escribir,
				movwf 	EECON2 			;  para habilitar el proceso de escritura
				movlw 	0xAA 			  ;  en la memoria EEPROM.
				movwf 	EECON2 			;
				
				bsf 	EECON1, WR 		; Inicia la operaci�n de escritura
										        ; Se habilitan las interrupciones...
				bsf 	INTCON, GIE 	; ...si previamente se estaban usando.

				bcf 	EECON1, WREN 	; Se deshabilita la escritura de la memoria EEPROM.
				
Espera_WR_EE2:				
				btfsc 	EECON1, WR  ; Espera hasta que...
				goto 	Espera_WR_EE2 ; ...concluya la escitura (actual)
				
				bcf 	STATUS, RP1 	;
				bcf 	STATUS, RP0 	; Ajusta al BANCO 0

				return
;----------------------------------------------------------------------------------------------------------------------				
;------[Realiza la ESCRITURA hacia una Zona de Memoria de un MENSAJE recibido por el canal serial]------
;----------------------------------------------------------------------------------------------------------------------
;
; Esta subrutina realiza el dep�sito de la informaci�n recibida, de acuerdo al siguiente orden:
;
;				NodoReceptor				; Nodo al que se dirige el mensaje
;				NodoEmisor					; Nodo quien remite el mensaje
;				Comando						  ; Orden a ejecutar
;				NumBytes					  ; Bytes que contiene el mensaje, a partir del siguiente
											      ; incluyendo el CHECKSUM
;				Parametro1					; Par�metro - uno -
;				Pamametro2					; Par�metro - dos - ...
;
;				CheckSum					  ; Verificaci�n de integridad del mensaje
;
;ALTERA:
;				W, Contador, FSR, Banco
;-----------------------------------------------------------------------------------------------

Buffer_Temp:	EQU		BANCO_3				;�ltimo banco de memoria RAM (empieza en la localidad 0x190)

Recibe_Mensaje:

				bsf		TempBanderas,EnvioMensaje	;Avisa que se est� recibiendo un mensaje				

				bsf		STATUS, IRP			;Para acceder a la zona de RAM adecuada (Banco 3)
				movlw	Buffer_Temp			;Inicio de la zona de dep�sito
				movwf	FSR					;Este es el apuntador
				
											;Lectura del NODO_RECEPTOR
				call	RecepcionByte		;Toma un dato del canal serial (en formato Hexadecimal)
;				call	RxByteHex			;Toma un dato del canal serial (en formato ASCII)
				movwf	INDF				;Deposita en el lugar adecuado
				incf	FSR, F				;Actualiza el apuntador

;Probablemente aqu� se analize si es conveniente continuar (si es el mensaje para ESTE nodo)
; o si se deja fluir el mensaje de manera constante, sin ponerle atenci�n
;
;				Compara si el valor le�do es igual
;				al valor de este nodo
;				-- Si lo fuera, continua
;               -- Si NO lo fuera, aborta la recepci�n del mensaje.

											;Lectura del NODO_EMISOR
				call	RecepcionByte		;Toma un dato del canal serial (en formato Hexadecimal)
;				call	RxByteHex			;Toma un dato del canal serial (en formato ASCII)
				movwf	INDF				;Deposita en el lugar adecuado
				incf	FSR, F				;Actualiza el apuntador
				
											;Lectura del COMANDO
				call	RecepcionByte		;Toma un dato del canal serial (en formato Hexadecimal)
;				call	RxByteHex			;Toma un dato del canal serial (en formato ASCII)
				movwf	INDF				;Deposita en el lugar adecuado
				incf	FSR, F				;Actualiza el apuntador
					
											;Lectura del NumeroBytes (el n�mero de datos que falta leer)
				call	RecepcionByte		;Toma un dato del canal serial (en formato Hexadecimal)
;				call	RxByteHex			;Toma un dato del canal serial (en formato ASCII)
				movwf	INDF				;Deposita en el lugar adecuado
				movwf	ContL				;Contador de datos le�dos y depositados
				incf	FSR, F				;Actualiza el apuntador
	
Continua_Mensaje:							;Lectura de Par�metros y Checksum
				call	RecepcionByte		;Toma un dato del canal serial (en formato Hexadecimal)
;				call	RxByteHex			;Toma un dato del canal serial (en formato ASCII)
				movwf	INDF				;Deposita en el lugar adecuado
				incf	FSR, F				;Actualiza el apuntador
				
				decfsz	ContL, F			;Actualiza el contador
				goto	Continua_Mensaje	;Continua hasta concluir
				
				bcf		STATUS, IRP			;Para regresar al estado natural de acceso (indirecto) a bancos
				
				bcf		TempBanderas,EnvioMensaje	;Avisa que se termin� de recibir un mensaje
				
				return							
;-----------------------------------------------------------------------------------------------
;Realiza la LECTURA de lo contenido en una Zona de Memoria (MENSAJE) y escritura hacia el canal serial.
;
; Esta subrutina toma la informaci�n previamente procesada, de acuerdo al siguiente orden:
;
;				NodoReceptor				;Nodo al que se dirige el mensaje
;				NodoEmisor					;Nodo quien remite el mensaje
;				Comando						;Orden a ejecutar
;				NumeroBytes					;Bytes que contiene el mensaje, a partir del siguiente
											; incluyendo el CHECKSUM
;				Parametro1					;Par�metro - uno -
;				Pamametro2					;Par�metro - dos - ...
;
;				CheckSum					;Verificaci�n de integridad del mensaje
;
;ALTERA:
;				W, Contador, FSR, Banco
;-----------------------------------------------------------------------------------------------

Buffer_Temp:	EQU		BANCO_3				;�ltimo banco de memoria RAM (empieza en la localidad 0x190)

Envia_Mensaje:
				bsf		TempBanderas,ReciboMensaje	;Avisa que se est� enviando un mensaje				

				bsf		STATUS, IRP			;Para acceder a la zona de RAM adecuada (Banco 3)
				movlw	Buffer_Temp			;Inicio de la zona de dep�sito
				movwf	FSR					;Este es el apuntador
				
											;Escritura del NODO_RECEPTOR
				movfw	INDF				;Toma el valor depositado en memoria RAM
				call	TxW					;Env�a el dato por el canal serial (en Hexadecimal)
				incf	FSR, F				;Actualiza el apuntador

											;Escritura del NODO_EMISOR
				movfw	INDF				;Toma el valor depositado en memoria RAM
				call	TxW					;Env�a el dato por el canal serial (en Hexadecimal)
				incf	FSR, F				;Actualiza el apuntador

											;Escritura del COMANDO
				movfw	INDF				;Toma el valor depositado en memoria RAM
				call	TxW					;Env�a el dato por el canal serial (en Hexadecimal)
				incf	FSR, F				;Actualiza el apuntador

											;Escritura del NumeroBytes a enviar
				movfw	INDF				;Toma el valor depositado en memoria RAM
				movwf	ContL				;Ajusta el Contador del n�mero de bytes a transmitir
				call	TxW					;Env�a el dato por el canal serial (en Hexadecimal)
				incf	FSR, F				;Actualiza el apuntador
				
Continua_Escribiendo:

				movfw	INDF				;Toma el valor depositado en memoria RAM
				call	TxW					;Env�a el dato por el canal serial (en Hexadecimal)
				incf	FSR, F				;Actualiza el apuntador
				
				decfsz	ContL, F			;Actualiza el Contador
				goto	Continua_Escribiendo	;Continua hasta concluir

				bcf		STATUS, IRP			;Para regresar al estado natural de acceso (indirecto) a bancos				
				bcf		TempBanderas,ReciboMensaje	;Avisa que se termin� de recibir un mensaje
				
				return
;----------------------------------------------------------------------------------------------------------------------
; C�lculo de Retardo: 100 milisegundos.
;
; --> En esta subrutina se consumen 500,000 ciclos.
; --> Si se emplea un cristal de 20 MHz, se generan instrucciones a una velocidad
;  		de 200 nanosegundos, de donde el retardo es de:
;  		(200 nanosegundos ) * (500,000 instrucciones ejecutadas) =
;   		100,000,000 de nanosegundos = 100 miliaegundos = 0.1 segundo.
;----------------------------------------------------------------------------------------------------------------------

PDelay:  
				movlw		.239      		; Ajusta el n�mero de repeticiones (B
        		movwf     	PDel0     		; 1 |
PLoop1 
				movlw     	.232      		; Ajusta el n�mero de repeticiones (A)
        		movwf     	PDel1     		; 1 |
PLoop2:
				clrwdt              		; 1 Limpieza del WDT.
PDelL1:
  				goto 		PDelL2         	; Retardo de 2 ciclos.
PDelL2:
				goto 		PDelL3         	; Retardo de 2 ciclos.
PDelL3:
				clrwdt              		; Retardo de 1 ciclo.
        		decfsz    	PDel1, 1  		; 1 + (1) �Se acab� en tiempo para (A)?
        		goto      	PLoop2    		; 2 No, contin�a...
        		
				decfsz    	PDel0,  1 		; 1 + (1) �Se acab� el tiempo para (B)?
        		goto      	PLoop1    		; 2 no, Contin�a...
PDelL4:
				goto 		PDelL5         	; Retardo de 2 ciclos.
PDelL5:
				goto 		PDelL6         	; Retardo de 2 ciclos.
PDelL6:
				goto 		PDelL7         	; Retardo de 2 ciclos.
PDelL7:
				clrwdt              		; Retardo de 1 ciclo.
        		
				return              		; Concluido 2+2
								
;----------------------------------------------------------------------------------------------------------------------
;------[Nombre de la Subrutina]------
; Descripci�n:	Lo que hace esta subrutina, en no m�s de un rengl�n
; Entrada(s): 	Registro "W".
; Afecta a:		Registro "W"
; Salida(s):	Registro "W".
;----------------------------------------------------------------------------------------------------------------------
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-	
