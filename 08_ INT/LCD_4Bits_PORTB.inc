;------------------------------------------------------------------------------
; Manejador de una LCD empleando comunicación en 4 Bits
;------------------------------------------------------------------------------
;
	IFNDEF LCD_4Bits_PORTB.h
		#INCLUDE "LCD_4Bits_PORTB.h"
	ENDIF
	
;-----[ ALTA de VARIABLES LOCALES ]-----
;------------------------------------------------------------------------------ 
;-----[ Subrutinas ]------
; Genera un pulso en la terminal E, para escribir un dato / comando a la LCD
PulseE:
	bsf		E							; E <- "1" 
	call	T1mS					; Retardo de 1ms 
	bcf		E							; E <- "0"
	call	T1mS					; Retardo de 1ms 
	return							; Es todo.
;--------------------------------------------------------------------------------------------------
; Envío de un caracter (Comando o Dato) en dos partes [baja y alta] por <RB4:RB7>
;
; Si se antecede esta
LCD_Char:
	movwf		OutCod					; Almacena el (dato / comando)de salida. 
	andlw		0xF0						; Limpia la parte baja [low nybble]
	movwf		PORT_LCD				; Muestra por el PUERTO la parte alta [high nybble]
	 
	btfsc		Select,Pin_RS		; Prueba la línea "RS" 
	bsf			RS							; y envía un dato
	
	call		PulseE					; Pulsa la señal de reloj pra enviar la información... 
	call		T1mS						; Espera por 1 milisegundo

	swapf		OutCod,F				; Intercambia las partes alta y baja [low - high nybbles]
	movf		OutCod,W				; Recupera el código de salida
	andlw		0xF0						; Limpia la parte baja [low nybble] 
	movwf		PORT_LCD				; Muestra por el PUERTO la parte baja [low nybble]
	 
	btfsc		Select,Pin_RS		; Prueba la línea "RS"  
	bsf			RS							; y envía un dato
	
	call		PulseE					; Pulsa la señal de reloj pra enviar la información...
	call		T1mS						; Espera por 1 milisegundo
	return									; Listo.
;------------------------------------------------------------------------------
; Inicialización del LCD 
LCD_Inicio:
	SelBanco	TRIS_LCD		; Selecciona el Banco adecuado. 
	clrw									; Todos los bits de este PUERTO son salidas. 
	movwf			TRIS_LCD		; 
	SelBanco 	PORT_LCD		; Selecciona el Banco adecuado.
	clrf			PORT_LCD		; Limpia las salidas.
	call			T10mS				; Espera por 10 milisegundos.
	
	movlw 		0xF0				; Máscara para el código. 
	movwf			Select			; Sin alterar la parte alta [High nybble] 
 
	movlw			0x30				; Carga del valor inicial 
	movwf			PORT_LCD		; Traslado a la LCD  
	call			PulseE			; Captura del código inicial. 
	call			T1mS				; Espera por 1 milisegundo
	call			PulseE			; Captura del código inicial, de nuevo.
	call			T1mS 				; Espera por 1 milisegundo
	call			PulseE			; Captura del código inicial, de nuevo.
	bcf				PORT_LCD,4	; Ajuste al MODO de 4-bit
	call			PulseE			; Captura de la información.
	 
	movlw			0x28				; Ajuste al MODO de 4-bit mode, 2 lineas 
	call			LCD_Char		; Envío del código
	movlw			0x08				; Código para el APAGADO de la LCD 
	call			LCD_Char		; Envío del código
	movlw			0x01				; Código para la LIMPIEZA de la LCD 
	call			LCD_Char		; Envío del código
	movlw			0x06				; Código para la HABILITACIÓN del CURSOR y AUTO INCREMENTO   
	call			LCD_Char		; Envío del código
	movlw			0x80				; Código para el AJUSTE a CERO de la DIRECCIÓN de MEMORIA. 
	call			LCD_Char		; Envío del código
	movlw			0x0C				; Código para el ENCENDIDO de la LCD
	call			LCD_Char		; Envío del código
 
	return								; Se terminó
;------------------------------------------------------------------------------
; Envío de un COMANDO a la LCD
LCD_Com:
SendCom:
	bcf				Select,Pin_RS	; Selecciona el MODO de COMANDO; RS <- "0" 
	call			LCD_Char			; Envía el código (Comando en este caso)
	return
;------------------------------------------------------------------------------
; Envío de un CARACTER (Dato) a la LCD
LCD_Caracter:
	bsf				Select,Pin_RS	; Selecciona el MODO de DATO; RS <- "1" 
	call			LCD_Char			; Envía el código (Dato en este caso)
	return

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; R E V I S A R   subrutinas incorporadas de la versión básica del manejador LCD

; Subrutina "LCD_CodigoCGROM" -----------------------------------------------------------
;
; A partir del carácter ASCII número 127 los códigos de los caracteres definidos en la
; tabla CGROM del LM016L no coinciden con los códigos ASCII. Así por ejemplo, el código
; ASCII de la "Ñ" en la tabla CGRAM del LM016L es EEh.
;
; Esta subrutina convierte los códigos ASCII de la "Ñ", "º" y otros, a códigos CGROM para que
; que puedan ser visualizado en el módulo LM016L.
; 
; Entrada:	En (W) el código ASCII del carácter que se desea visualizar.
; Salida:	En (W) el código definido en la tabla CGROM.

LCD_CodigoCGROM:
	movwf	LCD_Dato					; Guarda el valor del carácter y comprueba si es
