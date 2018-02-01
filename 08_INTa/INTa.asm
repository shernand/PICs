;--------------------------------------------------------------------------------------------------
; Aplicación para generar una frecuencia de 100 kHz empleando el temporizador TMR0.
;--------------------------------------------------------------------------------------------------
	#INCLUDE "SFHM.asm"		; Datos iniciales + Infraestructura
;--------------------------------------------------------------------------------------------------
;-----[ CÓDIGO en PRUEBA ]-----
;--------------------------------------------------------------------------------------------------
; Lo siguiente se calcula para un cristal de 20 MHz, 200 nanosegundos por ciclo de reloj.
;
; Para el temporizador TMR0, sin pre-escalador, la cantidad de pulsos que deben ocurrir antes de 
; desbordarse (transitar desde 00.01.02.03...5A.5B...FE.FF.00) es de 256. Con un cristal de 
; 20 MegaHertz cada conteo o incremento ocurre cuando transcurren 200 nanosegundos.
;
; Para lograr que se desborde el contador de TMR0 después de que se consuman un "X" número de 
; ciclos, al TMR0 se le debe precargar un cierto valor. Por ejemplo, si se desea que se consuman 
; 45 ciclos, se le debe precargar un valor tal que 256 - (valor) = 45 ciclos. Para este caso TMR0 
; se debe precargar con un valor de 211.
; 
; En particular, si se deseara generar una señal de 100 kilohertz, a partir de conmutar una 
; terminal de un puerto, se debe calcular el tiempo que se debe mantener a un nivel de "1" 
; dicho pin y el tiempo que se debe mantener en "0". Cada conmutación (de 0->1 y de 1->0)
; deberá hacerse al DOBLE de la FRECUENCIA que se desea implementar, en otras palabras, si se 
; desea generar una señal de 100 KHz, se deberá conmutar la terminal (0->1 y 1->0) a una
; frecuencia de 200 KHz.

; Para generar una señal de una frecuencia de 100 KHz es necesario que la señal se mantenga por 
; 5 microsegundos en un estado de "1" y por otros 5 microsegundos en un estado de "0".
;
; La cuestión es: ¿Cuántos pulsos de reloj deben ocurrir en TMR0 antes de que se desborde y
; genera una interrupción cada 5 microsegundos? 
;
; Lo anterior se puede plantear de la siguiente manera: Para consumir 5 microSegundos (5 uS), 
; ¿Cuántos pulsos de 200 nS deben ocurrir?  Se tiene la siguiente información:
;
; --> 5 uS = 5,000 nS      
; --> si cada pulso dura 200 nS, entonces deben ocurrir 5,000 / 200 número de pulsos
; --> Lo anterior nos da un total de 25 pulsos.
;
; Se debe preajustar TMR0 a una cantidad igual a 256 - "X" = 25, en donde "X" es igual a 231.
;
; Comprobando, si cada pulso tarda 200 nS, 25 * 200 nS = 5,000 nS = 5 microSegundos (5 uS).
; Una forma de onda que tiene 5 uS en estado "1" y 5 uS en estado "0" tendrá una frecuencia de
; 100 KiloHertz, un ciclo completo tarda 10 uS.
;
; Con el valor calculado se generará una frecuencia de 100 KiloHertz.
;
; En resumen:
; 1.) Cada interrupción (ocurre cada 5 uS) origina el incremento de PORTB, lo cual pondrá en
; estado "0" (o en estado "1") la salida. Al siguiente incremento de PORTB, el cual ocurre 
; al generarse la siguiente interrupción, después de exactamente 5 uS), la salida de PORTB 
; se pondrá en estado "1" (o en estado "0"), continuando así eternamente.
; 2.) Con dos incrementos de PORTB se genera un ciclo completo (ocurrieron 10 uS), entonces
; se tiene una señal de 100 KiloHertz en la terminal "0" de PORTB.
;
; Para el código del programa quedaría:
; El valor de precarga es (256 - "X") = 25, de donde "X" = 231
; El valor de precarga de TMR0 se propondrá en la etiqueta TMR0_Precarga.
;
; Para fines prácticos se debe considerar una sobrecarga ("overhead") que ocurre cuando se ejecutan
; instrucciones adicionales dentro de la ISR, la subrutina que atiende la interrupción.
; También se debe tener en cuenta en este ejemplo que se requerirá de que la ISR se ejecute 
; dos (2) veces para completar un ciclo (10 uS).
; 
;----
TMR0_Precarga:  EQU		.231 + .11		; El último valor es para compensar un "overhead".
																		; El valor de 11 se estima (por tanteo, ensayo y error)
