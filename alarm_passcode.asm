#include p18f87k22.inc

    global  passcode_set, passcode_test, passcode_test1, passcode_test2
    extern  multiply, multiply_random, random, random2
    extern  mode_counter
    


acs0    udata_acs   ; named variables in access ram
passcode_cnt res 1
passcode_test1 res 1
passcode_test2 res 1
passcode_temp  res 1
passcode_temp2 res 1
 
passcodes udata 0x600
passcode res 0x50
 
alarm_passcode code 
 
passcode_set
    lfsr    1, 0x600
    movlw   0x00
    movwf   passcode_cnt
passcode_loop
    movff   random2, WREG
    call    multiply
    movwf   POSTINC1
    movff   random, WREG
    call    multiply
    movwf   POSTINC1
    movff   random2, POSTINC1
    movff   random, POSTINC1
    call    multiply_random
    incf    passcode_cnt
    movlw   0x14
    cpfseq  passcode_cnt
    bra	    passcode_loop
    return

passcode_test
    lfsr    1, 0x600
    movlw   0x00
    movwf   passcode_cnt
passcode_test_loop
    movlw   0x14
    cpfseq  passcode_cnt
    bra	    passcode_test_loop2
    return
passcode_test_loop2
    movff   POSTINC1, passcode_temp2
    movff   POSTINC1, passcode_temp
    incf    passcode_cnt
    movff   passcode_test2, WREG
    subwf   passcode_temp2
    bnz	    passcode_test_loop
    movff   passcode_test, WREG
    subwf   passcode_temp
    bnz	    passcode_test_loop3
    clrf    mode_counter
    bsf	    mode_counter, 3
    clrf    LATH
    movff   POSTINC1, random2
    movff   POSTINC1, random
    call    passcode_set
    return
    
passcode_test_loop3
    incf    FSR1
    incf    FSR1
    bra	    passcode_test_loop
    
    end