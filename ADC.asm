#include p18f87k22.inc

    global  ADC_Setup, ADC_Read
    
    
acs0 udata_acs
RES0 res 1
RES1 res 1
RES2 res 1
RES3 res 1
RES4 res 1
RES5 res 1
RES6 res 1
counter1 res 1
counter2 res 1

    
ADC    code
    
ADC_Setup
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    movlw   0x01	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    movlw   0x00
    movwf   counter1
    movwf   counter2   
    
    return

ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    
    MOVF    ADRESL, W 
    MULLW   0x8A	    ; ARG1L * ARG2L-> 
			    ; PRODH:PRODL 
    MOVFF   PRODH, RES1 
    MOVFF   PRODL, RES0 
			    ; 
    MOVF    ADRESH, W 
    MULLW   0x41	    ; ARG1H * ARG2H-> 
			    ; PRODH:PRODL 
    MOVFF   PRODH, RES3	    ; 
    MOVFF   PRODL, RES2	    ; 
    ; 
    MOVF    ADRESL, W 
    MULLW   0x41		    ; ARG1L * ARG2H-> 
	
    MOVF    PRODL, W	    ; 
    ADDWF   RES1	    ; Add cross 
    MOVF    PRODH, W	    ; products 
    ADDWFC  RES2	    ;	  
    CLRF    WREG		     
    ADDWFC  RES3	    ; 
			    ; 
    MOVF    ADRESH, W	    ; 
    MULLW   0x8A	    ; ARG1H * ARG2L-> 
			    ; PRODH:PRODL 
    MOVF    PRODL, W	    ; 
    ADDWF   RES1	    ; Add cross 
    MOVF    PRODH, W	    ; products 
    ADDWFC  RES2	    ; 
    CLRF    WREG		 
    ADDWFC  RES3	    ;
     
    swapf   RES3, 1, 0
    movff   RES3, ADRESH
    	
multiply
    MOVF    RES0, W 
    MULLW   0x0A	    ; ARG1L * ARG2L-> 
			    ; PRODH:PRODL 
    MOVFF   PRODH, RES4 
    MOVFF   PRODL, RES3 
			    ; 
    MOVF    RES2, W 
    MULLW   0x0A	    ; ARG1H * ARG2H-> 
			    ; PRODH:PRODL 
    MOVFF   PRODH, RES6	    ; 
    MOVFF   PRODL, RES5	    ; 
    
    MOVF    RES1, W 
    MULLW   0x0A
    
    MOVF    PRODL, W	    ; 
    ADDWF   RES4	    ; Add cross 
    MOVF    PRODH, W	    ; products 
    ADDWFC  RES5	    ;	  
    CLRF    WREG		     
    ADDWFC  RES6
    
    incf    counter1
    movff   counter1, counter2
    decf    counter2
    bz	    first
    decf    counter2
    bz	    second
    decf    counter2
    bz	    third
    
    
first
    movf    RES6, W
    Addwf   ADRESH
    movff   RES3, RES0
    movff   RES4, RES1
    movff   RES5, RES2
    bra	    multiply
    
second
    swapf   RES6, 1, 0
    movff   RES6, ADRESL
    movff   RES3, RES0
    movff   RES4, RES1
    movff   RES5, RES2
    bra	    multiply
    
third
    movf    RES6, W
    Addwf   ADRESL
    movlw   0x00
    movwf   counter1
    movwf   counter2
    
finish
    return

    end