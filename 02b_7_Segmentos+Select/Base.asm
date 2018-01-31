;==================================================================================================
;	Programa de Ensayo para ejecutar las instrucciones del uC.
;
; NOTAS:
; 1. Ejercite todas y cada una de las instrucciones del uC, tal como están mostradas en la 
; presentación ("Conjunto Instrucciones PIC16F877. [SFHM].pdf"). Verifique el significado de cada 
; elemento de la instrucción leyendo en el manual del dispositivo 
; ("Manual PIC16F877 Comentado (SFHM).pdf").
; 
; 2. Verifique lo que sucede con las instrucciones observando la simulación en Proteus.
;
; 3. Verifique lo que sucede en los registros, memoria y recursos del uC al ejecutar cada 
; instrucción empleando el simulador de MPLAB.
;
; 4. Incluya TODAS las Directivas del lenguaje ensamblador en este segmento de código, explique lo 
; que hace cada directiva con líneas de comentarios
;==================================================================================================
;-----[ AJUSTES ]-----
  LIST 	P = PIC16F877			; Identificación del uC en donde se ensamblará.
  #INCLUDE 	P16f877.INC		; Se usarán las variables de Microchip
  RADIX			Hex						; La base numérica es Hexadecimal por omisión
  
;==================================================================================================
;-----[ Etiquetas de Identificadores ]-----
OK:			  EQU			0x00	  ; Identifica que "Todo está bien".
TIPO_uC:	EQU			0x00		; Tipo de uControlador.

;==================================================================================================
;-----[ Definiciones ]-----
	#DEFINE	Boton PORTB,0
	#DEFINE	Otra	Esto
;==================================================================================================
;-----[ Variables ]-----
Temp0:    EQU     0x20    ; Variable que alojará distintos parámetros. Primera localidad
Temp1:    EQU     0x21		; Variables Temporales para varios usos...
Temp2:    EQU     0x22		;	....

Switches	EQU			0x23		; Interruptores, se obtiene de la lectura del PORTB

;==================================================================================================
;----[ INICIO de CÓDIGO  y de ATENCIÓN a INTERRUPCIONES ]----

Entrada_RESET:
  ORG 0x00					  ; Inicio de ejecución de la aplicación.
				
  movlw	HIGH Inicio	  ; Verificar en cuál página se encuentra la rutina principal.
  movwf	PCLATH 			  ; Carga PCLATH.
  goto 	Inicio			  ;
;-----								
INTERRUPCIONES:		
  ORG 0x04					  ; Atención a interrupciones.
				
  movlw HIGH ISR		  ; Vector de atención a interrupciones.
  movwf	PCLATH			  ; Asegura que es la dirección adecuada (página).
  goto	ISR					  ; 
;==================================================================================================
;-----[ INICIO del CÓDIGO PRINCIPAL ]-----
Inicio:			
  bsf		STATUS, RP0	  ; Pasamos al BANCO "1"
  bcf   STATUS, RP1   ; (Se ajusta la selección del BANCO de FSR)
;-----				

	; AJUSTE de las terminales (pines) de Puertos. "0" -> Salidas, "1" -> Entradas
	movlw	b'11111111'		; Entradas <b7:b0> para
  movwf	TRISB					; Puerto "B"
  
  movlw	b'00000000'		; Salidas para PORTC
  movwf	TRISC					;
                      
  movlw	b'00000000'		; Todas las terminales del Puerto "D"...
  movwf	TRISD				  ; ...estarán como Salidas.
  
;-----				
	bcf		STATUS, RP0	  ; Ahora regresamos al BANCO "0"
	bcf   STATUS, RP1
;-----				

Repite:
;-----[ Captura y Ajuste de la lectura de los Interruptores ]-----	
	movfw	PORTB					; Lectura de los Interruptores
	andlw	b'11110000'		; Me quedo con los interruptores que están en la parte ALTA <b7:b4>
	movwf	Switches			;
	
	bcf		STATUS,C			; Limpia el bit de "carry", para propagar un "0" por la izquierda.
	rrf		Switches, F		; Rota el valor leído hacia la derecha 4 veces
	rrf		Switches, F		;
	rrf		Switches, F		;
	rrf		Switches, F		;
	
;-----
	movfw	Switches			; Para verificar cómo quedó la información en la variable "Switches"
	movwf	PORTC					; ¿Se ve bien?
;-----	

;-----[ Comparación del Valor Capturado de los Switches con las Opciones posibles ]-----
  movfw Switches      ; Toma el valor leído de los interruptores, cópialo en "W"
  sublw .0            ; Prueba si el valor leído fue igual a 0 (0000)
  btfss STATUS, Z     ; ¿Fueron los valores iguales?
  goto  Continua_01   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_0:
  movlw	b'10101010'	  ; Patrón de iluminación para el "0"
  goto  Procesa

Continua_01:
  movfw Switches      ; Toma el valor leído de los interruptores, cópialo en "W"
  sublw .1            ; Prueba si el valor leído fue igual a 1 (0001)
  btfss STATUS, Z     ; ¿Fueron los valores iguales?
  goto  Continua_02   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_1:
  movlw	b'01010101'	  ; Patrón de iluminación para el "1"
  goto  Procesa

Continua_02:
  movfw Switches      ; Toma el valor leído de los interruptores, cópialo en "W"
  sublw .2            ; Prueba si el valor leído fue igual a 2 (0010)
  btfss STATUS, Z     ; ¿Fueron los valores iguales?
  goto  Continua_03   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_2:
  movlw	b'00001111'	  ; Patrón de iluminación para el "2"
  goto  Procesa
  
Continua_03:
  movfw Switches      ; Toma el valor leído de los interruptores, cópialo en "W"
  sublw .3            ; Prueba si el valor leído fue igual a 3 (0011)
  btfss STATUS, Z     ; ¿Fueron los valores iguales?
  goto  Continua_04   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_3:
  movlw	b'11110000'	  ; Patrón de iluminación para el "3"
  goto  Procesa
  
Continua_04: 

  
;-----[ Verifica si ya se puede Imprimir el Resultado del valor procesado]-----
Procesa:
	btfsc	Boton					; ¿Está oprimido el Botón?
	goto  NoOprimida		; NO, estaba en "1"
	
SiOprimida:
	movwf	PORTD				  ;
	
NoOprimida:
	goto	Repite        ; Continúa con el proceso

;------------------------------------------------------------------------------	
	
				
	movlw b'00000000'
	movwf PORTD
;-----
	call  D100          ; Retardo de 100 milisegundos
	call  D100
	call  D100
	call  D100
	call  D100
;-----				
  goto  Repite				
;-----
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
ISR:
	retfie            ; Regresa de la atención a la interrupción.
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  #INCLUDE "R.asm"  ; Subrutinas con los "Retardos de Tiempo"
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  END
