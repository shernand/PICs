;******************************************************************************
;		RUTINAS GENERALES DE RETARDOS DE TIEMPO
;
; Están construidas para un cristal de 20 MHz.
; Cada ciclo consumido es de 200 nanoSegundos.
;
;	R_10uS:		Retardo de 10 microSegundos
;	R_20uS:		Retardo de 20 microSegundos
;	R_50uS:		Retardo de 50 microSegundos
;	R_100uS:	Retardo de 100 microSegundos
;	R_200uS:	Retardo de 200 microSegundos
;	R_500uS:	Retardo de 500 microSegundos
;	R_1mS:		Retardo de 1 miliSegundo
;	R_2mS:		Retardo de 2 miliSegundos
;	R_5mS:		Retardo de 5 miliSegundos
;	R_10mS:		Retardo de 10 miliSegundos
;	R_20mS:		Retardo de 20 miliSegundos
;	R_50mS:		Retardo de 50 miliSegundos
;	R_100mS:	Retardo de 100 miliSegundos
;	R_200mS:	Retardo de 200 miliSegundos
;	R_500mS:	Retardo de 500 miliSegundos
;	R_1S:		Retardo de 1 Segundo
;	R_2S:		Retardo de 2 Segundos
;	R_5S:		Retardo de 5 Segundos
;	R_10S:		Retardo de 10 Segundos
;	R_20S:		Retardo de 20 Segundos
;
;	Ejemplo de uso:
;
;	call	R_10uS	; Retardo de 10 microsegundos, incluyendo "call + return"

;******************************************************************************
;----------[V A R I A B L E S    U S A D A S]----------

;	Debe estar definido en el inicio de la aplicación:
;
;	CBLOCK	InicioBanco0
;		Temp0
;		Temp1
;		Temp2
;		Temp3
;
;
;	ENDC

;-------------------------------------------------------------
; Para generar una espera de 500 nanoSegundos (2 ciclos de 
; retardo) se puede usar el siguiente segmento en línea con 
; el código que requiera el retardo:
;
;	goto $ + 1	; Retardo de 2 ciclos
;Etiqueta:
;-------------------------------------------------------------
; Para generar una espera de 1000 nanoSegundos = 1 microsegundo
; (retardo de 5 ciclos)se puede usar el siguiente segmento en 
; línea con el código que requiera el retardo:
;
;	goto $ + 1	; Retardo de 2 ciclos
;	goto $ + 1	; Retardo de 2 ciclos
;	clrwdt      ; Retardo de 1 ciclo
;-------------------------------------------------------------
; Descripcion: Delay 50 ciclos
;-------------------------------------------------------------
R_10uS:
	movlw     .11		; 1 set numero de repeticion 
 	movwf     Temp1 	; 1 |

  	clrwdt         		; 1 clear watchdog
  	decfsz    Temp1, 1  ; 1 + (1) es el tiempo 0  ?
 	goto      $ - .2    ; 2 no, loop
	clrwdt              ; 1 ciclo delay
 	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 100 ciclos
;-------------------------------------------------------------
R_20uS:
  	movlw	.23       	; 1 set numero de repeticion 
  	movwf	Temp1     	; 1 |

  	clrwdt              ; 1 clear watchdog
   	decfsz	Temp1, 1  	; 1 + (1) es el tiempo 0  ?
   	goto	$ - .2     	; 2 no, loop

  	goto	$ + .1      ; 2 ciclos delay

  	clrwdt              ; 1 ciclo delay
   	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 250 ciclos
;-------------------------------------------------------------
R_50uS:
  	movlw     .61       ; 1 set numero de repeticion 
   	movwf     Temp1     ; 1 |

  	clrwdt              ; 1 clear watchdog
  	decfsz    Temp1, 1  ; 1 + (1) es el tiempo 0  ?
  	goto      $ - .2    ; 2 no, loop
 	clrwdt              ; 1 ciclo delay
    return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 500 ciclos
;-------------------------------------------------------------
R_100uS:
	movlw 	.123		; 1 set numero de repeticion 
  	movwf	Temp1    	; 1 |

  	clrwdt              ; 1 clear watchdog
	decfsz	Temp1, 1  	; 1 + (1) es el tiempo 0  ?
	goto 	$ - .2    	; 2 no, loop

  	goto	$ + .1      ; 2 ciclos delay

  	clrwdt              ; 1 ciclo delay
  	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 1000 ciclos
