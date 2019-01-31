#include p18f87k22.inc
   
    
    global Press_test, Keypad_Setup
    extern LCD_Write_Message, Line_set_2, Line_set_1
    
 
 acs0	udata_acs   ; reserve data space in access ram
 counter1 res 1
 output1  res 1
 output2  res 1
 input1   res 1
 input2   res 1
 cnt_l    res 1   ; reserve 1 byte for variable cnt_l
 cnt_h    res 1   ; reserve 1 byte for variable cnt_h
 cnt_ms   res 1   ; reserve 1 byte for ms counter
 position res 1   ; reserve 1 byte for tracking position on screen.
		  ; lowest 4 bits are x, next bit is y
   
 Keypad code
    
Keypad_Setup
    movlw    0x00
    movwf    position
    movlw    0x00
    movwf    PORTH
    movwf    TRISH
 
Press_test
    movlw    0x01
    movwf    counter1    
    movlw    0x00
    movwf    PORTE
    banksel  PADCFG1 
    bsf      PADCFG1, REPU, BANKED
    movlb    0x00
Press_test_1    
    movlw    0x0F    ;sets 0-3 to output and 4-7 to input
    movwf    TRISE
    movlw    .2
    call     delay_ms
    movff    PORTE, WREG 
    movwf    input1
    movwf    input2
    
    movlw    0x0F
    subwf    input1
    bz    no_press
    movff    input2, input1
    
    movlw    0x0E
    subwf    input1
    bz    button_select
    movff    input2, input1
    
    movlw    0x0D
    subwf    input1
    bz    button_select
    movff    input2, input1
    
    movlw    0x0B
    subwf    input1
    bz    button_select
    movff    input2, input1
    
    movlw    0x07
    subwf    input1
    bz    button_select
    movff    input2, input1
    
    bra invalid
    
Press_test_2
    movlw    0xF0    ;sets 4-7 to output and 0-3 to input
    movwf    TRISE
    movlw    .2
    call     delay_ms
    movff    PORTE, WREG
    movwf    input1
    movwf    input2
    
    movlw    0xE0
    subwf    input1
    bz    button_select2
    movff    input2, input1
    
    movlw    0xD0
    subwf    input1
    bz    button_select2
    movff    input2, input1
    
    movlw    0xB0
    subwf    input1
    bz    button_select2
    movff    input2, input1
    
    movlw    0x70
    subwf    input1
    bz    button_select2
    movff    input2, input1
    
    bra invalid
        
button_select
    movff    input2, output1
    bra Press_test_2
    
button_select2
    movf    input2, W
    addwf   output1
    tstfsz  counter1
    bra     something
    movf    output1, WREG
    subwf   output2
    bz      press
    bra     invalid
        
something    
    movff   output1, output2
    decf    counter1
    movlw .2
    call delay_ms
    bra     Press_test_1
    
press
   movff output1, 0x0A
   bra translate    
    
no_press
    movlw 0xFF
    movwf 0x0A
    return
invalid
    return    
    
delay_ms		    ; delay given in ms in W
	movwf	cnt_ms
lp2	movlw	.250	    ; 1 ms delay
	call	delay_x4us	
	decfsz	cnt_ms
	bra	lp2
	return
    
delay_x4us		    ; delay given in chunks of 4 microsecond in W
	movwf	cnt_l   ; now need to multiply by 16
	swapf   cnt_l,F ; swap nibbles
	movlw	0x0f	    
	andwf	cnt_l,W ; move low nibble to W
	movwf	cnt_h   ; then to cnt_h
	movlw	0xf0	    
	andwf	cnt_l,F ; keep high nibble in LCD_cnt_l
	call	delay
	return

delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lp1	decf 	cnt_l,F	; no carry when 0x00 -> 0xff
	subwfb 	cnt_h,F	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return	    
    
translate        ;multiple if statements for every valid command
	movff output1, output2
	movlw 0xEE
	subwf output2
	bz character1
	
	movff output1, output2
	movlw 0xED
	subwf output2
	bz character2
	
	movff output1, output2
	movlw 0xEB
	subwf output2
	bz character3
	
	movff output1, output2
	movlw 0xDE
	subwf output2
	bz character4
	
	movff output1, output2
	movlw 0xDD
	subwf output2
	bz character5
	
	movff output1, output2
	movlw 0xDB
	subwf output2
	bz character6
	
	movff output1, output2
	movlw 0xBE
	subwf output2
	bz character7
	
	movff output1, output2
	movlw 0xBD
	subwf output2
	bz character8
	
	movff output1, output2
	movlw 0xBB
	subwf output2
	bz character9
	
	movff output1, output2
	movlw 0x7D
	subwf output2
	bz character0
	
	movff output1, output2
	movlw 0x7E
	subwf output2
	bz characterA
	
	movff output1, output2
	movlw 0x7B
	subwf output2
	bz characterB
	
	movff output1, output2
	movlw 0x77
	subwf output2
	bz characterC
	
	movff output1, output2
	movlw 0xB7
	subwf output2
	bz characterD
	
	movff output1, output2
	movlw 0xD7
	subwf output2
	bz characterE
	
	movff output1, output2
	movlw 0xE7
	subwf output2
	bz characterF
	
character1	;print the ascii character onto the screen
	movlw   0x31
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character2	
	movlw   0x32
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character3	
	movlw   0x33
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character4	
	movlw   0x34
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character5	
	movlw   0x35
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character6	
	movlw   0x36
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character7	
	movlw   0x37
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character8	
	movlw   0x38
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character9	
	movlw   0x39
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character0	
	movlw   0x30
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
characterA	
	movlw   0x41
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
characterB	
	movlw   0x42
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
characterC	
	movlw   0x43
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
characterD	
	movlw   0x44
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
characterE	
	movlw   0x45
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
characterF	
	movlw   0x46
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
    
release   ;detects when a button is released
	movff    output1, output2
	movlw    0xF0    ;sets 0-3 to output and 4-7 to input
        movwf    TRISE
        movlw    .2
        call     delay_ms
	movff    PORTE, WREG
	subwf    output2
	movlw    0x0F    ;sets 0-3 to output and 4-7 to input
        movwf    TRISE
        movlw    .2
        call     delay_ms
        movff    PORTE, WREG
	subwf    output2
	bz       release
	
	movlw    0x0F
	cpfseq   position
	bra      line2
	bra      line_change
line2
	movlw    0x1F
	cpfseq   position
	bra      finish
	bra      line_change
finish
	incf     position
finish2
	movff    position, PORTH
	return
	
line_change
    movlw    0x0F
    subwf    position
    bz       set_line2
    movlw    0x00
    movwf    position
    call     Line_set_1
    bra      finish2
set_line2
    movlw    0x10
    movwf    position
    call     Line_set_2
    bra      finish2
    
end


