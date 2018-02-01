;------------------------------------------------------------------------------
; Ensayo para un conversor A/D
;	
;------------------------------------------------------------------------------
;==============================================================================
;-----[ AJUSTES ]-----
  LIST 	P = PIC16F877			; Identificación del uC en donde se ensamblará.
  #INCLUDE 	P16F877.INC		; Se usarán las variables de Microchip
  RADIX			HEX						; La base numérica es Hexadecimal por omisión
;==============================================================================	
	CBLOCK	0x20
    Cont
  ENDC
;------------------------------------------------------------------------------
	
;##############################################################################
;-----[ INFO ]-----
;REGISTER 11-1: ADCON0 REGISTER (ADDRESS: 1Fh) [Está en BANCO "0"]
;R/W-0  R/W-0  R/W-0  R/W-0  R/W-0  R/W-0  U-0  R/W-0
;ADCS1  ADCS0  CHS2   CHS1   CHS0  GO/DONE  —   ADON
;
;bit 7-6 ADCS1:ADCS0: A/D Conversion Clock Select bits
; 00 = FOSC/2
; 01 = FOSC/8
; 10 = FOSC/32
; 11 = FRC (clock derived from the internal A/D module RC oscillator)
;
;bit 5-3 CHS2:CHS0: Analog Channel Select bits
;000 = channel 0, (RA0/AN0)
;001 = channel 1, (RA1/AN1)
;010 = channel 2, (RA2/AN2)
;011 = channel 3, (RA3/AN3)
;100 = channel 4, (RA5/AN4)
;101 = channel 5, (RE0/AN5)(1)
;110 = channel 6, (RE1/AN6)(1)
;111 = channel 7, (RE2/AN7)(1)
;
;bit 2 GO/DONE: A/D Conversion Status bit
;If ADON = 1:
;1 = A/D conversion in progress (setting this bit starts the A/D conversion)
;0 = A/D conversion not in progress (this bit is automatically cleared by 
;        hardware when the A/D conversion is complete)
;
;bit 1 Unimplemented: Read as '0'
;
;bit 0 ADON: A/D On bit
;1 = A/D converter module is operating
;0 = A/D converter module is shut-off and consumes no operating current
;##############################################################################
;
;REGISTER 11-2: ADCON1 REGISTER (ADDRESS 9Fh) [Está en BANCO "1"]
; U-0  U-0  R/W-0  U-0  R/W-0  R/W-0  R/W-0  R/W-0
; ADFM  —     —     —   PCFG3  PCFG2  PCFG1  PCFG0
;
;bit 7 ADFM: A/D Result Format Select bit
;1 = Right justified. 6 Most Significant bits of ADRESH are read as ‘0’.
;0 = Left justified. 6 Least Significant bits of ADRESL are read as ‘0’.
;
;bit 6-4 Unimplemented: Read as '0'
;
;bit 3-0 PCFG3:PCFG0: A/D Port Configuration Control bits:
; [Página 114 del Manual Comentado]
;
; The ADRESH:ADRESL registers contain the 10-bit result of the A/D conversion.
; When the A/D conversion is complete, the result is loaded into this 
; A/D result register pair, the GO/DONE bit (ADCON0<2>) is cleared and the 
; A/D interrupt flag bit ADIF is set. The block diagram of the A/D module is
; shown in Figure 11-1.
; After the A/D module has been configured as desired, the selected channel
; must be acquired before the conversion is started. The analog input channels
; must have their corresponding TRIS bits selected as inputs.
; To determine sample time, see Section 11.1. After this acquisition time has 
; elapsed, the A/D conversion can be started.
;
; These steps should be followed for doing an A/D Conversion:
;  1. Configure the A/D module:
;  --> Configure analog pins/voltage reference and digital I/O (ADCON1)
;  --> Select A/D input channel (ADCON0)
;  --> Select A/D conversion clock (ADCON0)
;  --> Turn on A/D module (ADCON0)
;  2. Configure A/D interrupt (if desired):
;  --> Clear ADIF bit  [PIR1   - Banco "0"]
;  --> Set ADIE bit    [PIE1   - Banco "1"]
;  --> Set PEIE bit		 [INTCON - Banco "0"]
;  --> Set GIE bit		 [INTCON - Banco "0"]
;  3. Wait the required acquisition time.
;  4. Start conversion:
;  --> Set GO/DONE bit (ADCON0)
;  5. Wait for A/D conversion to complete, by either:
;  --> Polling for the GO/DONE bit to be cleared (with interrupts enabled); OR
;  --> Waiting for the A/D interrupt
;  6. Read A/D result register pair (ADRESH:ADRESL), clear bit ADIF if required.
;  7. For the next conversion, go to step 1 or step 2, as required.
;  The A/D conversion time per bit is defined as TAD. A minimum wait of 2TAD is
;  required before the next acquisition starts.
;##############################################################################

	ORG		0x00
	
	bsf 	STATUS,RP0		; Salto a BANCO "1"
;-----		
											; Se ajusta ADCON1 para: 
											; Resultado "Justificado a la Derecha" <b7> y
  movlw b'10001110' 	; se configura a RA0 como entrada ANALÓGICA
  										; Todas las otras entradas son DIGITALES.
  										; ¡OJO! con los voltajes de REFERENCIA
  movwf ADCON1
;-----       
	bsf 	TRISA,0				; Se configura a RA0 como ENTRADA.
;-----     
	clrf 	TRISD 				; PORTD se confugira como SALIDAS.
;----- 
	bcf 	TRISE,0  			; También serán salidas <RE1:RE0>
	bcf 	TRISE,1
;-----              
	clrf 	INTCON				; Se deshabilitan las interrupciones.
;-----	
	bcf		STATUS,RP0		; Regresamos al BANCO "0"
;-----	
	movlw	B'11000101' 	; Se ajusta: Oscilador a F R/C, Canal Analógico RA0,
	movwf ADCON0  			; Enciende Conversor A/D, conversión en progreso.
;-----                    
Inicio:
	call 	Pausa 				; Espera por 30 milisegundos
	;btfss	INTCON,2
	;goto	Inicio
	;bcf		INTCON,2
;-----                        
	bsf 	ADCON0,2			; Inicio del proceso de conversión A/D.
;-----     
Espera:
	btfsc	ADCON0,2 			; ¿Se terminó la conversión? 
  goto 	Espera				; No, espera...
;-----
	movf 	ADRESH,W 			; Lectura de la parte más significativa (2 bits)
 	movwf PORTE					; Muestra en PORTE
 	
 	bsf 	STATUS,RP0		; Salto a BANCO "1"           
 	movf 	ADRESL,W 			; Lectura de los bits menos significativos (8 bits)
 	bcf 	STATUS,RP0		; Salto a BANCO "0"
 	movwf PORTD					; Muestra en PORTD
 	
;-----
 	goto 	Inicio				;	Vamos por otra lectura
;-----  
   
Pausa:
	movlw 0x23          ; 0x23
  movwf Cont
Rep:
  decfsz 	Cont,F
 	goto		Rep
	return
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	

	END
     