;-------------------------------------------------------------
R_200uS:
	movlw	.248      	; 1 set numero de repeticion 
 	movwf  	Temp1     	; 1 |

	clrwdt              ; 1 clear watchdog
 	decfsz	Temp1, 1  	; 1 + (1) es el tiempo 0  ?
  	goto   	$ - .2   	; 2 no, loop

  	goto 	$ + .1   	; 2 ciclos delay
 
	clrwdt              ; 1 ciclo delay
   	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 2500 ciclos
;-------------------------------------------------------------
R_500uS:
	movlw	.7        	; 1 set numero de repeticion  (B)
 	movwf  	Temp1     	; 1 |
  
	movlw 	.88       	; 1 set numero de repeticion  (A)
 	movwf 	Temp2     	; 1 |

  	clrwdt              ; 1 clear watchdog
  	decfsz	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
 	goto  	$ - .2    	; 2 no, loop
  	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (B)
  	goto   	$ - .6    	; 2 no, loop
 
	goto 	$ + .1    	; 2 ciclos delay

	clrwdt              ; 1 ciclo delay
   	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 5000 ciclos
;-------------------------------------------------------------
R_1mS:
	movlw 	.6        	; 1 set numero de repeticion  (B)
 	movwf  	Temp1     	; 1 |
 
	movlw 	.207      	; 1 set numero de repeticion  (A)
  	movwf  	Temp2     	; 1 |
  
	clrwdt              ; 1 clear watchdog
	decfsz 	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
   	goto    $ - .2    	; 2 no, loop
  	decfsz 	Temp1,  1 	; 1 + (1) es el tiempo 0  ? (B)
  	goto   	$ - .6    	; 2 no, loop
 
	goto 	$ + .1    	; 2 ciclos delay
  
	clrwdt              ; 1 ciclo delay
  	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 10000 ciclos
;-------------------------------------------------------------
R_2mS:
	movlw	.8        	; 1 set numero de repeticion  (B)
  	movwf 	Temp1     	; 1 |

	movlw 	.249      	; 1 set numero de repeticion  (A)
 	movwf  	Temp2     	; 1 |

	clrwdt              ; 1 clear watchdog
	clrwdt              ; 1 ciclo delay
	decfsz	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
	goto   	$ - .3    	; 2 no, loop
  	decfsz 	Temp1,  1 	; 1 + (1) es el tiempo 0  ? (B)
  	goto  	$ - .7    	; 2 no, loop

	goto 	$ + .1    	; 2 ciclos delay

	clrwdt              ; 1 ciclo delay
	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 25000 ciclos
;-------------------------------------------------------------
R_5mS:
	movlw 	.44       	; 1 set numero de repeticion  (B)
   	movwf  	Temp1     	; 1 |

	movlw 	.141      	; 1 set numero de repeticion  (A)
  	movwf  	Temp2     	; 1 |

	clrwdt              ; 1 clear watchdog
  	decfsz	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
   	goto    $ - .2    	; 2 no, loop
   	decfsz 	Temp1,  1 	; 1 + (1) es el tiempo 0  ? (B)
  	goto    $ - .6    	; 2 no, loop
 
	goto 	$ + .1     	; 2 ciclos delay
 
	clrwdt              ; 1 ciclo delay
	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 50000 ciclos
;-------------------------------------------------------------
R_10mS:
	movlw 	.55       	; 1 set numero de repeticion  (B)
	movwf  	Temp1     	; 1 |

	movlw  	.181      	; 1 set numero de repeticion  (A)
  	movwf  	Temp2     	; 1 |
  
	clrwdt              ; 1 clear watchdog
	clrwdt              ; 1 ciclo delay
	decfsz 	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
   	goto  	$ - .3    	; 2 no, loop
  	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (B)
   	goto  	$ - .7    	; 2 no, loop
  	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 100000 ciclos
;-------------------------------------------------------------
R_20mS:
	movlw 	.110      	; 1 set numero de repeticion  (B)
	movwf  	Temp1     	; 1 |
 
	movlw 	.181      	; 1 set numero de repeticion  (A)
 	movwf  	Temp2     	; 1 |
  
	clrwdt              ; 1 clear watchdog
	clrwdt              ; 1 ciclo delay
	decfsz	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
 	goto  	$ - .3    	; 2 no, loop
  	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (B)
   	goto   	$ - .7    	; 2 no, loop
  
	goto 	$ + .1      ; 2 ciclos delay

	goto 	$ + .1      ; 2 ciclos delay

	clrwdt              ; 1 ciclo delay
   	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 250000 ciclos
