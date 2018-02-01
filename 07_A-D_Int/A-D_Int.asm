;El módulo convertidor ADC. Interrupción trás la conversión. Voltímetro digital
;
;Este ejemplo visualiza sobre la pantalla LCD el valor obtenido por el convertidor a partir
;de una tensión analógica de entrada de entre 0 y 5Vcc que se aplica por la entrada RA0/AN0.
;A lo que indique el LCD se le debe multiplicar 0.004887 (resolución/bit) para obtener la
;tensión de entrada en RA0/AN0.

        List    p=16F886        ;Tipo de procesador
        include    "P16F886.INC"    ;Definiciones de registros internos

;Ajusta los valores de las palabras de configuración durante el ensamblado.Los bits no empleados
;adquieren el valor por defecto.Estos y otros valores se pueden modificar según las necesidades

;        __config    _CONFIG1, _LVP_OFF&_PWRTE_ON&_WDT_OFF&_EC_OSC&_FCMEN_OFF&_BOR_OFF    ;Palabra 1 de configuración
;        __config    _CONFIG2, _WRT_OFF&_BOR40V                                    ;Palabra 2 de configuración

            cblock    0x20            ;Inicio de variables de la aplicación
                Byte_L                ;Parte baja del byte a convertir
                Byte_H                ;Parte alta del byte a convertir
                BCD_2                ;Byte 2 de conversión a BCD
                BCD_1                ;Byte 1 de conversión a BCD
                BCD_0                ;Byte 0 de conversión a BCD
                Contador            ;Variable de contaje
                Temporal            
                Temporal_1
                Temporal_2            ;Variables temporales
            endc        

Lcd_var            equ    0x70            ;Variables de las rutinas LCD
    
                org    0x00
                goto    Inicio        ;Vector de reset
                org    0x04
                goto    Inter        ;Vector de interrupción
                org    0x05

;******************************************************************************************
;Según el valor contenido en el registro W, se devuelve el carácter a visualizar

Tabla_Mensajes    movwf    PCL        ;Calcula el desplazamiento sobre la tabla

;***********************************************************************************
;La directiva DT genera tantas intsrucciones RETLW como bytes o caracteres contenga

Mens_0            equ    $        ;Mens_0 apunta al primer carácter del mensaje 0
                dt    "AN0=    (*4.8mV)",0x00

        include    "LCD4bitsPIC16.inc"        ;Incluye rutinas de manejo del LCD

;*************************************************************************************
;Mensaje: Esta rutina envía a la pantalla LCD el mensaje cuyo inicio está  indicado en
;el acumulador. El fin de un mensaje se determina mediante el código 0x00

Mensaje            movwf      Temporal_1         ;Salva posición de la tabla
Mensaje_1          movf       Temporal_1,W       ;Recupera posición de la tabla
                   call       Tabla_Mensajes     ;Busca caracter de salida
                   movwf      Temporal_2         ;Guarda el caracter
                movf       Temporal_2,F
                btfss      STATUS,Z           ;Mira si es el último
                goto       Mensaje_2
                return
Mensaje_2       call    LCD_DATO           ;Visualiza en el LCD
                incf    Temporal_1,F       ;Siguiente caracter
                goto    Mensaje_1

;****************************************************************************************
;Inter: Programa de tratamiento de interrupción cuando finaliza una conversión. Lee el 
;resultado, lo convierte a BCD y lo visualiza sobre la pantalla LCD
Inter            movf    ADRESH,W
                movwf    Byte_H
                bsf        STATUS,RP0        ;Banco 1
                movf    ADRESL,W
                bcf        STATUS,RP0        ;Banco 0
                movwf    Byte_L            ;Lee y salva el resultado de la conversión
                call    Bits16_BCD        ;Convierte a BCD
                movlw    0x84
                call    LCD_REG            ;Coloca el cursor
                call    Visualizar        ;Visualiza sobre el LCD
                bsf        ADCON0,GO_DONE    ;Inicia una nueva conversión
                retfie
    
;Visualizar: Visualiza sobre la pantalla LCD, en la posición actual del cursor, los cuatro 
;dígitos situados en las variables BC_1 y BCD_2
Visualizar        movlw    2
                movwf    Contador        ;Inicia contador de bytes a convertir
                movlw    BCD_1
                movwf    FSR                ;Inicia puntero índice
