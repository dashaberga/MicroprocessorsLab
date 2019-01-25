#include p18f87k22.inc
   
    
Press_test
    movlw 0x00
    movwf PORTE
    bsf PADCFG1, REPU, BANKED
    
    movlw 0x0F    ;sets 0-3 to output and 4-7 to input
    movwf TRISE
    
    movlw 0x0F    ;sets 4-7 to output and 0-3 to input
    movwf TRISE
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end
