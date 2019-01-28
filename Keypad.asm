#include p18f87k22.inc
   
    global Press_test
    
    Keypad code
    
Press_test
    movlw    0x02
    movwf    0x0B    
    movlw    0x00
    movwf    PORTE
    banksel  PADCFG1 
    bsf      PADCFG1, REPU, BANKED
    movlb    0x00
Press_test_1    
    movlw    0x0F    ;sets 0-3 to output and 4-7 to input
    movwf    TRISE
    movff    PORTE, WREG 
    movwf    0x08
    movwf    0x09
    
    movlw    0x0F
    subwf    0x08
    bz    no_press
    movff    0x09, 0x08
    
    movlw    0x0E
    subwf    0x08
    bz    button_select
    movff    0x09, 0x08
    
    movlw    0x0D
    subwf    0x08
    bz    button_select
    movff    0x09, 0x08
    
    movlw    0x0B
    subwf    0x08
    bz    button_select
    movff    0x09, 0x08
    
    movlw    0x07
    subwf    0x08
    bz    button_select
    movff    0x09, 0x08
    
    bra no_press
    
Press_test_2
    movlw    0xF0    ;sets 4-7 to output and 0-3 to input
    movwf    TRISE
    movff    PORTE, WREG
    movwf    0x08
    movwf    0x09
    
    movlw    0xE0
    subwf    0x08
    bz    button_select2
    movff    0x09, 0x08
    
    movlw    0xD0
    subwf    0x08
    bz    button_select2
    movff    0x09, 0x08
    
    movlw    0xB0
    subwf    0x08
    bz    button_select2
    movff    0x09, 0x08
    
    movlw    0x70
    subwf    0x08
    bz    button_select2
    movff    0x09, 0x08
    
    bra no_press
        
button_select
    movff    0x09, 0x0A
    bra Press_test_2
    
button_select2
    movf    0x09, W
    addwf   0x0A
    decfsz  0x0B
    bra Press_test_1
    
    
    
    
    
    
    
    

press    
    
no_press    
    return    
    
    
    
    
    
end


