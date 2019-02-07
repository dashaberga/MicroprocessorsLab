#include p18f87k22.inc

    global  Multiply_Setup
    
    
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
    
Multiply_Setup
    movlw   0x00
    movwf   counter1
    movwf   counter2   
    return
    	
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