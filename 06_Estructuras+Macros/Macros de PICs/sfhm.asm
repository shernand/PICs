;===================================================================================
;  Libreria de Macros para microcontroladores PIC
;
;Autor:		Sergio Fco. Hernandez Machuca
;Fecha:		Noviembre del 2001
;Lugar:		Xalapa - Veracruz - Mexico
;version:	1.0
;
;-----[ Revisiones  ]-----
;  
;===================================================================================

	messg	"Verson 1.0 de Librerias de Macros SFHM@IDEAS"

;===================================================================================
:
:	Esta libreria incluye los macros esenciales para implementar funciones basicas
;  de cotrol e intepretacion en lenguajes de alto nivel.
;
;	Para incorporar esta libreria a sus proppios programas, se debe agregar el
;estatuto INCLUDE inmediatamente despues del que corresponde a las etiquetas de
;referencia para el microcontrolador que esta trabajando.
;
;Por ejemplo:
;
;	include		".\p16f877.inc"
;	include		".\sfhm.asm"
;
;
;  Version 1.0   29 May 1999
;
  Initial release.  Includes WAITWHILE, WAITUNTIL, and POLL-ENDPOLL.
;  Changed movfw to movf, to support older MCUs.  Will still give errors
;  in NEXTL macro on older PICs, since that macro uses the addlw
;  instruction.
;


;-----[ Variables Genericas ]-----
;
;  Declaracion de variables que se emplean como referencia en la generacion
;de diversas instancias de los macros. La mayoria se emplea para la generacion
;de las adecuadas etiquetas.


	variable	_forknt=0
	variable	_nxtknt=0
	variable	_rptknt=0
	variable	_alwknt=0
	variable	_untknt=0
	variable	_seltot=0
	variable	_selknt=0
	variable	_castot=0
	variable	_casknt=0
	variable	_waitk=0
	variable	_pollk=0
	variable	_pollt=0

;==========================================================================

;-----[ Macro BEQ (Branch - If - Equal) ]-----
;
;
;Sintaxis:	BEQ	Etiqueta
;
;Operación:	Prueba el valor actual de la bandera "Z".
;
;Altera:	Nada
;

BEQ	macro	Direccion

	btfsc	STATUS,Z
	goto	Direccion
	endm
;==========================================================================
;
;-----[ Macro BNE (Branch - If Not - Equal) ]-----
;
;
;Sintaxis:	BNE	Etiqueta
;
;Operación:	Prueba el valor actual de la bandera "Z".
;
;Altera:	Nada
;

BNE	macro	Direccion

	btfss	STATUS,Z
	goto	Direccion
	endm
;==========================================================================
;
;-----[ Macro FOR, Inicio de la estructura FOR - NEXT ]-----
;
;
;Sintaxis:	FOR	Variable, Inicio, Fin
;
;Operación:	Inicia la estructura FOR - NEXT, los argumentos son: "Variable",
;	la cual es una variable en RAM usada como índice para el lazo; "Inicio",
;	que es una literal empleada como el valor inicial del índice; "Fin",
;	que es una literal usada como el último valor de índice.
;		
;	La ejecución de código se realizará en el lazo comprendido entre el
;	estatuto FOR y el estatuto NEXT, hasta que el valor de "Variable" sea
;	igual al valor de la literal "Fin", este valor es calculado en la parte
;	inicial del lazo. En caso de darse una comparación exitosa, el control
;	se transfiere al punto en donde se encuentra la macro NEXT.
;
;	Se puede concluir el estatuto FOR con los macros NEXT, NEXTL, NEXTF.	
;
;Altera:	Registro W
;


FOR	macro	Variable, Inicio, Fin
	movlw	Inicio			;Inicia el valor del índice
	movwf	Variable

_for#v(_forknt)				;Etiqueta de retorno para el NEXT

	movlw	Fin			;Prueba si Variable (índice) = FIN
	subwf	Variable,w
	beq	_next#v(_forknt)	;Si lo fuera, salta al macro NEXT