;-------------------------------------------------------------
R_50mS:
	movlw	.197      	; 1 set numero de repeticion  (B)
 	movwf  	Temp1     	; 1 |
  
	movlw  	.253      	; 1 set numero de repeticion  (A)
 	movwf  	Temp2     	; 1 |
  
	clrwdt              ; 1 clear watchdog
	clrwdt              ; 1 ciclo delay
	decfsz	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
  	goto  	$ - 3    	; 2 no, loop
  	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (B)
  	goto  	$ - .7    	; 2 no, loop
  
	goto 	$ + .1    	; 2 ciclos delay
 
   	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 500000 ciclos
;-------------------------------------------------------------
R_100mS:
	movlw 	.239      	; 1 set numero de repeticion  (B)
  	movwf  	Temp1     	; 1 |

	movlw  	.232      	; 1 set numero de repeticion  (A)
   	movwf  	Temp2     	; 1 |

	clrwdt              ; 1 clear watchdog

	goto 	$ + .1    	; 2 ciclos delay

	goto 	$ + .1     	; 2 ciclos delay

	clrwdt              ; 1 ciclo delay
	decfsz 	Temp2, 1  	; 1 + (1) es el tiempo 0  ? (A)
   	goto   	$ - .5    	; 2 no, loop
  	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (B)
   	goto    $ - .9		; 2 no, loop
 
	goto 	$ + .1     	; 2 ciclos delay
 
	goto 	$ + .1   	; 2 ciclos delay

	goto 	$ + .1      ; 2 ciclos delay

	clrwdt              ; 1 ciclo delay
  	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 1000000 ciclos
;-------------------------------------------------------------
R_200mS:
	movlw	.14      	; 1 set numero de repeticion  (C)
   	movwf  	Temp1     	; 1 |
 
	movlw  	.72       	; 1 set numero de repeticion  (B)
  	movwf  	Temp2     	; 1 |
 
	movlw  	.247      	; 1 set numero de repeticion  (A)
   	movwf  	Temp3     	; 1 |

	clrwdt              ; 1 clear watchdog
	decfsz 	Temp3, 1  	; 1 + (1) es el tiempo 0  ? (A)
  	goto   	$ - .2    	; 2 no, loop
  	decfsz 	Temp2, 1 	; 1 + (1) es el tiempo 0  ? (B)
  	goto  	$ - .6    	; 2 no, loop
   	decfsz 	Temp1,  1 	; 1 + (1) es el tiempo 0  ? (C)
   	goto	$ - .10   	; 2 no, loop
 
	goto 	$ + .1    	; 2 ciclos delay
 
	clrwdt              ; 1 ciclo delay
	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 2500000 ciclos
;-------------------------------------------------------------
R_500mS:
	movlw  	.22       	; 1 set numero de repeticion  (C)
   	movwf 	Temp1     	; 1 |

	movlw	.134      	; 1 set numero de repeticion  (B)
   	movwf  	Temp2     	; 1 |
  
	movlw 	.211      	; 1 set numero de repeticion  (A)
  	movwf  	Temp3     	; 1 |

	clrwdt              ; 1 clear watchdog
   	decfsz	Temp3, 1  	; 1 + (1) es el tiempo 0  ? (A)
  	goto   	$ - .2    	; 2 no, loop
  	decfsz	Temp2, 1 	; 1 + (1) es el tiempo 0  ? (B)
   	goto   	$ - .6    	; 2 no, loop
   	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (C)
   	goto  	$ - .10    	; 2 no, loop

	goto 	$ + .1    	; 2 ciclos delay
  
	clrwdt              ; 1 ciclo delay
	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 5000000 ciclos
;-------------------------------------------------------------
R_1S:
	movlw	.165      	; 1 set numero de repeticion  (C)
   	movwf  	Temp1     	; 1 |
 
	movlw  	.41       	; 1 set numero de repeticion  (B)
   	movwf  	Temp2     	; 1 |
 
	movlw  	.147      	; 1 set numero de repeticion  (A)
  	movwf  	Temp3     	; 1 |
  
	clrwdt              ; 1 clear watchdog
	clrwdt              ; 1 ciclo delay
	decfsz 	Temp3, 1  	; 1 + (1) es el tiempo 0  ? (A)
  	goto  	$ - .3    	; 2 no, loop
	decfsz 	Temp2, 1 	; 1 + (1) es el tiempo 0  ? (B)
	goto   	$ - .7    	; 2 no, loop
  	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (C)
  	goto   	$ - .11    	; 2 no, loop
   	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 10000000 ciclos