LCD_EnheMinuscula:				; un carácter especial.
	sublw	'ñ' 							; ¿Es la "ñ"?
	btfss	STATUS,Z
	goto	LCD_EnheMayuscula	; No es "ñ".
	movlw	b'11101110'				; Código CGROM de la "ñ".
	movwf	LCD_Dato
	goto	LCD_FinCGROM
LCD_EnheMayuscula:
	movf	LCD_Dato,W				; Recupera el código ASCII de entrada.
	sublw	'Ñ' 							; ¿Es la "Ñ"?
	btfss	STATUS,Z
	goto	LCD_Grado					; No es "Ñ".
	movlw	b'11101110'				; Código CGROM de la "ñ". (No hay símbolo para
	movwf	LCD_Dato					; la "Ñ" mayúscula en la CGROM).
	goto	LCD_FinCGROM	
LCD_Grado:
	movf	LCD_Dato,W				; Recupera el código ASCII de entrada.
	sublw	'º' 							; ¿Es el símbolo "º"?
	btfss	STATUS,Z
	goto	LCD_FinCGROM			; No es "º".
	movlw	b'11011111'				; Código CGROM del símbolo "º".
	movwf	LCD_Dato
LCD_FinCGROM:
	movf	LCD_Dato,W				; En (W) el código buscado.
	return

; Subrutina "LCD_DosEspaciosBlancos" y "LCD_LineaBlanco" --------------------------------
; Visualiza espacios en blanco.

LCD_LineaEnBlanco:
	movlw		Columnas
	goto		LCD_EnviaBlancos
LCD_UnEspacioBlanco:
	movlw		.1
	goto	LCD_EnviaBlancos
LCD_DosEspaciosBlancos:
	movlw		.2
	goto	LCD_EnviaBlancos
LCD_TresEspaciosBlancos:
	movlw		.3
LCD_EnviaBlancos:
	movwf		LCD_Auxiliar1						; (LCD_Auxiliar1) se utiliza como contador.
LCD_EnviaOtroBlanco:	
	movlw		' '											; Esto es un espacio en blanco.
	call		LCD_Caracter						; Visualiza tanto espacios en blanco como se
	decfsz	LCD_Auxiliar1,F					; haya cargado en (LCD_Auxiliar1).
	goto		LCD_EnviaOtroBlanco
	return
	
;--------------------------------------------------------------------------------------------------
; Subrutinas "LCD_ByteCompleto" y "LCD_Byte" --------------------------------------------
; Subrutina "LCD_ByteCompleto", visualiza el byte que almacena el registro W en el
; lugar actual de la pantalla. Por ejemplo, si (W)=b'10101110' visualiza "AE".
;
; Subrutina "LCD_Byte" igual que la anterior, pero en caso de que el nibble alto sea cero 
; visualiza en su lugar un espacio en blanco. Por ejemplo si (W)=b'10101110' visualiza "AE"
; y si (W)=b'00001110', visualiza " E" (un espacio blanco delante).
;
; Utilizan la subrutina "LCD_Nibble" que se analiza más adelante.
;
LCD_Byte:
	movwf		LCD_Auxiliar2				; Guarda el valor de entrada.
	andlw		b'11110000'					; Analiza si el nibble alto es cero.
	btfss		STATUS,Z						; Si es cero lo apaga.
	goto		LCD_VisualizaAlto		; No es cero y lo visualiza.
	movlw		' '									; Visualiza un espacio en blanco.
	call		LCD_Caracter				;
	goto		LCD_VisualizaBajo		;

LCD_ByteCompleto:
	movwf		LCD_Auxiliar2				; Guarda el valor de entrada.
LCD_VisualizaAlto:
	swapf		LCD_Auxiliar2,W			; Pone el nibble alto en la parte baja.
	call		LCD_Nibble					; Lo visualiza.
LCD_VisualizaBajo:
	movf		LCD_Auxiliar2,W			; Repite el proceso con el nibble bajo.

; Subrutina "LCD_Nibble" ----------------------------------------------------------------
;
; Visualiza en el lugar actual de la pantalla, el valor hexadecimal que almacena en el nibble
; bajo del registro W. El nibble alto de W no es tenido en cuenta. Ejemplos:
; - Si (W)=b'01010110', se visualizará "6". 
; - Si (W)=b'10101110', se visualizará "E". 
;
LCD_Nibble:
	andlw		b'00001111'							; Se queda con la parte baja.
	movwf		LCD_Auxiliar1						; Lo guarda.
	sublw		0x09										; Comprueba si hay que representarlo con letra.
	btfss		STATUS,C	
	goto		LCD_EnviaByteLetra
	movf		LCD_Auxiliar1,W
	addlw		'0'											; El número se pasa a carácter ASCII sumándole
	goto 		LCD_FinVisualizaDigito	; el ASCII del cero y lo visualiza.
LCD_EnviaByteLetra:
	movf		LCD_Auxiliar1,W
	addlw		'A'-0x0A								; Sí, por tanto, se le suma el ASCII de la 'A'.
LCD_FinVisualizaDigito:
	goto		LCD_Caracter						; Y visualiza el carácter. Se hace con un "goto"
																	; para no sobrecargar la pila.
;--------------------------------------------------------------------------------------------------
;-----[ BAJA de VARIABLES LOCALES ]-----
;------------------------------------------------------------------------------
;-----[ SUBRUTINAS LOCALES a ESTE PAQUETE ]-----
;------------------------------------------------------------------------------