_forknt	set	_forknt+1		;Ajusta para las siguientes
_nxtknt	set	_forknt			;  invocaciones

	endm
;==========================================================================
;
;-----[ Macro FORF Inicio de la estructura FORF - NEXT ]-----
;
;
;Sintaxis:	FOR	Variable, Inicio, Fin
;
;Operación:	Inicia la estructura FORF - NEXT, los argumentos son: "Variable",
;	la cual es una variable en RAM usada como índice para el lazo; "Inicio",
;	que es una literal empleada como el valor inicial del índice; "Fin",
;	que es una bandera o variable RAM usada como el valor límite de índice.
;		
;	La ejecución de código se realizará en el lazo comprendido entre el
;	estatuto FORF y el estatuto NEXT, hasta que el valor de "Variable" sea
;	igual al valor de la literal "Fin", este valor es calculado en la parte
;	inicial del lazo. En caso de darse una comparación exitosa, el control
;	se transfiere al punto en donde se encuentra la macro NEXT.
;
;	Se puede concluir el estatuto FOR con los macros NEXT, NEXTL, NEXTF.	
;
;Altera:	Registro W
;

FORF	macro	Variable, Inicio, Fin
	movlw	Inicio
	movwf	Variable

_for#v(_forknt)

	movf	Variable,w
	subwf	Fin
	beq	_next#v(_forknt)

_forknt	set	_forknt+1
_nxtknt	set	_forknt

	endm
;==========================================================================
;
;-----[ Macro NEXT, final de la estructura FOR - NEXT) ]-----
;
;
;Sintaxis:	NEXT	Variable
;
;Operación:	Concluye la estructura FOR - NEXT, el argumento es: "Variable",
;	la cual es una variable RAM empleada como índice del lazo FOR-NEXT.
;
;	La ejecución del macro FOR incrementará el valor de "Variable" y regresará
;	al inicio del lazo FOR-NEXT para probar si llegó al final. Debe ponerse
;	mucha atención en que la Variable del macro NEXT sea idéntica a la variable
;	del macro FOR correspondiente. Estos macros no hacen ningún tipo de revisión
;	específica al respecto.		
;
;	Se puede concluir el estatuto FOR con los macros NEXT, NEXTL, NEXTF.	
;
;Altera:	Registro W, contenido de "Variable"
;

NEXT	macro	Variable

_nxtknt	set	_nxtknt-1		;Ajuste del índice de FOR´s procesados

	incf	var,f			;Incrementa el índice
	goto	_for#v(_nxtknt)		;Regresa al inicio del lazo

_next#v(_nxtknt)			;Punto de salida del NEXT

	endm
==========================================================================
;
;-----[ Macro NEXTL, final de la estructura FOR - NEXTL ]-----
;
;
;Sintaxis:	NEXTL	Variable, Incremento
;
;Operación:	Concluye la estructura FOR - NEXT, los argumentos son: "Variable",
;	la cual es una variable RAM empleada como índice del lazo FOR-NEXT, 
;	"Incremento" es una literal usada para modificar el índice.
;
;	La ejecución del macro FOR agregará el valor de la literal "Incremento"
;	al valor de "Variable" y regresará al inicio del lazo FOR-NEXTL para probar
;	si llegó al final. Debe ponerse mucha atención en que la Variable del macro 
;	NEXT sea idéntica a la variable del macro FOR correspondiente. Estos macros
;	no hacen ningún tipo de revisión específica al respecto.		
;
;	Se puede usar NEXTL para concluir los macros FOR-NEXTL, FORF-NEXTL o FORL-NEXTL
;
;Altera:	Registro W, contenido de "Variable"
;

NEXTL	macro	Variable, Incremento

_nxtknt	set	_nxtknt-1

	movf	Variable,w
	addlw	Incremento
	movwf	Variable
	goto	_for#v(_nxtknt)

_next#v(_nxtknt)

	endm
