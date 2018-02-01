;--------------------------------------------------------------------------------------------------
;-----[ TECLADO.INC ]-----
; Subrutinas para el manejo de un teclado matricial (4 x 4) conectado al Puerto D
;--------------------------------------------------------------------------------------------------
;
;	 	 	      RD4  RD5  RD6  RD7
;		 	       ^    ^    ^    ^
;			    |----|----|----|----|
;	RD0 -->	|  0 |  1 |  2 |  3 |
;			    |----|----|----|----|
;	RD1 -->	|  4 |  5 |  6 |  7 |
;			    |----|----|----|----|
;	RD2 -->	|  8 |  9 | 10 | 11 |
;			    |----|----|----|----|
;	RD3 -->	| 12 | 13 | 14 | 15 |
;			    |----|----|----|----|
;
; Los números dentro de cada recuadro indican el orden de las teclas (esto no tienen por qué 
; coincidir con la serigrafiado que tengan dichas teclas). Se emplea una Tabla para calcular
; el valor que se entregará al oprimir una tecla en particular, en función del orden que
; guarde dentro de la matriz. 
;
;-----[ ZONA DE DATOS ]-----
;
	CBLOCK
		Tecl_TeclaOrden								; Orden de la tecla a revisar.
	ENDC

Tecl_UltimaTecla	EQU	d'15'				; Posición de la última tecla utilizada.

;--------------------------------------------------------------------------------------------------
;-----[ Sub "Teclado_LeeHex" ]-----
;
; Cada tecla tiene asignado un número de orden que es contabilizado en la variable
; Tecl_TeclaOrden. Para convertir a su valor según el tipo de teclado en concreto se
; utiliza una tabla de conversión. 
; A continuación se expone la relación entre el número de orden de la tecla y los
; valores correspondientes para el teclado hexadecimal más utilizado.
;
;	    ORDEN DE TECLA:		TECLADO HEX. UTILIZADO:
;		  0   1   2   3 			7  8  9  /
;		  4   5   6   7 			4  5  6  X
;		  8   9  10  11 			1  2  3  -
;		 12  13  14  15 			*  0  =  +
;
; Así, en este ejemplo, la tecla con la serigrafía "7" ocupa el orden "0"; la tecla "/" 
; ocupa el orden "3" y la tecla "=" el orden "14".

; Si cambia la serigrafía del teclado habrá que cambiar de tabla de conversión.
;
; Entrada:	En (W) el orden de la tecla pulsada [0x00..0x0F]
; Salida:	  En (W) el valor (Hexadecimal o ASCII, según el caso) del código de la tecla
; que estuviera en la posición correspondiente.
;--------------------------------------------------------------------------------------------------
Teclado_LeeHex:
	call		Teclado_LeeOrdenTecla			; Lee el Orden de la tecla pulsada.
	btfss		STATUS,C									; ¿Se pulsó alguna tecla?, ¿Cy=1?
	goto		Tecl_FinLeeHex						; No, no hay nada que hacer, se terminó.
	call		Tecl_ConvierteOrdenEnHex	; Obtén el código de la tecla oprimida en la tabla.
	bsf			STATUS,C									; Vuelve a posicionar el Carry, porque la
Tecl_FinLeeHex:											; instrucción "addwf PCL,F" lo pone a "0".
	return
;--------------------------------------------------------------------------------------------------
Tecl_ConvierteOrdenEnHex:
	addwf		PCL,F											; Para el teclado utilizado:
	DT			0x37, 0x38, 0x39, 0x41		; Primera fila del teclado.
	DT			0x34, 0x35, 0x36, 0x42		; Segunda fila del teclado
	DT			0x31, 0x32, 0x33, 0x43		; Tercera fila del teclado.
	DT			0x46, 0x30, 0x45, 0x44		; Cuarta fila del teclado.
Teclado_FinTablaHex:
;
; Esta tabla se sitúa al principio de la librería con el propósito de que no supere la
; posición 0FFh de memoria ROM de programa (¡REVISAR!). De todas formas, en caso que así fuera 
; visualizaría el siguiente mensaje de error en el proceso de ensamblado:
;
;	IF (Teclado_FinTablaHex > 0xFF)
;		ERROR	"Atención: La tabla ha superado el tamaño de la página de los"
;		MESSG	"primeros 256 bytes de memoria ROM. NO funcionará correctamente."
;	ENDIF
;--------------------------------------------------------------------------------------------------	
;-----[ Sub "Teclado_Inicializa" ]----- 
;
; Esta subrutina configura las líneas del Puerto D según la conexión del teclado realizada
; y comprueba que no esté oprimida alguna tecla al principio.

