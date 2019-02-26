#include p18f87k22.inc

    global  Multiply_Setup, multiply, random, random2, multiply_random
    
    
acs0 udata_acs
input res 1	    ; reserve 1 byte for input
RES0 res 1	    ; reserve 1 byte for result 0
RES1 res 1	    ; reserve 1 byte for result 1
RES2 res 1	    ; reserve 1 byte for result 2
RES3 res 1	    ; reserve 1 byte for result 3
RES4 res 1	    ; reserve 1 byte for result 4
RES5 res 1	    ; reserve 1 byte for result 5
RES6 res 1	    ; reserve 1 byte for result 6
output res 1	    ; reserve 1 byte for output
random res 1	    ; reserve 1 byte for random number (lower byte)
random2 res 1	    ; reserve 1 byte for random number (higher byte)
counter1 res 1	    ; reserve 1 byte for counter 1
counter2 res 1	    ; reserve 1 byte for counter 2

    
ADC    code
    
Multiply_Setup
    clrf   counter1
    clrf   counter2   
    return
    	
multiply    ; subroutine for turning a byte of Hex into a decimal number (0-99)
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
    MULLW   0x41	    ; ARG1L * ARG2H-> 
	
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
    
multiply_1  ; multiply by 10 to get the rest of the digits
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
    
    incf    counter1		; increment counter
    movff   counter1, counter2	; test counter value & branch appropriately
    decf    counter2
    bz	    first
    decf    counter2
    bz	    second
    decf    counter2
    bz	    third
    
    
first	; move answers back into inputs & rerun
    movff   RES3, RES0
    movff   RES4, RES1
    movff   RES5, RES2
    bra	    multiply_1
    
second	; save largest nibble, move answers back into inputs & rerun
    swapf   RES6, 1, 0
    movff   RES6, output
    movff   RES3, RES0
    movff   RES4, RES1
    movff   RES5, RES2
    bra	    multiply_1
    
third	; save largest nibble, move answers back into inputs & output result
    movf    RES6, W
    Addwf   output
    clrf   counter1
    clrf   counter2
    
    movf    output, W
    
finish
    return

multiply_random	; Linear congruential generator for random number generation
		; 2 byte numbers input & output, m = 65536, a = 13, c = 13
		; instead of dividing by m, uses overflow of 2 byte number
    movlw   0x0d
    MULWF   random	    ; ARG1L * ARG2L-> 
			    ; PRODH:PRODL 
    MOVFF   PRODH, RES1 
    MOVFF   PRODL, RES0 
			    ; 
    MOVF    0x00, W 
    MULWF   random2	    ; ARG1H * ARG2H-> 
			    ; PRODH:PRODL 
    MOVFF   PRODL, RES2	    ; 
    ; 
    MOVLW    0x0d
    MULWF   random2	    ; ARG1L * ARG2H-> 
	
    MOVF    PRODL, W	    ; 
    ADDWF   RES1	    ; Add cross 
    MOVF    PRODH, W	    ; products 
    ADDWFC  RES2	    ;	  	    ; 
			    ; 
    MOVF    0x00, W	    ; 
    MULWF   random	    ; ARG1H * ARG2L-> 
			    ; PRODH:PRODL 
    MOVF    PRODL, W	    ; 
    ADDWF   RES1	    ; Add cross 
    MOVF    PRODH, W	    ; products 
    ADDWFC  RES2	    ; 
    
    movff   RES1, random2   ; save output
    movff   RES0, random
    
    movlw   0x0d	    ; add c
    addwf   random
    CLRF    WREG
    ADDWFC  random2
    
    bra finish    
    
    
    
    
    
    end