==========================================================================
;
;-----[ Macro NEXTF, final de la estructura FOR - NEXTF ]-----
;
;
;Sintaxis:	NEXTF	Variable, Incremento
;
;Operación:	Concluye la estructura FOR - NEXT, los argumentos son: "Variable",
;	la cual es una variable RAM empleada como índice del lazo FOR-NEXT, 
;	"Incremento" es un registro RAM usado para modificar el índice.
;
;	La ejecución del macro FOR agregará el valor del registro "Incremento"
;	al valor de "Variable" y regresará al inicio del lazo FOR-NEXTL para probar
;	si llegó al final. Debe ponerse mucha atención en que la Variable del macro 
;	NEXT sea idéntica a la variable del macro FOR correspondiente. Estos macros
;	no hacen ningún tipo de revisión específica al respecto.		
;
;	Se puede usar NEXTF para concluir los macros FOR-NEXTF, FORF-NEXTF o FORL-NEXTF
;
;Altera:	Registro W, contenido de "Variable"
;

NEXTF	macro	Variable, Incremento

_nxtknt	set	_nxtknt-1

	movf	var,w
	addwf	incf,f
	goto	_for#v(_nxtknt)

_next#v(_nxtknt)

	endm
==========================================================================
;
;-----[ Macro REPEAT, inicia la estructura REPEAT - ALWAYS o REPEAT - UNTIL ]-----
;
;
;Sintaxis:	REPEAT
;
;Operación:	Marca el inicio de un lazo REPEAT - ALWAYS o un lazo REPEAT - UNTIL.
;	Siempre se retornará el control al inicio del lazo REPEAT si esta estructura 
;	concluye con con el macro ALWAYS. El control regresará condicionalmente al incio
;	de la estructura REPEAT si el lazo es terminado con la macro UNTILEQ o la
;	macro UNTILNE.
;
;Altera:	Nada
;

REPEAT	macro

_rpt#v(_rptknt)

_rptknt	set	_rptknt+1
_alwknt	set	_rptknt
_untknt	set	_rptknt

	endm
==========================================================================
;
;-----[ Macro ALWAYS, retorna al macro REPEAT correspondiente ]-----
;
;
;Sintaxis:	ALWAYS
;
;Operación:	Marca el final de un lazo REPEAT - ALWYAS, el control es
;	pasado automáticamente al macro REPEAT correspondiente.
;
;Altera:	Nada.
;

ALWAYS	macro

_alwknt	set	_alwknt-1

	goto	_rpt#v(_alwknt)
	endm
==========================================================================
;
;-----[ Macro UNTILEQ, retorna (condicionalmente) al macro REPEAT correspondiente ]-----
;
;
;Sintaxis:	UNTILEQ
;
;Operación:	Marca el final de un lazo REPEAT - ALWYAS, el control es
;	pasado  al macro REPEAT correspondiente si la bandez "Z" está en
;	cero (limpiada) en el momento en que se procesa este macro.
;
;Altera:	Nada.
;

UNTILEQ	macro

_untknt	set	_untknt-1

	bne	_rpt#v(_untknt)
	endm
==========================================================================
;
;-----[ Macro UNTILNE, retorna (condicionalmente) al macro REPEAT correspondiente ]-----
;
;
;Sintaxis:	UNTILNE
;
;Operación:	Marca el final de un lazo REPEAT - ALWYAS, el control es
;	pasado  al macro REPEAT correspondiente si la bandez "Z" está en
;	uno (puesta) en el momento en que se procesa este macro.
;
;Altera:	Nada.
;

UNTILNE	macro

_untknt	set	_untknt-1

	beq	_rpt#v(_untknt)

	endm
==========================================================================
;
;-----[ Macro SELECT, declara el inicio de una estructura SELECT - EndSELECT  ]-----
;
;
;Sintaxis:	SELECT
;
;Operación:	Marca el inicio de una estructura SELECT - EndSELECT, la cual
;	típicamente se debiera ver como:
;
;	SELECT			;Inicio del bloque SELECT
;	  CASE  5		; Si w = 5 ...
;	    ...			;
;	  ENDCASE		;Fin de la claúsula para w = 5
;	  CASEF Otra		;Si w = Otra (variable)
;	    ...			;
;	  ENDCASE		;Fin de sección
;	    ...			;Sección que se ejecuta por omisión
;	    ...			;Si todos los casos anteriores fallan.
;	ENDSELECT		;Fin del bloque SELECT	
;
;Altera:	Nada.
;