;----
;--------------------------------------------------------------------------------------------------
;[7]OPTION_REG.RBPU		-> PORTB Pull-up Enable  (1 = Disabled; 0 = Enabled by individual port latch)		
;[6]OPTION_REG.INTDEG -> Interrupt Edge Select (1 = Rising edge; 0 = Falling edge of RB0/INT pin)
;[5]OPTION_REG.T0CS		-> Clock Source Select   (1 = RA4/T0CKI pin; 0 = CLKOUT)
;[4]OPTION_REG.T0SE 	-> Source Edge Select    (1 = high-to-low; 0 = low-to-high on RA4/T0CKI pin)
;[3]OPTION_REG.PSA  	-> Prescaler Assignment  (1 = Prescaler to WDT; 0 = Prescaler to the Timer0)
;[2]OPTION_REG.PS2  	-> Prescaler Rate Select - 2
;[1]OPTION_REG.PS1		-> Prescaler Rate Select - 1
;[0]OPTION_REG.PS0  	-> Prescaler Rate Select - 0

; Bit Value  TMR0 Rate	 WDT Rate
;---------------------------------
;   000				1 : 2				1 : 1
;		001				1 : 4				1 : 2
;		010				1 : 8				1 : 4
;		011				1 : 16			1 : 8
;		100				1 : 32			1 : 16
;		101				1 : 64			1 : 32
;		110				1 : 128			1 : 64
;		111				1 : 256			1 : 128
;***************************************************************************************************
Principal:
	SelBanco	TRISB
	movlw			b'00000000'
	movwf 		TRISB
	
	SelBanco 	OPTION_REG
	movlw 		b'00001000'				; Preescalador en 1, el preescalador se asigna a WDT
	movwf 		OPTION_REG
	
	SelBanco	0x00
	movlw			TMR0_Precarga			; Carga TMR0, 0xE7.
	movwf			TMR0

;--------------------------------------------------------------------------------------------------
;[7]INTCON.GIE	-> Global Interrupt Enable bit
;[6]INTCON.PEIE	-> Peripheral Interrupt Enable bit
;[5]INTCON.T0IE	-> TMR0 Overflow Interrupt Enable bit
;[4]INTCON.INTE	-> RB0/INT External Interrupt Enable bit
;[3]INTCON.RBIE	-> RB Port Change Interrupt Enable bit
;[2]INTCON.T0IF	-> TMR0 Overflow Interrupt Flag bit
;[1]INTCON.INTF	-> RB0/INT External Interrupt Flag bit
;[0]INTCON.RBIF	-> RB Port Change Interrupt Flag bit
;--------------------------------------------------------------------------------------------------
	movlw			b'10100000'	; Autoriza Interrupciones en general (GIE)...
	movwf			INTCON			; ...e Interrupción por desbordamiento del TIMER 0
Aqui:										; 
	goto 	$						   	; Ciclo vacío.
;-----[ ISR_Timer0 ]----- 
; En un PIC que trabaja a una frecuencia de 20 MHz, TMR0 se incrementa cada 200 nanosegundos.
; Para conseguir un retardo de 5 µs con un preescalador de 1 el TMR0 tiene que contar 25 pulsos
; .2 µs x 25 x 1 = 5 µs.
;***************************************************************************************************
ISR:
  movlw			TMR0_Precarga		; Carga el TMR0, para que regrese a esta ISR en un
	movwf			TMR0          	; tiempo específico, después de consumir "x" ciclos.
	incf 			PORTB,F					; Cada pasada por esta interrupción incrementa en "1" a PORTB
  bcf				INTCON,T0IF			; Repone la bandera de ocurrencia de interrupción del TMR0,
                           	; Se ACEPTAN otras interrupciones.
	retfie
;***************************************************************************************************
	END
;***************************************************************************************************
;--------------------------------------------------------------------------------------------------
;-----[ Rutina que ATIIENDE la INTERRUPCIONES ]-----
;ISR:
; Preservación de los valores de "W", "STATUS" y Registros importantes
	;movwf		Temp_W					; Guarda el valor actual de "w".
	;swapf		STATUS,W				; No usar "movf STATUS,W", altera "Z"
	;movwf		Temp_STATUS
;	...
;	...
	;SelBanco	0x000					; Para asegurare que se está dentro del BANCO "0"
;	(SUBRUTINA que ATIENDE a la INTERRUPCIÓN) ...
; Restauración de los valores de "W", "STATUS" y Registros importantes	
	;swapf		Temp_STATUS, W	; Restaura STATUS
	;movwf		STATUS
	;swapf		Temp_W, F				; Restaura W
	;swapf		Temp_W, W
	;retfie                	; Regresa de la atención a la INTERRUPCIÓN.
;--------------------------------------------------------------------------------------------------