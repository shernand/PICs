;--------------------------------------------------------------------------------------------------
; ------[Subrutinas para el Manejo de Tiempos Exactos]------
;
; Se selecciona la opción para las pruebas necesarias, locales o externas.
; Para el uso común de estas subrutinas se habilitan los contadores [1, 2 y 3] asociándolos a las
; variables temporales [Temp0, Temp1 y Temp2], que deberían haberse creado previamente.
;
;     Retardos de Tiempo Disponibles:
;
; 		T1uS
; 		T10uS
;			T100uS
;			T1mS
;			T10mS
;			T100mS
;			T1S
;			T10S

	CBLOCK							; Sustituir por variables TEMPorales
		Contador1	
		Contador2	
		Contador3			
	ENDC

;Contador1 EQU VarTmp1
;Contador2 EQU VarTmp2
;Contador3 EQU VarTmp3
;---------------------------------
;			ORG		0x000
			
;			call	T10uS		; Desde aquí se cuenta el tiempo que se consumirá.
;			call	T100mS	;
;			call  T1uS
;			call  T1uS
							      ; 
;			goto	$       ; AQUÍ se inserta un "breakpoint", para contabilizar el tiempo de ejecución
			              ; en el "StopWatch"
;--------------------------------------------------------------------------------------------------
;------[Retardo de 1 microsegundo]------
;--------------------------------------------------------------------------------------------------
T1uS:
			nop						; "A" [1]
			
			return				; "B" [2]
;--------------------------------------------------------------------------------------------------
;TEORÍA de FUNCIONAMIENTO:
;
;--> Los números entre paréntesis indican los ciclos consumidos. Recuerde que un ciclo de máquina
; es igual a 200 nS.
;--> Existen CICLOS que se repiten un cierto numero de veces.
;--> En algunos casos habrá CICLOS ANIDADOS, es decir, CICLOS dentro de CICLOS.
;
;Para esta subrutina el cálculo de los ciclos queda de la siguiente manera:
;
; 		  [2]                 -->  2    {Instrucción "call" en la "llamada" o "invocación"}
; 	+ 	[A]                 -->  1	  {Instrucción "nop" [A]}
;   +   [2]                 -->  2    {Instrucción "return" [B]}
; -----------------------------------                  
;       T O T A L           -->  5 Ciclos
;                                5 * 200 nS = 1000 nS = 1 uS
;--------------------------------------------------------------------------------------------------
;------[Retardo de 10 microsegundos]------
;--------------------------------------------------------------------------------------------------
			
T10uS:												; "A" [2] de la instrucción “call” que le invoca 
			movlw		0x0F						; "B" [1] de la instrucción "movlw"
			movwf		Contador1				; "C" [1] de la instrucción "movwf"

			decfsz	Contador1, F		; "D" [2] si salta, [1] si continúa
			goto		$ - 1						; "E" [2]

			return									; "F" [2]
;--------------------------------------------------------------------------------------------------
;TEORÍA de FUNCIONAMIENTO:
;
;--> Los números entre paréntesis indican los ciclos consumidos. Recuerde que un ciclo de máquina
; es igual a 200 nS.
;--> Existen CICLOS que se repiten un cierto numero de veces.
;--> En algunos casos habrá CICLOS ANIDADOS, es decir, CICLOS dentro de CICLOS.
;
;Para esta subrutina el cálculo de los ciclos queda de la siguiente manera:
;
; 			[2] + [1] + [1]     -->  4    {Instrucciones "call", "movlw", "movwf"}
; 	+ 	14 * [1 + 2]        --> 42	  {Repetición del ciclo "decfsz", "goto $ - 1"}
;   +   [2] + [2]           -->  4    {Del salto de "decfsz" y "return"}
; -----------------------------------                  
;       T O T A L           --> 50 Ciclos
;                               50 * 200 nS = 10,000 nS = 10 uS
;--------------------------------------------------------------------------------------------------
;------[Retardo de 100 microsegundos]------
;--------------------------------------------------------------------------------------------------