SELECT	macro

_seltot	set	_seltot+1
_selknt	set	_seltot

	endm
==========================================================================
;
;-----[ Macro ENDSELECT, declara el fin de una estructura SELECT - EndSELECT  ]-----
;
;
;Sintaxis:	ENDSELECT
;
;Operación:	Marca el fin de una estructura SELECT - EndSELECT, la cual
;	típicamente se debiera ver como:
;
;	SELECT			;Inicio del bloque SELECT
;	  CASE  5		; Si w = 5 ...
;	    ...			;
;	  ENDCASE		;Fin de la claúsula para w = 5
;	  CASEF Otra		;Si w = Otra (variable)
;	    ...			;
;	  ENDCASE		;Fin de sección
;	    ...			;Sección que se ejecuta por omisión
;	    ...			;Si todos los casos anteriores fallan.
;	ENDSELECT		;Fin del bloque SELECT	
;
;	Se debe concluir cada macro SELECT con un macro ENDSELECT respectivo, en
;	caso contrario se reportarán errores.
;
;Altera:	Nada.
;

ENDSELECT	macro

sel#v(_selknt)

_selknt	set	_selknt-1
	endm
==========================================================================
;
;-----[ Macro CASE, declara el inicio de una estructura CASE - ENDCASE ]-----
;
;
;Sintaxis:	CASE	Literal
;
;Operación:	Cuando se ejecuta el macro CASE, el valor de w es comparado
;	con el valor de la literal argumento. Si son iguales, el código que
;	sigue a continuación del macro CASE es ejecutado. Si los valores de
;	la literal y w son distintos, el control pasa al código que está
;	a continuación de macro ENDCASE correspondiente.
;
;Altera:	Nada.
;

CASE	macro	Literal

_castot set	_castot+1
_casknt	set	_castot

	xorlw	Literal
	beq	cas#v(_casknt)
	xorlw	Literal
	goto	ecas#v(_casknt)

cas#v(_casknt)

	xorlw	Literal
	endm
==========================================================================
;
;-----[ Macro CASEF, declara el inicio de una estructura CASEF - ENDCASE ]-----
;
;
;Sintaxis:	CASEF	Variable
;		
;		En este caso, "Variable" es usada como selector del CASEF.
;
;Operación:	Cuando se ejecuta el macro CASE, el valor de w es comparado
;	con el valor de la literal argumento. Si son iguales, el código que
;	sigue a continuación del macro CASE es ejecutado. Si los valores de
;	la literal y w son distintos, el control pasa al código que está
;	a continuación de macro ENDCASE correspondiente.
;
;Altera:	Nada.
;


;
;  CASEF (declares start of a CASEF-ENDCASE structure)
;
;  Syntax:
;		casef	var
;
;  where var is a register or variable used as the CASEF selector.
;
;  When the CASEF macro is executed, the value in W is compared
;  with the value in var.  If W equals var, code following
;  the CASEF macro is executed.  If W does not equal var, control
;  passes to the code following the corresponding ENDCASE macro.
;
;  W is preserved in the CASEF macro.
;

casef	macro	var
_castot set	_castot+1
_casknt	set	_castot
	xorwf	var,w
	beq	cas#v(_casknt)
	xorwf	var,w
	goto	ecas#v(_casknt)
cas#v(_casknt)
	xorwf	var,w
	endm


;
;  ENDCASE (declares end of a CASE-ENDCASE or CASEF-ENDCASE structure)
;
;  Syntax:
;		endcase
;
;  The ENDCASE macro marks the end of a CASE-ENDCASE or CASEF-ENDCASE
;  structure.  This macro serves as a jump address for the corresponding
;  CASE or CASEF macro.
;
;  You must have an ENDCASE macro for each CASE or CASEF macro.  If
;  not, MPASM will report errors when it assembles your code.
;
;  This macro preserves the W register.
;