;-------------------------------------------------------------
R_2S:
	movlw 	.43       	; 1 set numero de repeticion  (C)
 	movwf  	Temp1     	; 1 |

	movlw	.226      	; 1 set numero de repeticion  (B)
  	movwf  	Temp2     	; 1 |

	movlw 	.205      	; 1 set numero de repeticion  (A)
  	movwf  	Temp3     	; 1 |
  
	clrwdt              ; 1 clear watchdog
	clrwdt              ; 1 ciclo delay
	decfsz 	Temp3, 1  	; 1 + (1) es el tiempo 0  ? (A)
  	goto   	$ - .3    	; 2 no, loop
	decfsz 	Temp2, 1 	; 1 + (1) es el tiempo 0  ? (B)
	goto  	$ - .7    	; 2 no, loop
	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (C)
	goto  	$ - .11    	; 2 no, loop
	clrwdt              ; 1 ciclo delay
  	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 25000000 ciclos
;-------------------------------------------------------------
R_5S:
	movlw	.106      	; 1 set numero de repeticion  (C)
	movwf 	Temp1     	; 1 |
  
	movlw 	.135      	; 1 set numero de repeticion  (B)
  	movwf  	Temp2     	; 1 |
  
	movlw  	.249      	; 1 set numero de repeticion  (A)
   	movwf  	Temp3     	; 1 |
  
	clrwdt              ; 1 clear watchdog

	goto 	$ + .1    	; 2 ciclos delay
 
	clrwdt              ; 1 ciclo delay
   	decfsz	Temp3, 1  	; 1 + (1) es el tiempo 0  ? (A)
	goto   	$ - .4    	; 2 no, loop
  	decfsz 	Temp2, 1 	; 1 + (1) es el tiempo 0  ? (B)
  	goto   	$ - .8    	; 2 no, loop
 	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (C)
  	goto   	$ - .12    	; 2 no, loop
  	clrwdt              ; 1 ciclo delay
	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 50000000 ciclos
;-------------------------------------------------------------
R_10S:  
	movlw  	.183      	; 1 set numero de repeticion  (C)
  	movwf  	Temp1     	; 1 |
  
	movlw 	.190      	; 1 set numero de repeticion  (B)
	movwf  	Temp2     	; 1 |

	movlw 	.239      	; 1 set numero de repeticion  (A)
	movwf  	Temp3     	; 1 |

	clrwdt              ; 1 clear watchdog

	goto 	$ + .1     	; 2 ciclos delay

	decfsz	Temp3, 1  	; 1 + (1) es el tiempo 0  ? (A)
	goto   	$ - .3    	; 2 no, loop
	decfsz 	Temp2, 1 	; 1 + (1) es el tiempo 0  ? (B)
	goto  	$ - .7    	; 2 no, loop
	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (C)
	goto   	$ - .11    	; 2 no, loop

	goto 	$ + .1  	; 2 ciclos delay
  
	clrwdt              ; 1 ciclo delay
	return              ; 2+2 Fin.
;-------------------------------------------------------------
; Descripcion: Delay 100000000 ciclos
;-------------------------------------------------------------
R_20S:
	movlw	.147  		; 1 set numero de repeticion  (C)
	movwf  	Temp1     	; 1 |
PLoop0  
	movlw	.249      	; 1 set numero de repeticion  (B)
	movwf  	Temp2     	; 1 |
PLoop1  
	movlw 	.248      	; 1 set numero de repeticion  (A)
  	movwf  	Temp3     	; 1 |
PLoop2  
	clrwdt              ; 1 clear watchdog
PDelL1  
	goto 	PDelL2 		; 2 ciclos delay
PDelL2
	goto 	PDelL3		; 2 ciclos delay
PDelL3
	goto 	PDelL4 		; 2 ciclos delay
PDelL4
	clrwdt              ; 1 ciclo delay
	decfsz 	Temp3, 1		; 1 + (1) es el tiempo 0  ? (A)
	goto 	PLoop2    	; 2 no, loop
	decfsz 	Temp2, 1 	; 1 + (1) es el tiempo 0  ? (B)
	goto   	PLoop1    	; 2 no, loop
	decfsz 	Temp1, 1 	; 1 + (1) es el tiempo 0  ? (C)
	goto  	PLoop0    	; 2 no, loop
PDelL5  
	goto 	PDelL6 		; 2 ciclos delay
PDelL6  
	goto 	PDelL7  	; 2 ciclos delay
PDelL7  
	goto 	PDelL8  	; 2 ciclos delay
PDelL8  
	goto 	PDelL9   	; 2 ciclos delay
PDelL9  
	goto 	PDelL10  	; 2 ciclos delay
PDelL10 
	clrwdt              ; 1 ciclo delay
 	return              ; 2+2 Fin.
;-------------------------------------------------------------
