#include p18f87k22.inc

    global  Multiply_Setup, multiply
    
    
acs0 udata_acs
input res 1
RES0 res 1
RES1 res 1
RES2 res 1
RES3 res 1
RES4 res 1
RES5 res 1
RES6 res 1
output res 1
counter1 res 1
counter2 res 1

    
ADC    code
    
Multiply_Setup
    movlw   0x00
    movwf   counter1
    movwf   counter2   
    return
    	
multiply
    movwf   input
    
    MOVF    input, W 
    MULLW   0x8A	    ; ARG1L * ARG2L-> 
			    ; PRODH:PRODL 
    MOVFF   PRODH, RES1 
    MOVFF   PRODL, RES0 
			    ; 
    MOVF    0x00, W 
    MULLW   0x41	    ; ARG1H * ARG2H-> 
			    ; PRODH:PRODL 
    MOVFF   PRODL, RES2	    ; 
    ; 
    MOVF    input, W 
    MULLW   0x41		    ; ARG1L * ARG2H-> 
	
    MOVF    PRODL, W	    ; 
    ADDWF   RES1	    ; Add cross 
    MOVF    PRODH, W	    ; products 
    ADDWFC  RES2	    ;	  	    ; 
			    ; 
    MOVF    0x00, W	    ; 
    MULLW   0x8A	    ; ARG1H * ARG2L-> 
			    ; PRODH:PRODL 
    MOVF    PRODL, W	    ; 
    ADDWF   RES1	    ; Add cross 
    MOVF    PRODH, W	    ; products 
    ADDWFC  RES2	    ; 
    
multiply_1
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
    movff   RES3, RES0
    movff   RES4, RES1
    movff   RES5, RES2
    bra	    multiply_1
    
second
    swapf   RES6, 1, 0
    movff   RES6, output
    movff   RES3, RES0
    movff   RES4, RES1
    movff   RES5, RES2
    bra	    multiply_1
    
third
    movf    RES6, W
    Addwf   output
    movlw   0x00
    movwf   counter1
    movwf   counter2
    
    movf    output, W
    
finish
    return

    end