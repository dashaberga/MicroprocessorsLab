#include p18f87k22.inc
   
    global Press_test
    
    Keypad code
    
Press_test
    movlw    0x00
    movwf    PORTE
    banksel  PADCFG1 
    bsf      PADCFG1, REPU, BANKED
    movlb    0x00
    movlw    0x0F    ;sets 0-3 to output and 4-7 to input
    movwf    TRISE
    movff    PORTE, WREG 
    movwf    0x06
    movlw    0xF0    ;sets 4-7 to output and 0-3 to input
    movwf    TRISE
    movff    PORTE, WREG
    movff    PORTE, WREG 
    movwf    0x06
    
    return
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end