Teclado_Inicializa:
	SelBanco	TRISD									; Selecciona el Banco adecuado
	movlw			b'11110000'						; <RD7:RD4> Entradas, <RD3:RD0> Salidas
	movwf			TRISD
	SelBanco	0x00									; Regresa al Banco 0

Teclado_Comprobacion	EQU	b'11110000'
;-----[ Sub EsperaDejePulsar ]-----
; Permanece aquí mientras esté oprimida una tecla.
Teclado_EsperaDejePulsar:
	movlw		Teclado_Comprobacion	; Pone a cero las cuatro líneas de salida del 
	movwf		PORTD									; Puerto D.
Teclado_SigueEsperando:
	call		T10mS									; Espera por 20 milisegundos. [Experimentar]
	call		T10mS	
	movf		PORTD,W								; Lee el Puerto D.
	sublw		Teclado_Comprobacion	; Si es lo mismo que escribió es que ya no está oprimida 
	btfss		STATUS,Z							; tecla alguna.
	goto		Teclado_SigueEsperando
	return
;
; Subrutina "Teclado_LeeOrdenTecla" -----------------------------------------------------
;
; Lee el teclado, obteniendo el orden de la tecla pulsada. 
;
; Salida:	En (W) el número de orden de la tecla pulsada. Además Carry se pone a "1" si
;			se pulsa una tecla ó a "0" si no se pulsa tecla alguna.
;
Teclado_LeeOrdenTecla:
	clrf		Tecl_TeclaOrden			; Todavía no ha empezado a chequear el teclado.
	movlw		b'11111110'					; Va a chequear primera fila.
Tecl_ChequeaFila:							; (Ver esquema de conexión).
	movwf		PORTD								; Activa la fila correspondiente.
	call		T1mS								; Espera un milisegundo.
Tecl_Columna1:
	btfss		PORTD,4							; Chequea la 1ª columna buscando un cero. 
	goto		Tecl_GuardaValor		; Sí, es cero y por tanto guarda su valor y sale.
	incf		Tecl_TeclaOrden,F		; Va a chequear la siguiente tecla.
Tecl_Columna2:								; Repite proceso para las siguientes 
	btfss		PORTD,5							; columnas.
	goto		Tecl_GuardaValor
	incf		Tecl_TeclaOrden,F
Tecl_Columna3:		
	btfss		PORTD,6
	goto		Tecl_GuardaValor
	incf		Tecl_TeclaOrden,F
Tecl_Columna4:	
	btfss		PORTD,7
	goto		Tecl_GuardaValor
	incf		Tecl_TeclaOrden,F
;
; Comprueba si ya se revisó la última tecla, si así fue, concluyó. Prueba si
; el contenido del registro Tecl_TeclaOrden es igual al número de teclas.
;
Tecl_TerminaColumnas:
	movlw		Tecl_UltimaTecla
	subwf		Tecl_TeclaOrden,W		; (W) = (Tecl_TeclaOrden)-Tecl_UltimaTecla.
	btfsc		STATUS,C						; ¿C=0?, ¿(W) negativo?, ¿(Tecl_TeclaOrden)<15?
	goto		Tecl_NoPulsada			; No, se ha llegado al final del chequeo.
	bsf			STATUS,C						; Sí. Va a chequear la siguiente fila.
	rlf			PORTD,W							; Apunta a la siguiente fila.
	goto		Tecl_ChequeaFila	
Tecl_NoPulsada:
	bcf			STATUS,C						; Posiciona C=0, indicando que no ha pulsado
	goto		Tecl_FinTecladoLee	; tecla alguna y sale.
Tecl_GuardaValor:
	movf		Tecl_TeclaOrden,W		; El orden de la tecla pulsada en (W) y sale.
	bsf			STATUS,C						; Como hay tecla tecla pulsada, pone C=1. 
Tecl_FinTecladoLee:
	return
;--------------------------------------------------------------------------------------------------
;	END													; Se omite aquí.