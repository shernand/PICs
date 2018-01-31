;==================================================================================================
;	Programa de Ensayo para ejecutar las instrucciones del uC.
;
; NOTAS:
; 1. Ejercite todas y cada una de las instrucciones del uC, tal como est�n mostradas en la 
; presentaci�n ("Conjunto Instrucciones PIC16F877. [SFHM].pdf"). Verifique el significado de cada 
; elemento de la instrucci�n leyendo en el manual del dispositivo 
; ("Manual PIC16F877 Comentado (SFHM).pdf").
; 
; 2. Verifique lo que sucede con las instrucciones observando la simulaci�n en Proteus.
;
; 3. Verifique lo que sucede en los registros, memoria y recursos del uC al ejecutar cada 
; instrucci�n empleando el simulador de MPLAB.
;
; 4. Incluya TODAS las Directivas del lenguaje ensamblador en este segmento de c�digo, explique lo 
; que hace cada directiva con l�neas de comentarios
;==================================================================================================
;-----[ AJUSTES ]-----
  LIST 	P = PIC16F877			; Identificaci�n del uC en donde se ensamblar�.
  #INCLUDE 	P16f877.INC		; Se usar�n las variables de Microchip
  RADIX			Hex						; La base num�rica es Hexadecimal por omisi�n
  
;==================================================================================================
;-----[ Etiquetas de Identificadores ]-----
OK:			  EQU			0x00	  ; Identifica que "Todo est� bien".
TIPO_uC:	EQU			0x00		; Tipo de uControlador.

;==================================================================================================
;-----[ Definiciones ]-----
	#DEFINE	Boton PORTB,0
	#DEFINE	Otra	Esto
;==================================================================================================
;-----[ Variables ]-----
Temp0:    EQU     0x20    ; Variable que alojar� distintos par�metros. Primera localidad
Temp1:    EQU     0x21		; Variables Temporales para varios usos...
Temp2:    EQU     0x22		;	....

Switches	EQU			0x23		; Interruptores, se obtiene de la lectura del PORTB

;==================================================================================================
;----[ INICIO de C�DIGO  y de ATENCI�N a INTERRUPCIONES ]----

Entrada_RESET:
  ORG 0x00					  ; Inicio de ejecuci�n de la aplicaci�n.
				
  movlw	HIGH Inicio	  ; Verificar en cu�l p�gina se encuentra la rutina principal.
  movwf	PCLATH 			  ; Carga PCLATH.
  goto 	Inicio			  ;
;-----								
INTERRUPCIONES:		
  ORG 0x04					  ; Atenci�n a interrupciones.
				
  movlw HIGH ISR		  ; Vector de atenci�n a interrupciones.
  movwf	PCLATH			  ; Asegura que es la direcci�n adecuada (p�gina).
  goto	ISR					  ; 
;==================================================================================================
;-----[ INICIO del C�DIGO PRINCIPAL ]-----
Inicio:			
  bsf		STATUS, RP0	  ; Pasamos al BANCO "1"
  bcf   STATUS, RP1   ; (Se ajusta la selecci�n del BANCO de FSR)
;-----				

	; AJUSTE de las terminales (pines) de Puertos. "0" -> Salidas, "1" -> Entradas
	movlw	b'11111111'		; Entradas <b7:b0> para
  movwf	TRISB					; Puerto "B"
  
  movlw	b'00000000'		; Salidas para PORTC
  movwf	TRISC					;
                      
  movlw	b'00000000'		; Todas las terminales del Puerto "D"...
  movwf	TRISD				  ; ...estar�n como Salidas.
  
;-----				
	bcf		STATUS, RP0	  ; Ahora regresamos al BANCO "0"
	bcf   STATUS, RP1
;-----				

Repite:
;-----[ Captura y Ajuste de la lectura de los Interruptores ]-----	
	movfw	PORTB					; Lectura de los Interruptores
	andlw	b'11110000'		; Me quedo con los interruptores que est�n en la parte ALTA <b7:b4>
	movwf	Switches			;
	
	bcf		STATUS,C			; Limpia el bit de "carry", para propagar un "0" por la izquierda.
	rrf		Switches, F		; Rota el valor le�do hacia la derecha 4 veces
	rrf		Switches, F		;
	rrf		Switches, F		;
	rrf		Switches, F		;
	
;-----
	movfw	Switches			; Para verificar c�mo qued� la informaci�n en la variable "Switches"
	movwf	PORTC					; �Se ve bien?
;-----	

;-----[ Comparaci�n del Valor Capturado de los Switches con las Opciones posibles ]-----
  movfw Switches      ; Toma el valor le�do de los interruptores, c�pialo en "W"
  sublw .0            ; Prueba si el valor le�do fue igual a 0 (0000)
  btfss STATUS, Z     ; �Fueron los valores iguales?
  goto  Continua_01   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_0:
  movlw	b'10101010'	  ; Patr�n de iluminaci�n para el "0"
  goto  Procesa

Continua_01:
  movfw Switches      ; Toma el valor le�do de los interruptores, c�pialo en "W"
  sublw .1            ; Prueba si el valor le�do fue igual a 1 (0001)
  btfss STATUS, Z     ; �Fueron los valores iguales?
  goto  Continua_02   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_1:
  movlw	b'01010101'	  ; Patr�n de iluminaci�n para el "1"
  goto  Procesa

Continua_02:
  movfw Switches      ; Toma el valor le�do de los interruptores, c�pialo en "W"
  sublw .2            ; Prueba si el valor le�do fue igual a 2 (0010)
  btfss STATUS, Z     ; �Fueron los valores iguales?
  goto  Continua_03   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_2:
  movlw	b'00001111'	  ; Patr�n de iluminaci�n para el "2"
  goto  Procesa
  
Continua_03:
  movfw Switches      ; Toma el valor le�do de los interruptores, c�pialo en "W"
  sublw .3            ; Prueba si el valor le�do fue igual a 3 (0011)
  btfss STATUS, Z     ; �Fueron los valores iguales?
  goto  Continua_04   ; El resultado fue distinto a CERO, No fueron iguales los valores.

Fue_igual_a_3:
  movlw	b'11110000'	  ; Patr�n de iluminaci�n para el "3"
  goto  Procesa
  
Continua_04: 

  
;-----[ Verifica si ya se puede Imprimir el Resultado del valor procesado]-----
Procesa:
	btfsc	Boton					; �Est� oprimido el Bot�n?
	goto  NoOprimida		; NO, estaba en "1"
	
SiOprimida:
	movwf	PORTD				  ;
	
NoOprimida:
	goto	Repite        ; Contin�a con el proceso

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
	retfie            ; Regresa de la atenci�n a la interrupci�n.
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  #INCLUDE "R.asm"  ; Subrutinas con los "Retardos de Tiempo"
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  END
