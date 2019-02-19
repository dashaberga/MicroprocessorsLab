#include p18f87k22.inc
   
    
    global Press_test, Keypad_Setup
    extern LCD_Write_Message, Line_set_2, Line_set_1
    extern mode_counter, write_date, write_time
    extern time_sec, time_min, time_hour, time_day, time_week, time_month, time_year, month_days, inc_month
    
 
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
set_position res 1
   
Keypad code
    
Keypad_Setup
    movlw    0x00
    movwf    position
 
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
    movf    output1, w
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
	bz character10
	
	movff output1, output2
	movlw 0xED
	subwf output2
	bz character20
	
	movff output1, output2
	movlw 0xEB
	subwf output2
	bz character30
	
	movff output1, output2
	movlw 0xDE
	subwf output2
	bz character40
	
	movff output1, output2
	movlw 0xDD
	subwf output2
	bz character50
	
	movff output1, output2
	movlw 0xDB
	subwf output2
	bz character60
	
	movff output1, output2
	movlw 0xBE
	subwf output2
	bz character70
	
	movff output1, output2
	movlw 0xBD
	subwf output2
	bz character80
	
	movff output1, output2
	movlw 0xBB
	subwf output2
	bz character90
	
	movff output1, output2
	movlw 0x7D
	subwf output2
	bz character00
	
	movff output1, output2
	movlw 0x7E
	subwf output2
	bz characterA0
	
	movff output1, output2
	movlw 0x7B
	subwf output2
	bz characterB0
	
	movff output1, output2
	movlw 0x77
	subwf output2
	bz characterC0
	
	movff output1, output2
	movlw 0xB7
	subwf output2
	bz characterD0
	
	movff output1, output2
	movlw 0xD7
	subwf output2
	bz characterE0
	
	movff output1, output2
	movlw 0xE7
	subwf output2
	bz characterF0

character10
	goto character1
character20
	goto character2
character30
	goto character3
character40
	goto character4
character50
	goto character5
character60
	goto character6
character70
	goto character7
character80
	goto character8
character90
	goto character9
character00
	goto character0
characterA0
	goto characterA 
characterB0
	goto characterB
characterC0
	goto characterC
characterD0
	goto characterD
characterE0
	goto characterE
characterF0
	goto characterF
	
	
	
character1	;print the ascii character onto the screen
	movlw   0x31
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character2	
	btfsc   mode_counter, 0
	bra	up
	btfsc   mode_counter, 1
	bra     up_date
	goto	other1
up
	movff set_position, output1
	movlw 0x00
	subwf output1
	bz hour_up
	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz minute_up
	
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz second_up
	
	movff set_position, output1
	movlw 0x03
	subwf output1
	bz week_up
	
hour_up
	movff time_hour, output1
	movlw 0x17
	subwf output1
	bz no_increase
	incf time_hour
	call write_time
	goto release
minute_up
	movff time_min, output1
	movlw 0x3b
	subwf output1
	bz no_increase
	incf time_min
	call write_time
	goto release
second_up
	movff time_sec, output1
	movlw 0x3b
	subwf output1
	bz no_increase
	incf time_sec
	call write_time
	goto release
week_up
	movff time_week, output1
	movlw 0x07
	subwf output1
	bz no_increase
	incf time_week
	call write_time
	
up_date
	movff set_position, output1
	movlw 0x00
	subwf output1
	bz day_up
	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz month_up
	
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz year_up
	
day_up
	movff time_day, output1
	movf  month_days, WREG
	subwf output1
	bz no_increase
	incf time_day
	call write_date
	goto release
month_up
	movff time_month, output1
	movlw 0x0c
	subwf output1
	bz no_increase
	call inc_month
	incf time_month
	call write_date
	goto release
year_up
	movff time_year, output1
	incf time_year
	call write_date
	goto release
no_increase
	goto release
	
other1
	bra release
character3	
	movlw   0x33
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character4	
	btfsc   mode_counter, 0
	bra	left
	btfsc   mode_counter, 1
	bra     left_date
	bra	other1
left	
	movff set_position, output1
	movlw 0x00
	subwf output1
	bz other1
	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz position_n1
	
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz position_n2
	
	movff set_position, output1
	movlw 0x03
	subwf output1
	bz position_n3
	
position_n1	
	decf set_position
	call Line_set_2
	call chevron
	call chevron
	call spaces1
	call spaces1
	call spaces1
	bra other1
	
position_n2
	decf set_position
	call Line_set_2
	call spaces1
	call spaces1
	call spaces1
	call chevron
	call chevron
	call spaces1
	call spaces1
	call spaces1
	bra other1
	
position_n3
	decf set_position
	call Line_set_2
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call chevron
	call chevron
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	bra other1
	