endcase	macro
	goto	sel#v(_selknt)
ecas#v(_casknt)
_casknt	set	_casknt-1
	endm


;
;  WAITWHILE (declares a high-speed WAIT-WHILE loop)
;
;  Syntax:
;
;  		waitwhile	addr,andl,xorl
;
;  The WAITWHILE macro creates a tight loop that reads the byte
;  in address addr, ANDs it with the literal andl, then XORs the
;  result with the literal xorl.  If the result is TRUE (non-zero),
;  the loop repeats.  If the result is FALSE (zero), control exits
;  the macro.
;
;  This macro destroys the W register.  It does not modify addr.
;

waitwhile	macro	addr,andl,xorl
waitw#v(_waitk)
	movf	addr,w
	andlw	andl
	if	xorl != 0
	xorlw	xorl
	endif
	bne	waitw#v(_waitk)
_waitk	set	_waitk+1
	endm


;
;  WAITUNTIL (declares a high-speed WAIT-UNTIL loop)
;
;  Syntax:
;
;  		waituntil	addr,andl,xorl
;
;  The WAITUNTIL macro creates a tight loop that reads the byte
;  in address addr, ANDs it with the literal andl, then XORs the
;  result with the literal xorl.  If the result is TRUE (non-zero),
;  control exits the macro.  If the result is FALSE (zero),
;  the loop repeats.
;
;  This macro destroys the W register.  It does not modify addr.
;


waituntil	macro	addr,andl,xorl
waitw#v(_waitk)
	movf	addr,w
	andlw	andl
	if	xorl != 0
	xorlw	xorl
	endif
	beq	waitw#v(_waitk)
_waitk	set	_waitk+1
	endm


;
;  POLL (starts a POLL-ENDPOLL structure)
;
;  Syntax:
;
;  		poll	addr,andl,xorl
;
;  The POLL macro reads the byte in address addr, ANDs it with
;  the literal andl, then XORs the result with the literal xorl.
;  If the result is TRUE (non-zero), control passes to the code
;  immediately following the macro.  If the result is FALSE
;  (zero), control jumps to the corresponding ENDPOLL macro.
;
;  For example, the following POLL command will test the address
;  SPORT for bit 3 high:
;
;	poll	SPORT,8,0		test bit 3
;	nop				do this if bit 3 is high
;	endpoll
;
;  The following POLL command will test the address SPORT for
;  bit 3 high while either bits 2 or 1 are low:
;
;	poll	SPORT,0x0e,0x06		test bits 1-3
;	nop				do if 3 is high, 1 or 2 is low
;	endpoll
;
;  This macro destroys the W register.  It does not modify addr.
;


poll	macro	addr,andl,xorl
_pollt	set	_pollt+1
_pollk	set	_pollt
	movf	addr,w
	andlw	andl
	xorlw	xorl
	beq	poll#v(_pollk)
	endm


;
;  ENDPOLL (marks end of a POLL-ENDPOLL structure)
;
;  The ENDPOLL macro terminates a POLL-ENDPOLL structure.
;  Control reaches this macro if the associated POLL macro
;  fails.
;

endpoll	macro
poll#v(_pollk)
_pollk	set	_pollk-1
	endm



 
Segunda parte de Macros

;******************************************************************************
 
;Ifs.mac
;Use:    Provide FORTRAN-like IF statements.
;Revision:  8 Dec 98
;Author:  Tom Lyons Fisher
;Note:  W is preserved; Carry flag may be altered.
;CAUTION!:  Dest must be on the same Page as the If.
  
;******************************************************************************
 
;------------------------------------------------------------------------------
 
IfWGTF  MACRO   File, Dest
 
;------------------------------------------------------------------------------
 
   LOCAL   If10
 
   movwf   TempW
   subwf   File,W
   bc   If10
   movfw   TempW
   goto   Dest
If10
   movfw   TempW
 
   ENDM
 
