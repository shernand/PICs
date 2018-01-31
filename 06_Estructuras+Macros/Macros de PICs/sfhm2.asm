;==========================================================================
;
;-----[ Macro Movlf - Carga un registro con un valor ]-----
;
;
;Sintaxis:	Movlf	Literal, Registro
;
;Operación:	Carga el valor de una literal en un registro "fr".
;
;Altera:	Registro W, contenido de "Variable"
;

Movlf	macro	Literal, Registro

	movlw	Literal
	movwf	Registro

	endm
;==========================================================================
;
;-----[ Macro Load - Carga un registro con un valor ]-----
;
;
;Sintaxis:	Load	Registro, Literal
;
;Operación:	Carga el valor de una literal en un registro.
;
;Altera:	Registro W, contenido de "Variable"
;

Load	macro	Registro, Literal

	movlw	Literal
	movwf	Registro

	endm
;==========================================================================
;
;-----[ Macro Movff - Carga un registro con el valor de otro registro ]-----
;
;
;Sintaxis:	Movlf	Fuente, Destino
;
;Operación:	Carga el valor del registro "Fuente" en el registro "Destino".
;
;Altera:	Registro W, contenido de "Destino"
;

Movff	macro	Fuente, Destino

	movfw	Fuente
	movwf	Destino

	endm
;==========================================================================
;
;-----[ Macro Copy - Copia el valor de un registro hacia otro registro ]-----
;
;
;Sintaxis:	Copy	Destino, Fuente
;
;Operación:	Carga el valor del registro "Fuente" en el registro "Destino".
;
;Altera:	Registro W, contenido de "Destino"
;

Copy	macro	Destino, Fuente

	movfw	Fuente
	movwf	Destino

	endm
;==========================================================================
;==========================================================================
;
;-----[ Macro Skpb Registro, Bit - Salto condicional "Skip" (Bit de un Reg.) ]-----
;
;
;Sintaxis:	Skpb	Registro, Bit
;
;Operación:	Salta la siguiente instrucción (no la ejecuta) si el "Bit" 
;		del "Registro" está en "uno".
;
;Altera:	Nada
;

Skpb	macro	Registro, Bit

	btfss	Registro, Bit

	endm
;==========================================================================
;==========================================================================
;
;-----[ Macro Skpnb Registro, Bit  - Salto condicional "Skip" (Bit de un Reg.) ]-----
;
;
;Sintaxis:	Skpnb	Registro, Bit
;
;Operación:	Salta la siguiente instrucción (no la ejecuta) si el "Bit" 
;		del "Registro" está en "cero".
;
;Altera:	Nada
;

Skpnb	macro	Registro, Bit

	btfsc	Registro, Bit

	endm
;==========================================================================
;	También se pueden emplear las siguientes instucciones
; 
;	skpc	- Salta si está puesta la bandera de "Carry"
;	skpnc	- Salta si no está puesta la bandera de "Carry"
;	skpz	- Salta si está puesta la bandera de "Zero"
;	skpnz	- Salta si no está puesta la bandera de "Zero"
;==========================================================================

;==========================================================================
;
;-----[ Macro Bb Registro, Bit, Dirección - Salto condicional (Bit de un Reg.) ]-----
;
;
;Sintaxis:	Bb	Registro, Bit, Dirección
;
;Operación:	Continúa la ejecución del programa a partir de "Dirección" 
;		si el "Bit" del "Registro" está puesto en "1".
;
;Altera:	Nada
;

Bb	macro	Registro, Bit, Direccion

	btfsc	Registro, Bit
	goto	Direccion

	endm

;==========================================================================
;-----[ Macro Bnb Registro, Bit, Dirección - Salto condicional (Bit de un Reg.) ]-----
;
;
;Sintaxis:	Bnb	Registro, Bit, Dirección
;
;Operación:	Continúa la ejecución del programa a partir de "Dirección" 
;		si el "Bit" del "Registro" está puesto en "0".
;
;Altera:	Nada
;

Bnb	macro	Registro, Bit, Direccion

	btfss	Registro, Bit
	goto	Direccion

	endm
;==========================================================================
;	También se pueden emplear las siguientes instrucciones
; 
;	b
;	bc
;	bnc
;	bz
;	bnz
;
;==========================================================================

;==========================================================================
;-----[ Macro Incbz Registro, Dirección - Incremento y salto ]-----
;
;
;Sintaxis:	Incbz	Registro, Dirección
;
;Operación:	Incrementa el "Registro", si el resultado es igual a
;		"0",, transfiere el control a "Dirección"
;
;Altera:	Nada
;

Incbz	macro	Registro, Direccion

	LOCAL	Salida

	decfsz	Registro, f
	goto	Salida
	goto	Direccion
Salida:
	endm
;==========================================================================

;===============================================
; Decrement/Increment register and jump if zero
;
; Syntax:
;	dbnz register,address
;	ibnz register,address
;
; Registers: -
;
;-----------------------------------------------
; Decrement/increment register and jump if the result is zero.
; Flags are not changed.
;-----------------------------------------------

dbnz		macro register,address
				decfsz register,f
				goto address
		endm

ibnz		macro register,address
				incfsz register,f
				goto address
		endm
