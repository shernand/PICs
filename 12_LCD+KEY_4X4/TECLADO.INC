;##################################################################################################
;	Surutinas para el manejo de un teclado en arreglo de matriz 4 X 4
;	Organización básica de los interruptores para el teclado 4 x 4
;
;	Se usa el puerto D del uC. Para adaptar a otro puerto se deben hacer modificaciones
;
;	 	 	      RD4	 RD5 	RD6  RD7
;		 	       ^    ^    ^    ^
;		    	|----|----|----|----|
;	RD0 -->	|  0 |  1 |  2 |  3 |
;			    |----|----|----|----|
;	RD1 -->	|  4 |  5 |  6 |  7 |
;		    	|----|----|----|----|
;	RD2 -->	|  8 |  9 | 10 | 11 |
;			    |----|----|----|----|
;	RD3 -->	| 12 | 13 | 14 | 15 |
;			    |----|----|----|----|
;
; 	Los números dentro de cada recuadrado representan la posición relativa de las teclas, 
; no es el código que regresa este programa al ser oprimida esa tecla.
;
; 	Para calcular el valor correspondiente a la tecla oprimida se emplea una Tabla de Conversión.
; Con ella se asigna un valor en relación a la posición que tiene la tecla oprimida.
;
;##################################################################################################
;-----[Z O N A    D E    D A T O S-----
;
	CBLOCK							; Continúa a partir de la última variable dada de alta.
		Tecl_TeclaOrden		; Orden de la tecla a revisar.
	ENDC

Tecl_UltimaTecla	EQU	d'15'	; Valor de orden de la última tecla utilizada.

; Subrutina "Teclado_LeeHex" ************************************************************
;
; 	Cada tecla tiene asignado un número de Posición Relativa, éste es contabilizado en la variable
; Tecl_TeclaOrden. Para encontrar el valor correspondiente de la tecla oprimida, de acuerdo a 
; un teclado organizado en una forma particular, se usa una Tabla de Conversión.
; 	Como un ejemplo se muestra a continuación la relación que hay entre el número de orden de una 
; tecla y los valores correspondientes para un teclado hexadecimal en particular (uno de los más 
; utilizados).
;
;	  POSICIÓN DE TECLAS	  TECLADO Particular
;		 0   1   2   3 					1  2  3  F
;		 4   5   6   7 					4  5  6  E
;		 8   9  10  11 					7  8  9  D
;		12  13  14  15 					A  0  B  C
;
; 	Así, en este ejemplo, la tecla "7" de la serigrafía del teclado comercial ocupa el posición 8 
; del arreglo 4X4, la tecla "F" ocupa la posición 3 y la tecla "9" la posición 10.
;
; 	Si se cambiara por otro teclado comercial, con otra serigrafía o dibujos, sólo se tendría que
; modificar la tabla de conversión.
;
; Dato de entrada:	En (W) el orden de la tecla pulsada.
; Salida:			En (W) el valor hexadecimal para este teclado concreto.
;
Teclado_LeeHex:
	call	Teclado_LeeOrdenTecla				; Lee la posición o el orden de la tecla pulsada.
	btfss	STATUS,C										; ¿Se pulsó alguna tecla?, ¿Cy=1?
	goto	Tecl_FinLeeHex							; No, entonces se sale de esta rutina.
	call	Tecl_ConvierteOrdenEnHex		; SI, Lo convierte en su valor real mediante la Tabla.
	bsf		STATUS,C										; Vuelve a ajustar el Carry (a "1"), porque la
Tecl_FinLeeHex:											; instrucción "addwf PCL,F" lo pone a "0".
	return

; 	A continuación está la Tabla de Conversión. Se organiza para que la posición de la tecla
; oprimida corresponda al código que se regresará cuando se oprima esa tecla.

Tecl_ConvierteOrdenEnHex:			; Según el teclado utilizado resulta:
	addwf	PCL,F
	DT	1h,2h,3h,0Fh					; Primera fila del teclado.
	DT	4h,5h,6h,0Eh					; Segunda fila del teclado
	DT	7h,8h,9h,0Dh					; Tercera fila del teclado.
	DT	0Ah,0h,0Bh,0Ch				; Cuarta fila del teclado.
Teclado_FinTablaHex
;
; Esta tabla se sitúa al principio de la librería con el propósito de que no salte de la
; página de memoria ROM en donde inició. De todas formas, en caso que así fuera 
; visualizaría el siguiente mensaje de error en el proceso de ensamblado:
; [R E V I S A R]
;	IF (Teclado_FinTablaHex > 0xFF)
;		ERROR	"Atención: La tabla ha superado el tamaño de la página de los"
;		MESSG	"primeros 256 bytes de memoria ROM. NO funcionará correctamente."
;	ENDIF
	
; Subrutina "Teclado_Inicializa" --------------------------------------------------------
;
; Esta subrutina configura las líneas del Puerto D según la conexión del teclado realizada
; y comprueba que no hay pulsada tecla alguna al principio.

Teclado_Inicializa:
	bsf		STATUS,RP0				; Cambio al Banco "1". Configura las líneas del puerto:
	movlw	b'11110000'				; <PD7:PD4> entradas, <PD3:PD0> salidas
	movwf	PORTD
	bcf		STATUS,RP0				; Regreso al Banco "0".

; Subrutina "Teclado_EsperaDejePulsar" --------------------------------------------------
;
;Permanece en esta subrutina mientras siga pulsada la tecla.
;
Teclado_Comprobacion	EQU	b'11110000'

Teclado_EsperaDejePulsar:
	movlw	Teclado_Comprobacion		; Pone a cero las cuatro líneas de salida del 
	movwf	PORTD										; Puerto D.
Teclado_SigueEsperando:
	call	R_20mS									; Espera para que se estabilicen las señales.
	movf	PORTD,W									; Lee el Puerto D.
	sublw	Teclado_Comprobacion		; Si se lee lo mismo que se escribió, es que ya no
	btfss	STATUS,Z								; está oprimida tecla alguna.
	goto	Teclado_SigueEsperando	; En caso contrario hay alguna tecla oprimida.
	return
;
; Subrutina "Teclado_LeeOrdenTecla" -----------------------------------------------------
;
; Lee el teclado, obteniendo el posición relativa de la tecla pulsada. 
;
; Salida:	En (W) está el número de posición de la tecla pulsada. Además Carry está 
;			en "1" si se pulsa una tecla ó está en "0" si no se oprimió tecla alguna.
;
Teclado_LeeOrdenTecla:
	clrf	Tecl_TeclaOrden				; Todavía no ha empezado a revisar el teclado.
	movlw	b'11111110'						; Verifica iniciando en la primera fila.
Tecl_RevisaFila:							; (Ver esquema de conexión).
	movwf	PORTD									; Activa la fila correspondiente (se ajusta a "0")
	call	R_1mS									; Un retardo para sensar la tecla adecuadamente [VERIFICAR]
Tecl_Columna1:
	btfss	PORTD,4								; Revisa la primera columna en búsqueda de un "0". 
	goto	Tecl_GuardaValor			; Sí, fue "0", entonces guarda el valor y concluye avisando.
	incf	Tecl_TeclaOrden,F			; No fue "0", actualiza contador y revisa la siguiente tecla.
Tecl_Columna2:								;    Repite el proceso para las siguientes... 
	btfss	PORTD,5								; ...tres columnas restantes.
	goto	Tecl_GuardaValor			;
	incf	Tecl_TeclaOrden,F			; 	Se incrementa la variable Tecl_TeclaOrden cada vez que 
Tecl_Columna3:								; no se encontró oprimida una tecla en la columna revisada.
	btfss	PORTD,6
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
Tecl_Columna4:		
	btfss	PORTD,7
	goto	Tecl_GuardaValor
	incf	Tecl_TeclaOrden,F
;
;	Comprueba si está revisdo la última tecla, si así fuera termina, avisando que no se encontró 
; tecla oprimida, (haciendo "Cy" = 0). Para la prueba verifica el contenido del registro 
; Tecl_TeclaOrden contra el número de teclas del teclado (En este caso 15).
;
Tecl_TerminaColumnas:
	movlw	Tecl_UltimaTecla
	subwf	Tecl_TeclaOrden,W			; (W) <- (Tecl_TeclaOrden)-Tecl_UltimaTecla.
	btfsc	STATUS,C							; ¿Cy=0?, ¿(W) negativo?, ¿(Tecl_TeclaOrden)<15?
	goto	Tecl_NoPulsada				; No, se ha llegado al final del chequeo.
	bsf		STATUS,C							; Sí. Va a revisar la siguiente fila.
	rlf		PORTD,W								; Apunta a la siguiente fila. (Rota el "0" a la siguiente...
	goto	Tecl_RevisaFila				;...posición y continúa.
Tecl_NoPulsada:
	bcf		STATUS,C							; Ajusta Cy=0, indicando que no se ha oprimido
	goto	Tecl_FinTecladoLee		; tecla alguna y concluye.
Tecl_GuardaValor:
	movf	Tecl_TeclaOrden,W			; Guarda la posición relativa de la tecla pulsada en (W) y sale.
	bsf		STATUS,C							; Como hay tecla tecla pulsada, pone Cy=1. 
Tecl_FinTecladoLee:
	return