left_date
	movff set_position, output1
	movlw 0x00
	subwf output1
	bz other
	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz position_n1_date
	
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz position_n2_date
	
position_n1_date
	
	decf set_position
	call Line_set_1
	call chevron_v
	call chevron_v
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	bra other
	
position_n2_date
	decf set_position
	call Line_set_1
	call spaces1
	call spaces1
	call spaces1
	call chevron_v
	call chevron_v
	call chevron_v
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	bra other
other
	bra     release
	
character5	
	movlw   0x35
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character6
	btfsc   mode_counter, 0
	bra	right
	btfsc   mode_counter, 1
	bra     right_date
	bra	other
right	
	movff set_position, output1
	movlw 0x03
	subwf output1
	bz other
position_1	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz position_2
	
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz position_3
	
	incf set_position
	call Line_set_2
	call spaces1
	call spaces1
	call spaces1
	call chevron
	call chevron
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	bra other
	
position_2	
	incf set_position
	call Line_set_2
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call chevron
	call chevron
	bra other
	
position_3	
	incf set_position
	call Line_set_2
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call chevron
	call chevron
	call chevron
	bra other
	
right_date
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz other
	
position1_date
	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz position2_date
	
	incf set_position
	call Line_set_1
	call spaces1
	call spaces1
	call spaces1
	call chevron_v
	call chevron_v
	call chevron_v
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	bra other
	
position2_date
	
	incf set_position
	call Line_set_1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call chevron_v
	call chevron_v
	call chevron_v
	call chevron_v
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	bra other

character7	
	movlw   0x37
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	bra     release
	
character8	
	btfsc   mode_counter, 0
	bra	down
	btfsc   mode_counter, 1
	bra	down_date
	bra	other
down
	movff set_position, output1
	movlw 0x00
	subwf output1
	bz hour_down
	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz minute_down
	
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz second_down
	
	movff set_position, output1
	movlw 0x03
	subwf output1
	bz week_down
	
hour_down
	movff time_hour, output1
	movlw 0x00
	subwf output1
	bz no_decrease
	decf time_hour
	call write_time
	goto release
minute_down
	movff time_min, output1
	movlw 0x00
	subwf output1
	bz no_decrease
	decf time_min
	call write_time
	goto release
second_down
	movff time_sec, output1
	movlw 0x00
	subwf output1
	bz no_decrease
	decf time_sec
	call write_time
	goto release
week_down
	movff time_week, output1
	movlw 0x01
	subwf output1
	bz no_decrease
	decf time_week
	call write_time
	goto release
	
down_date
	movff set_position, output1
	movlw 0x00
	subwf output1
	bz day_down
	
	movff set_position, output1
	movlw 0x01
	subwf output1
	bz month_down
	
	movff set_position, output1
	movlw 0x02
	subwf output1
	bz year_down
	
day_down
	movff time_day, output1
	movlw 0x01
	subwf output1
	bz no_decrease
	decf time_day
	call write_date
	goto release
	
month_down
	movff time_month, output1
	movlw 0x01
	subwf output1
	bz no_decrease
	decf time_month
	decf time_month
	call inc_month
	incf time_month
	movf time_day, WREG
	cpfsgt month_days
	bra fine
	movff month_days, time_day
fine	
	call write_date
	goto release
	
year_down
	movff time_year, output1
	movlw 0x00
	subwf output1
	bz no_decrease
	decf time_year
	call write_date
	goto release
	
no_decrease
	goto release
	
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
	btfsc	mode_counter, 0
	bra     release
	btfss   mode_counter, 1
	bra	set_date
	bra	start_date
set_date
	bsf	mode_counter, 1
	call	Line_set_1
	call    chevron_v
	call	chevron_v
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	movlw	0x00
	movwf   set_position
	bra	release
start_date
	bcf     mode_counter, 1
	bra     release
	
characterF
	btfsc	mode_counter, 1
	bra	release
	btfss   mode_counter, 0
	bra	set_time
	bra	start_time
set_time
	bsf	mode_counter, 0
	call	Line_set_2
	call    chevron
	call	chevron
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	movlw	0x00
	movwf   set_position
	bra	release
start_time
	bcf     mode_counter, 0
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
    
chevron
    movlw   0x5e
    movwf   output1
    movlw   1	; output message to LCD
    lfsr    FSR2, output1
    call    LCD_Write_Message
    return
    
chevron_v
    movlw   0x76
    movwf   output1
    movlw   1	; output message to LCD
    lfsr    FSR2, output1
    call    LCD_Write_Message
    return
    
spaces1
	movlw   0x20
	movwf   output1
	movlw	1	; output message to LCD
	lfsr	FSR2, output1
	call	LCD_Write_Message
	return
    end