;------------------------------------------------------------------------------
 
IfWGTL   MACRO   Const, Dest
 
;------------------------------------------------------------------------------
 
   LOCAL   If15
 
   movwf   TempW
   sublw   Const
   bc   If15
   movfw   TempW
   goto   Dest
If15
   movfw   TempW
 
   ENDM
 
;------------------------------------------------------------------------------
 
IfWGEF MACRO File, Dest
 
;------------------------------------------------------------------------------
 
   LOCAL   If20,If21
 
   movwf   TempW
   subwf   File,W
   bnc   If20
   bnz   If21
If20
   movfw   TempW
   goto   Dest
If21
   movfw   TempW
 
   ENDM
 
;------------------------------------------------------------------------------
 
IfWGEL   MACRO   Const, Dest
 
;------------------------------------------------------------------------------
 
   LOCAL   If25,If26
 
   movwf   TempW
   sublw   Const
   bnc   If25
   bnz   If26
If25
   movfw   TempW
   goto   Dest
If26
   movfw   TempW
 
   ENDM
 
;------------------------------------------------------------------------------
 
IfWEQF   MACRO   File, Dest
 
;------------------------------------------------------------------------------
 
   LOCAL   If30
 
  movwf  TempW
  subwf  File,W
  bnz  If30
  movfw  TempW
  goto  Dest
If30
  movfw  TempW
 
  ENDM
  
;------------------------------------------------------------------------------
 
IfWEQL  MACRO  Const, Dest
 
;------------------------------------------------------------------------------
 
  LOCAL  If35
  movwf  TempW
  sublw  Const
  bnz  If35
  movfw  TempW
  goto  Dest
If35
  movfw  TempW
 
  ENDM
 
;------------------------------------------------------------------------------
 
IfWNEF  MACRO  File, Dest
 
;------------------------------------------------------------------------------
 
  LOCAL  If40
 
  movwf  TempW
  subwf  File,W
  bz  If40
  movfw  TempW
  goto  Dest
If40
  movfw  TempW
 
  ENDM
 
;------------------------------------------------------------------------------
 
IfWNEL  MACRO  Const, Dest
 
;------------------------------------------------------------------------------
 
  LOCAL  If45
 
  movwf  TempW
  sublw  Const
  bz  If45
  movfw  TempW
  goto  Dest
If45
  movfw  TempW
 
  ENDM
 
;------------------------------------------------------------------------------
 
IfWLEF  MACRO  File, Dest
 
;------------------------------------------------------------------------------
 
  LOCAL  If50
 
  movwf  TempW
  subwf  File,W
  bnc  If50
  movfw  TempW
  goto  Dest
If50
  movfw  TempW
 
  ENDM
 
;------------------------------------------------------------------------------
 
IfWLEL  MACRO  Const, Dest
 
;------------------------------------------------------------------------------
 
  LOCAL  If55
 
  movwf  TempW
  sublw  Const
  bnc  If55
  movfw  TempW
  goto  Dest
If55
  movfw  TempW
 
  ENDM
 
;------------------------------------------------------------------------------
 
IfWLTF  MACRO  File, Dest
 
;------------------------------------------------------------------------------
 
  LOCAL  If60
 
  movwf  TempW
  subwf  File,W
  bnc  If60
  bz  If60
  movfw  TempW
  goto  Dest
If60
  movfw  TempW
 
  ENDM
 
;------------------------------------------------------------------------------
 
IfWLTL  MACRO  Const, Dest
 
;------------------------------------------------------------------------------
 
  LOCAL  If65
 
  movwf  TempW
  sublw  Const
  bnc  If65
  bz  If65
  movfw  TempW
  goto  Dest
If65
  movfw  TempW
 
  ENDM
 
 
;******************************************************************************
 
;Ports.mac
 
;Use:    Port Utilities
;Revision:  18 Jun 99
;Author:  Tom Lyons Fisher
 
;******************************************************************************
 
;------------------------------------------------------------------------------
 
DirIn  MACRO  PortNum,PinNum
 
