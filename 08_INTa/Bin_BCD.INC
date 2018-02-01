;--------------------------------------------------------------------------------------------------
;-----[ Subs de CONVERSIONES ]-----
; Aquí estarán todas las subrutinas que realicen conversiones entre números o caracteres de 
; diversas bases
;--------------------------------------------------------------------------------------------------
;-----[ Sub BIN_a_BCD ]-----
; Un número binario natural de 8 bits [0:255] es convertido a BCD. El resultado se guarda en tres
; posiciones de memorias llamadas: BCD_Centenas, BCD_Decenas y BCD_Unidades.
;
; El procedimiento utilizado es mediante restas sucesivas de 10.
; Entrada:	En el registro W el número binario natural a convertir.
; Salidas:	En (BCD_Centenas), (BCD_Decenas) y (BCD_Unidades).
;						En "W" también se guardan decenas (nibble alto) y unidades (nibble bajo).
;--------------------------------------------------------------------------------------------------
	CBLOCK									; En las subrutinas no se debe fijar la dirección
		BCD_Centenas					; de la RAM de usuario. Se toma a continuación de la última asignada.
		BCD_Decenas						; 
		BCD_Unidades					; SUSTITUIR esta estructura por ASIGNACIÓN - LIBERACIÓN de Variables
	ENDC										;  - con M A C R O S -

BIN_a_BCD:
	clrf	BCD_Centenas			; En estos registros se guarda el resultado.
	clrf	BCD_Decenas				; Inicialmente se ajustan a cero.
	movwf	BCD_Unidades			; Número Binario a convertir.
BCD_Resta10:
	movlw	.10								; Se le resta  las unidades 10 en cada iteración.
	subwf	BCD_Unidades,W		; (W)=(BCD_Unidades) -10.
	btfss	STATUS,C					; ¿C = 1?, ¿(W) positivo?, ¿(BCD_Unidades)>=10? (Resultado "cupo")
	goto 	BIN_BCD_Fin				; No, el resultado fue menor a 10. Ya se terminó el proceso.
BCD_IncrementaDecenas:
	movwf	BCD_Unidades			; Recupera lo que queda por restar.
	incf	BCD_Decenas,F			; Incrementa las decenas y comprueba si ya son iguales a 10
	movlw	.10								; Lo hace mediante una resta.
	subwf	BCD_Decenas,W			; (W)=(BCD_Decenas)-10).
	btfss	STATUS,C					; ¿C = 1?, ¿(W) positivo?, ¿(BCD_Decenas)>=10?
	goto	BCD_Resta10				; No fue así. Vuelve a dar otra pasada, restándole 10 a las unidades
BCD_IncrementaCentenas:		; 
	clrf	BCD_Decenas				; Decenas <- 0x00
	incf	BCD_Centenas,F		; Centenas++
	goto	BCD_Resta10				; Otra iteración...
BIN_BCD_Fin:
	swapf	BCD_Decenas,W			; En el nibble alto de (W) también están las Decenas.
	addwf	BCD_Unidades,W		; En el nibble bajo de (W) las Unidades.
	return									; Retorna a quien invocó.
;--------------------------------------------------------------------------------------------------

;	END										; Se omite en este segmento.
