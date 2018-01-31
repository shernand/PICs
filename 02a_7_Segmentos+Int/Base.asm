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
;-----[ Variables ]-----
Temp0:    EQU     0x20    ; Variable que alojar� distintos par�metros. Primera localidad
Temp1:    EQU     0x21
Temp2:    EQU     0x22

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
                      ; AJUSTE de las terminales (pines) de PORTD. "0" -> Salidas, "1" -> Entradas
  movlw	b'00000000'		; Todas las terminales del Puerto "D"
  movwf	TRISD				  ; Estar�n como Salidas.
  
  movlw	b'00001111'		; Salidas <b7:b4> y Entradas <b3:b0> para
  movwf	TRISB					; Puerto "B"
;-----				
	bcf		STATUS, RP0	  ; Ahora regresamos al BANCO "0"
	bcf   STATUS, RP1
;-----				

Repite:

	btfsc	PORTB,0				; �Est� oprimida (En "0") la terminal "0" del Puerto "B"?
	goto  NoOprimida		; NO estaba oprimida, estaba en "1"
	
SiOprimida:
  movlw	b'11111111'	  ; Ilumina...
	movwf	PORTD				  ; 
	goto	Procesa				; Contin�a con el proceso...
	
NoOprimida:
	movlw	b'00000000'		; Apaga...
	movwf	PORTD					;
	
;-----
Procesa:

	goto	Repite

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