;------------------------------------------------------------------------------
 
  Bank1
  bsf  PortNum,PinNum
  Bank0
 
  ENDM
 
;------------------------------------------------------------------------------
 
DirOut  MACRO  PortNum,PinNum
 
;------------------------------------------------------------------------------
 
  Bank1
  bcf  PortNum,PinNum
  Bank0
 
  ENDM
 
;------------------------------------------------------------------------------
 
ClrPin  MACRO  PortNum,PinNum
 
;CAUTION!:  RAM locations must be reserved for the port mirrors.
 
;------------------------------------------------------------------------------
 
  bcf  PortNum+D'27',PinNum
  movfw  PortNum+D'27'
  movwf  PortNum
 
  ENDM
 
;------------------------------------------------------------------------------
 
SetPin  MACRO  PortNum,PinNum
 
;CAUTION!:  RAM locations must be reserved for the port mirrors.
 
;------------------------------------------------------------------------------
 
  bsf  PortNum+D'27',PinNum
  movfw  PortNum+D'27'
  movwf  PortNum
 
  ENDM
 
 
;******************************************************************************
  
;Gos.mac
 
;Use:    Implement GoSub, GoTab, Pass, and Catch.
;Revision:  30 Jul 99
;Author:  Tom Lyons Fisher
 
;******************************************************************************
 
;------------------------------------------------------------------------------
 
GoSub  MACRO  Subrtn
 
;Perform a "call subroutine" anywhere in memory.
;Note: W is preserved, so GoSub behaves just like a call.
;CAUTION!: The variable TempW must be located in "bankless RAM" (70h to 7Fh in
; the newer PIC microcontrollers).
 
;------------------------------------------------------------------------------
 
  ERRORLEVEL -306
 
  movwf  TempW
  movlw  HIGH Subrtn
  movwf  PCLATH
  movfw  TempW
  
  call  Subrtn
 
  movwf  TempW  
  movlw  HIGH $
  movwf  PCLATH
  movfw  TempW
 
  ENDM
 
  ERRORLEVEL +306
 
;------------------------------------------------------------------------------
 
GoTab  MACRO  Table
 
;Perform a table look-up anywhere in Program Memory.
;Note:    addwf  PCL,F   is required at the head of the Table.
;CAUTION!: A table cannot have more than 256 entries nor can it straddle a page
; boundary.
 
;------------------------------------------------------------------------------
 
  ERRORLEVEL -306
 
  movwf  TempW  
  movlw  LOW Table
  addwf  TempW,W
  movlw  HIGH Table
  skpnc
  addlw  D'1'
  movwf  PCLATH
  movfw  TempW
  
  call  Table
 
  movwf  TempW
  movlw  HIGH $
  movwf  PCLATH
  movfw  TempW
  
  ENDM
 
  ERRORLEVEL +306
 
;------------------------------------------------------------------------------
 
Pass  MACRO  PassA,PassB
 
;CAUTION!: The variables Pass0 and Pass1 should be located in "bankless RAM".
 
;------------------------------------------------------------------------------
 
  movfw  PassA
  movwf  Pass0
  movfw  PassB
  movwf  Pass1
 
  ENDM
 
;------------------------------------------------------------------------------
 
Catch  MACRO  PassA,PassB
 
;------------------------------------------------------------------------------
 
  movfw  Pass0
  movwf  PassA
  movfw  Pass1
  movwf  PassB
 
  ENDM
 
 
;******************************************************************************
 
;Stack.inc
 
;Use:    Establish and maintain a general purpose system stack.
;Version:  14 May 99
;Author:  Tom Lyons Fisher
;Method:  A general purpose system stack is established by pointing FSR to
;    the next available stack location.
;    W is preserved (in TempW) and restored transparently.
;CAUTION!:  THERE IS NO STACK OVERFLOW OR UNDERFLOW WARNING!
;    The current position of the pointer is preserved in Stack ONLY when
;    SavStak is utilized. Otherwise, Stack is set to zero. 
;Note:    The stack pointer in FSR points to the next available (free) byte.
 