T100uS:												; "A" [2] de la instrucción “call” que le invoca 
			movlw		0xA5						; "B" [1] 
			movwf		Contador1				; "C" [1]

			decfsz	Contador1, F		; "D" [2] si salta, [1] si continúa
			goto		$ - 1						; "E" [2]

			return									; "F" [2]
			
;--------[ TEORÍA de FUNCIONAMIENTO------------------------------------------------------------------------------------
;  Para N igual a 1:
; A[2] --> B[1] --> C[1] --> D[2] --> F[2]								
;			8 Ciclos, 1.6 uSegs.
;
;  Para N igual a 2:
; A[2] --> B[1] --> C[1] --> D[1] --> E[2] --> D[2] --> F[2]
;			11 Ciclos, 2.2 uSegs.
;
;  Para N igual a 3:
; A[2] --> B[1] --> C[1] --> D[1] --> E[2] --> D[1] --> E[2] --> D[2] --> F[2]
; 			14 Ciclos, 2.8 uSegs.
;
;  Para N igual a 4:
; A[2] --> B[1] --> C[1] --> D[1] --> E[2] --> D[1] --> E[2] --> D[1] --> E[2]--> D[2] --> F[2]
; 			17 Ciclos, 3.4 uSegs.
;
; Secuencia de ejecución para cada valor de "N". Cada columna representa una etapa.
; Se indica la instrución que se ejecuta y los ciclos que consume.
; 
;  1     2         3             4
;
; A-2   A-2       A-2           A-2 								* Número de ciclos fijo: 2
; B-1   B-1       B-1           B-1									* Número de ciclos fijo: 1
; C-1   C-1       C-1           C-1									* Número de ciclos fijo: 1
; D-2   D-1 D-2   D-1 D-1 D-2   D-1 D-1 D-1 D-2			* (N-1)*1 + 2
;       E-2       E-2 E-2       E-2 E-2 E-2					* (N-1)*2
; F-2   F-2       F-2           F-2									* Número de ciclos fijo: 2
;
;  En general, para cualquier valor "N":
;
; Ciclos consumidos = 2 + 1 + 1 + 1*(N-1) + 2 + 2*(N-1) + 2 
; Ciclos consumidos = 8 + (N-1) + 2*(N-1) 
; Ciclos consumidos = 8 + 3*(N-1) 
; Ciclos consumidos = 8 + 3*N - 3 
; Ciclos consumidos = 5 + 3*N
;
; Por ejemplo, para N=255, ciclos consumidos = 770 (154 uSeg).
; Para un retardo de 10 uSeg se resuelve: 50 = 5 + 3*N, de donde N = 15 (0x0F) .
;  y para 100 uSeg, se resuelve: 500 = 5 + 3*N, de donde N = 165 (0xA5).
;----------------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------------
;------[Retardo de 1 milisegundo]------
;----------------------------------------------------------------------------------------------------------------------
T1mS:
  			movlw     .6        			; 1 | Número de repeticiones externas (B)
        movwf     Contador1 			; 1 |
        	
L01:  	movlw     .207      			; 1 | Número de repeticiones internas (A)
        movwf     Contador2 			; 1 |
        	
L02:  	clrwdt              			; 1 | Limpia registro WDT.
        decfsz    Contador2,1  		; 1 + (1) ¿Se agotó? (A)
        goto      L02    					; 2 no, regresa.
        decfsz    Contador1,1 		; 1 + (1) ¿Se agotó? (B)
        goto      L01    					; 2 no, regresa
        	
				goto 	  	$+1         		; Retardo de 2 ciclos.
				clrwdt              			; Retardo de un ciclo. 

        return              			; 2+2 Concluído.
;----------------------------------------------------------------------------------------------------------------------
;------[Retardo de 10 milisegundos]------
;----------------------------------------------------------------------------------------------------------------------
T10mS:
  			movlw     .55        			; 1 | Número de repeticiones externas (B)
        movwf     Contador1 			; 1 |
        	
L03:  	movlw     .181      			; 1 | Número de repeticiones internas (A)
        movwf     Contador2 			; 1 |
        	
L04:  	clrwdt              			; 1 | Limpia registro WDT.
				clrwdt              			; 1 | Limpia registro WDT.
        decfsz    Contador2,1  		; 1 + (1) ¿Se agotó? (A)
        goto      L04    					; 2 no, regresa.
        decfsz    Contador1,1 		; 1 + (1) ¿Se agotó? (B)
        goto      L03    					; 2 no, regresa
        	
        return              			; 2+2 Concluído.
;----------------------------------------------------------------------------------------------------------------------
;------[Retardo de 100 milisegundos]------
;----------------------------------------------------------------------------------------------------------------------
T100mS:
				movlw     .239      			; 1 Ajustar el número de repeticiones (B)
        movwf     Contador1     	; 1 |
        	
L05:  	movlw     .232      			; 1 Ajustar el número de repeticiones (A)
        movwf     Contador2     	; 1 |
        
L06:  	clrwdt              			; 1 Limpiar WDT
  			goto 	  	$ + 1         	; 2 Ciclos, retardo
		  	goto      $ + 1         	; 2 Ciclos, retardo
				clrwdt              			; 1 Ciclo, retardo

        decfsz    Contador2,1  		; 1 + (1) ¿Se agotó el tiempo? (A)
        goto      L06    					; 2 no, Regresa
        	
        decfsz    Contador1, 1 		; 1 + (1) ¿Se agotó el tiempo? (B)
        goto      L05    					; 2 no, Regresa
        	
		  	goto      $ + 1         	; 2 Ciclos, retardo
		  	goto 	  	$ + 1         	; 2 Ciclos, retardo
		 		goto      $ + 1         	; 2 Ciclos, retardo
				clrwdt              			; 1 Ciclo, retardo

        return              			; 2+2 Terminado
;----------------------------------------------------------------------------------------------------------------------
;------[Retardo de 1 Segundo]------
;----------------------------------------------------------------------------------------------------------------------
T1S:
  			movlw     .165      			; 1 Ajustar el número de repeticiones (C)
        movwf     Contador1     	; 1 |
L07:        	
  			movlw     .41       			; 1 Ajustar el número de repeticiones (B)
        movwf     Contador2     	; 1 |
L08:        	
  			movlw     .147      			; 1 Ajustar el número de repeticiones (A)
        movwf     Contador3     	; 1 |
L09:        	
  			clrwdt              			; 1 Limpiar el WDT
        clrwdt              			; 1 Retardo de un ciclo
        decfsz    Contador3,1   	; 1 + (1) ¿Se agotó el tiempo? (A)
        goto      L09    					; 2 no, Regresa
        decfsz    Contador2,1   	; 1 + (1) ¿Se agotó el tiempo? (B)
        goto      L08    					; 2 no, Regresa
        decfsz    Contador1,1   	; 1 + (1) ¿Se agotó el tiempo? (C)
        goto      L07    					; 2 no, Regresa
        	
        return              			; 2+2 Concluido.
;----------------------------------------------------------------------------------------------------------------------
;------[Retardo de 10 Segundos]------
;----------------------------------------------------------------------------------------------------------------------
T10S:
  			movlw     .183      			; 1 | Ajusta el número de repeticiones (C)
        movwf     Contador1     	; 1 |
L10:        	
				movlw     .190      			; 1 | Ajusta el número de repeticiones (B)
        movwf     Contador2     	; 1 |
L11:        	
				movlw     .239      			; 1 | Ajusta el número de repeticiones (A)
        movwf     Contador3     	; 1 |
L12:        	
		  	clrwdt              			; 1 | Limpia el "WDT"
  			goto 	  	$ + 1         	; 2 | Retardo de dos ciclos 

        decfsz    Contador3,1  		; 1 + (1) is the time over? (A)
        goto      L12    					; 2 no, loop
        	
        decfsz    Contador2,1 		; 1 + (1) ¿Se consumió el tiempo? (B)
        goto      L11    					; 2  NO, regresa
        	
        decfsz    Contador1,1 		; 1 + (1) ¿Se consumió el tiempo? (C)
        goto      L10    					; 2 NO, regresa
        	
  			goto 	  	$ + 1         	; 2 ciclos de retardo
 				clrwdt              			; 1 ciclo de retardo

        return              			; 2+2 Terminado
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

;			END
