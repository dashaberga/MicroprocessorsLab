#include p18f87k22.inc

    global  passcode_set, passcode_test, passcode_test1, passcode_test2
    extern  multiply, multiply_random, random, random2
    extern  mode_counter
    
acs0    udata_acs	; named variables in access ram
passcode_cnt res 1	; passcode counter, tracks how many valid codes there are
passcode_test1 res 1	; trial passcode from input on screen, to be tested
passcode_test2 res 1	; trial passcode from input on screen, to be tested
passcode_temp  res 1	; temporary storage for trial passcodes
passcode_temp2 res 1	; temporary storage for trial passcodes
 
passcodes udata 0x600	; reserve 50 bytes in memory for valid passcodes & seeds
passcode res 0x50
 
alarm_passcode code 
 
passcode_set	; stores 20 random numbers in Hex, and converts them to decimal
		; hex numbers greater than 100 only use last 2 decimal digits
		; ie  hex equivalent 024, 124, 224 all produce code 24
    lfsr    1, 0x600	    ; set file select register 1 to passcode location
    clrf   passcode_cnt	    ; clear passcode counter
passcode_loop
    movff   random2, WREG   ; move random number (higher) to W
    call    multiply	    ; translate it Hex to Dec
    movwf   POSTINC1	    ; move to FSR1 location & increment FSR1
    movff   random, WREG    ; move random number (lower) to W
    call    multiply	    ; translate it Hex to Dec
    movwf   POSTINC1	    ; move to FSR1 location & increment FSR1
    movff   random2, POSTINC1	; move random number (higher) to FSR1 & inc FSR
    movff   random, POSTINC1	; move random number (lower) to FSR1 & inc FSR
    call    multiply_random	; generates new random Hex number, using previous number as a seed
    incf    passcode_cnt    ; increment passcode counter
    movlw   0x14
    cpfseq  passcode_cnt    ; check when 20 codes have been generated
    bra	    passcode_loop   ; loop if less than 20 codes generated
    lfsr    1, 0x600	    ; move file select register to first code
    movlw   0xFF	    
    movwf   POSTINC1	    ; erase first code (to prevent multiple uses)
    movwf   POSTINC1
    return

passcode_test	; take input code from Keypad/LCD and compares it to valid codes
		; if valid, clears the snooze countdown & snooze alarm modes
    lfsr    1, 0x600	    ; set file select register 1 to passcode location
    clrf   passcode_cnt	    ; clear passcode counter
passcode_test_loop
    movlw   0x14
    cpfseq  passcode_cnt    ; if all 20 codes checked, return
    bra	    passcode_test_loop2
    return
passcode_test_loop2
    movff   POSTINC1, passcode_temp2	; move valid code to temp storage
    movff   POSTINC1, passcode_temp
    incf    passcode_cnt		; increment passcode counter
    movff   passcode_test2, WREG	; test if higher bytes are the same
    subwf   passcode_temp2
    bnz	    passcode_test_loop3		; if not the same, loop back
    movff   passcode_test, WREG		; test if lower bytes are the same
    subwf   passcode_temp
    bnz	    passcode_test_loop3		; if not the same, loop back
    clrf    mode_counter		; clear mode counter & enable alarm
    bsf	    mode_counter, 3
    clrf    LATH			; clear LATH (disable alarm)
    incf    FSR1			; increment file select register
    incf    FSR1
    incf    FSR1
    incf    FSR1
    movff   POSTINC1, random2		; place new seed into rng
    movff   POSTINC1, random
    call    passcode_set		; generate new codes with rng
    return
    
passcode_test_loop3
    incf    FSR1			; increment FSR1 past rng seeds
    incf    FSR1
    bra	    passcode_test_loop		; loop back to passcode test loop
    
    end