;******************************************************************************
 
;------------------------------------------------------------------------------
 
Push1  MACRO
 
;------------------------------------------------------------------------------
 
  movfw  Temp1
  movwf  INDF
  incf  FSR,F  
  movfw  TempW
  ENDM
 
;------------------------------------------------------------------------------
  
Push2  MACRO
 
;------------------------------------------------------------------------------
 
  movfw  Temp1
  movwf  INDF
  incf  FSR,F  
  movfw  Temp2
  movwf  INDF
  incf  FSR,F  
  movfw  TempW
  ENDM
 
;------------------------------------------------------------------------------
  
Push3  MACRO
 
;------------------------------------------------------------------------------
 
  movfw  Temp1
  movwf  INDF
  incf  FSR,F  
  movfw  Temp2
  movwf  INDF
  incf  FSR,F  
  movfw  Temp3
  movwf  INDF
  incf  FSR,F  
  movfw  TempW
  ENDM
 
;------------------------------------------------------------------------------
  
Pull1  MACRO
 
;------------------------------------------------------------------------------
 
  movwf  TempW
  decf  FSR,F
  movfw  INDF
  movwf  Temp1
  movfw  TempW
  ENDM
 
;------------------------------------------------------------------------------
  
Pull2  MACRO
 
;------------------------------------------------------------------------------
 
  movwf  TempW
  decf  FSR,F
  movfw  INDF
  movwf  Temp2
  decf  FSR,F
  movfw  INDF
  movwf  Temp1
  movfw  TempW
  ENDM
 
;------------------------------------------------------------------------------
  
Pull3  MACRO
 
;------------------------------------------------------------------------------
 
  movwf  TempW
  decf  FSR,F
  movfw  INDF
  movwf  Temp3
  decf  FSR,F
  movfw  INDF
  movwf  Temp2
  decf  FSR,F
  movfw  INDF
  movwf  Temp1
  movfw  TempW
  ENDM
 
;------------------------------------------------------------------------------
 
SavStak  MACRO
 
;Temporarily save the System Stack Pointer if it is not already saved.
;NOTE: This routine guards against a "false pointer" being saved.
;CAUTION!: W is not preserved.
;Stack now holds the current stack pointer.
 
;------------------------------------------------------------------------------
 
  LOCAL  SS0
 
  tstf  Stack
  bnz  SS0
  movfw  FSR
  movwf  Stack
SS0
  ENDM
 
;------------------------------------------------------------------------------
 
GetStak  MACRO
 
;Restore the System Stack Vector (IRP and FSR).
;CAUTION!: W is not preserved! 
;Stack no longer holds the current stack pointer.
 
;------------------------------------------------------------------------------
 
  movfw  Stack
  movwf  FSR
  clrf  Stack
 
  ENDM
 
;Main.inc
 
;Use:    Boilerplate executable code for all programs.
;Revision:  1 Aug 99
;Author:  Tom Lyons Fisher
;CAUTION!:  Be sure to set variable name width to 7 or greater.
 
  #INCLUDE <c:\Progra~1\MPLAB\P16C76.inc>
;  #INCLUDE <Macros2.asm>
 
  #DEFINE ROM0 H'0000'
  #DEFINE RAM0 H'20'
  #DEFINE RAM1 H'A0'
 
;Place Port Mirrors 27 bytes above the Ports themselves.
 
  CBLOCK  RAM0
  ATROP
  BTROP
  CTROP
  ENDC
  
;Place important variables in "bankless RAM".  
TempW  equ  H'070'
Temp1  equ  H'071'
Temp2  equ  H'072'
Temp3  equ  H'073'
Stack  equ  H'074'
Flags  equ  H'075'
Pass0  equ  H'076'
Pass1  equ  H'077'
 
  ORG  ROM0
  goto  Main
  ORG  (ROM0+4)
 
;  #INCLUDE <interrupt routines here>
 
Main
  
;Set up System Stack.  
  movlw  RAM1
  movwf  FSR
  clrf  Stack
 
  END
 