Visual_loop        swapf    INDF,W
                andlw    0x0f
                iorlw    0x30            ;Convierte a ASCII el nible de más peso
                call    LCD_DATO        ;Lo visualiza
                movf    INDF,W
                andlw    0x0f
                iorlw    0x30            ;Convierte a ASCII el nible de menos peso
                call    LCD_DATO        ;Lo visualiza
                decf    FSR,F            ;Siguiente byte
                decfsz    Contador,F
                goto    Visual_loop
                return

;16Bits_BCD: Esta rutina convierte un número binario de 16 bits situado en Cont_H y
;Cont_L y, lo convierte en 5 dígitos BCD que se depositan en las variables BCD_0, BCD_1
;y BCD_2, siendo esta última la de menos peso.
;Está presentada en la nota de aplicación AN544 de MICROCHIP y adaptada por MSE
Bits16_BCD        bcf        STATUS,C
                clrf    Contador    
                bsf        Contador,4        ;Carga el contador con 16        
                clrf    BCD_0
                clrf    BCD_1
                clrf    BCD_2            ;Puesta a 0 inicial

Loop_16            rlf        Byte_L,F
                rlf        Byte_H,F
                rlf        BCD_2,F
                rlf        BCD_1,F
                rlf        BCD_0,F            ;Desplaza a izda. (multiplica por 2)
                decfsz    Contador,F
                goto    Ajuste
                return

Ajuste            movlw    BCD_2
                movwf    FSR                ;Inicia el índice
                call    Ajuste_BCD        ;Ajusta el primer byte
                incf    FSR,F
                call    Ajuste_BCD        ;Ajusta el segundo byte
                incf    FSR,F
                call    Ajuste_BCD
                goto    Loop_16

Ajuste_BCD        movf    INDF,W        
                addlw    0x03
                movwf    Temporal    
                btfsc    Temporal,3        ;Mayor de 7 el nibble de menos peso ??
                movwf    INDF            ;Si, lo acumula
                movf    INDF,W        
                addlw    0x30
                movwf    Temporal
                btfsc    Temporal,7        ;Mayor de 7 el nibble de menos peso ??
                movwf    INDF            ;Si, lo acumula
                return

;Programa principal
Inicio               clrf    PORTA
                clrf    PORTB            ;Borra salidas
                bsf        STATUS,RP0
                bsf        STATUS,RP1        ;Banco 3
                movlw    b'00000001'
                movwf    ANSEL            ;RA0/AN0/C12IN0- entrada analógica, resto digitales
                clrf    ANSELH            ;Puerta B digital
                bcf        STATUS,RP1        ;Banco 1
                clrf    TRISB            ;Puerta B se configura como salida
                movlw    b'11110001'
                movwf    TRISA            ;RA3:RA1 salidas
                bcf        STATUS,RP0        ;Selecciona banco 0

;Inicio de la pantalla LCD y visualiza mensaje inicial
                call    UP_LCD            ;Configura E/S para el LCD
                call    LCD_INI            ;Secuencia de inicio del LCD
                movlw    b'00001100'
                call    LCD_REG            ;LCD On, cursor y blink Off
                movlw    Mens_0
                call    Mensaje            ;Visualiza "AN0=    (*4.8mV)"

;Se activa el ADC y se selecciona el canal RA0/AN0.    Frec. de conversión = Fosc/32        
                bsf        STATUS,RP0        ;Selecciona página 1
                movlw    b'10000000'
                movwf    ADCON1            ;Alineación dcha. Vref= VDD
                bcf        STATUS,RP0        ;Selecciona página 0
                movlw    b'10000001'
                movwf    ADCON0            ;ADC en On, seleciona canal RA0/AN0 y Fosc/32

;Habilita interrupción provocada al finalizar la conversión
                bcf        PIR1,ADIF        ;Restaura el flag del conversor AD
                bsf        STATUS,RP0        ;Banco 1
                bsf        PIE1,ADIE        ;Activa interrupción del ADC
                bcf        STATUS,RP0        ;Banco 0
                bsf        INTCON,PEIE        ;Habilita interrupciones de los periféricos
                bsf        INTCON,GIE        ;Habilita interrupciones
                bsf        ADCON0,GO_DONE    ;Inicia la conversión

;Bucle principal
            
Loop            nop
                goto    Loop            ;Repetir la lectura

                end                        ;Fin del programa fuente