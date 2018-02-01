;******************************************************************************
; Programa que realiza el producto de dos bytes FACTOR1 y FACTOR2.
; El resultado se almacena en las localidades: Binario_ALTO y Binario_BAJO
; 
; Para probarlo, cargar valores en FACTOR1 y FACTOR2 y ejecutar este programa
;******************************************************************************
	LIST p=16F877A
	INCLUDE "p16f877a.inc"	;Fichero que incluye info del uC a usarse.

; Reserva de localidades de memoria para variables y apuntadores.
	CBLOCK	0x20
		Factor1, Factor2					;Localidades que guardan los DATOS de ENTRADA.
		SumaAlto, SumaBajo				;Localidades para ir cargando FACTOR1 desplazado.
    BinarioAlto,BinarioBajo		;Localidades de memoria para el resultado.
 		Contador     							;Contador de desplazamientos.
	ENDC
;******************************************************************************	
	ORG	0
	CALL	Producto							; Esta es la subrutina que podr� incluirse en
															; aplicaciones.
Espera:
	GOTO	Espera								; Para atrapar en esta parte el ensayo.
;******************************************************************************
; Subrutina para realizar la multiplicaci�n de dos bytes.
;
; Recibe los valores de entrada en las localidades de memoria
; Factor1 y Factor2
;
; Entrega el resultado en dos bytes: BinarioAlto y BinarioBajo.
;***************************************************************************
;Inicio de la Subrutina, puede ser otra la direcci�n inicial.
	ORG     0x120
Producto:
	clrf	SumaAlto			;Se ajusta a cero la parte ALTA del SUMANDO.
	clrf	BinarioAlto	;Se pone a cero la parte ALTA y BAJA del ACUMULADOR
	clrf	BinarioBajo	;de los resultados
	
	movlw	0x08					;El CONTADOR de operaciones de rotaci�n se...
	movwf	Contador			;...ajusta a 8

	movf	Factor1,W			;Factor1 se carga en la parte baja del sumando...
	movwf	SumaBajo			;...para aqu� efectuar las rotaciones

A_Sumar:
	rrf	Factor2, F				;Rotaci�n a la derecha para comprobar si este bit
	btfss	STATUS,C				;est� en "0" o en "1" a trav�s del bit de "carry".
	goto	Otro_Bit				;Si este bit era un "0", no hay nada que sumar.
	movf	SumaBajo,W			;Si este bit era "1", habr� que sumar la parte BAJA... 
	addwf	BinarioBajo,F	  ;...del acumulador con el sumando que corresponde... 
												;...al Factor1 previamente desplazado a la izquierda.
	btfsc	STATUS,C				;comprobamos si hubo acarreo en esa suma
	incf	BinarioAlto, F	;Si lo hubiera, sumamos 1 al siguiente byte
	movf	SumaAlto,W			;sumamos la parte alta del acumulador con
	addwf	BinarioAlto,F	  ;el Factor1 anteriormente desplazado.

Otro_Bit:	
	decfsz	Contador,F		;Decrementamos el contador de operaciones parciales
	goto	A_Rotar					;si no hemos llegado a cero, seguimos rotando
	return								;si ya hemos hecho 8 veces la operaci�n, �se termin�!

A_Rotar:
	bcf	STATUS,C					;Para rotar Factor1 a la izquierda, carry = 0.
	rlf	SumaBajo,F				;rotamos encadenando la parte baja...
	rlf	SumaAlto,F	      ;...con la parte alta
	goto A_Sumar					;Comprobando si es necesario sumar o no.

	END
