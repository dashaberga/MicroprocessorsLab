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
 
passcodes udata 0x500
passcode res 0x50
 
alarm_passcode code 
 
passcode_set
    lfsr    0, passcode
    movlw   0x00
    movwf   passcode_cnt
passcode_loop
    movff   random2, WREG
    call    multiply
    movwf   POSTINC0
    movff   random, WREG
    call    multiply
    movwf   POSTINC0
    movff   random2, POSTINC0
    movff   random, POSTINC0
    call    multiply_random
    incf    passcode_cnt
    movlw   0x14
    cpfseq  passcode_cnt
    bra	    passcode_loop
    return

passcode_test
    lfsr    0, passcode
    movlw   0x00
    movwf   passcode_cnt
passcode_test_loop
    movlw   0x14
    cpfseq  passcode_cnt
    bra	    passcode_test_loop2
    return
passcode_test_loop2
    movff   POSTINC0, passcode_temp2
    movff   POSTINC0, passcode_temp
    incf    passcode_cnt
    movff   passcode_test2, WREG
    subwf   passcode_temp2
    bnz	    passcode_test_loop
    movff   passcode_test, WREG
    subwf   passcode_temp
    bnz	    passcode_test_loop3
    clrf    mode_counter
    bsf	    mode_counter, 3
    movff   POSTINC0, random2
    movff   POSTINC0, random
    call    passcode_set
    return
    
passcode_test_loop3
    incf    FSR0
    incf    FSR0
    bra	    passcode_test_loop
    
    end