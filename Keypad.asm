#include p18f87k22.inc
   
    
    global Press_test, Keypad_Setup, position
    extern LCD_Write_Message, Line_set_2, Line_set_1, Toggle_Bell, Line_set_code
    extern mode_counter, write_date, write_time, write_alarm
    extern time_sec, time_min, time_hour, time_day, time_week, time_month, time_year, month_days, inc_month, alarm_sec, alarm_min, alarm_hour, alarm_min_cnt, alarm_sec_cnt
    extern passcode_test, passcode_test1, passcode_test2
 
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
code_in_1 res 1
code_in_2 res 1
code_in_3 res 1
code_in_4 res 1
code_temp_1 res 1
code_temp_2 res 1
code_temp_3 res 1
code_temp_4 res 1
 
Keypad code
    
Keypad_Setup			;initialise position register at 0x00
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
    movlw   .2
    call    delay_ms
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
    
delay_x4us		    	; delay given in chunks of 4 microsecond in W
	movwf	cnt_l   	; now need to multiply by 16
	swapf   cnt_l,F 	; swap nibbles
	movlw	0x0f	    
	andwf	cnt_l,W 	; move low nibble to W
	movwf	cnt_h  		; then to cnt_h
	movlw	0xf0	    
	andwf	cnt_l,F 	; keep high nibble in LCD_cnt_l
	call	delay
	return

delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lp1	decf 	cnt_l,F	; no carry when 0x00 -> 0xff
	subwfb 	cnt_h,F	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return	    
    
translate        ;multiple if statements for every valid command, to translate keypad inputs into characters
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

character10			; a list of pointers to solve 'branch out of range' error
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
	
reset_position			;routine to set position of the cursor 
	clrf	position
	call	Line_set_code
	call	spaces1
	call	spaces1
	call	spaces1
	call	spaces1
	call	Line_set_code
	return
	
character1			;routine to print the ascii character '1' onto the screen
	btfsc	mode_counter, 5
	bra	code_1
	btfsc	mode_counter, 6
	bra	code_1
	goto	release
code_1
	movlw   0x04
	cpfseq  position
	goto    print1
	call	reset_position
print1
	movlw   0x31
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x01
	movwf	output1
	call	code_in
	incf    position
	goto	release
	

	
character2			;character 2 can print character '2' or acta as an upwards arrow to increment time/date, depending on the value of mode_counter
	btfsc	mode_counter, 5 ; if in snooze countdown mode, branch to print '2'
	bra	code_2
	btfsc	mode_counter, 6 ; if in snooze alarm mode, branch to print '2'
	bra	code_2
	btfsc   mode_counter, 0 ; if in time set mode, branch to increment time
	bra	up
	btfsc   mode_counter, 1 ; if in date set mode, branch to incriment date
	bra     up_date
	btfsc	mode_counter, 2 ; if in alarm set mode, branch to incriment alarm time 
	bra	up_alarm
	goto	other1		; otherwise branch to release 
	
	
	
up      ;branch here when in time set mode
	movff set_position, output1 ; if cursor at position 0, branch to increment hour register
	movlw 0x00
	subwf output1
	bz hour_up
	
	movff set_position, output1 ; if cursor at position 1, branch to increment minute register
	movlw 0x01
	subwf output1
	bz minute_up
	
	movff set_position, output1 ; if cursor at position 2, branch to increment seconds register
	movlw 0x02
	subwf output1
	bz second_up
	
	movff set_position, output1 ; if cursor at position 3, branch to increment weekday register
	movlw 0x03
	subwf output1
	bz week_up
	
hour_up
	movff time_hour, output1  ; routine to increment hour register from 0 up to 23 
	movlw 0x17
	subwf output1
	bz no_increase
	incf time_hour
	call write_time
	goto release
minute_up			; routine to increment minute register from 0 up to 59 
	movff time_min, output1
	movlw 0x3b
	subwf output1
	bz no_increase
	incf time_min
	call write_time
	goto release
second_up			; routine to increment seconds register from 0 up to 59 
	movff time_sec, output1
	movlw 0x3b
	subwf output1
	bz no_increase
	incf time_sec
	call write_time
	goto release
week_up				; routine to increment weekday register from Monday up to Sunday
	movff time_week, output1
	movlw 0x07
	subwf output1
	bz no_increase
	incf time_week
	call write_time
	goto release
	
	
	
up_date				; branch here when in date set mode
	movff set_position, output1 ; if cursor at position 0, branch to increment day register by 1 
	movlw 0x00
	subwf output1
	bz day_up
	
	movff set_position, output1 ; if cursor at position 1, branch to increment month register by 1 
	movlw 0x01
	subwf output1
	bz month_up
	
	movff set_position, output1 ; if cursor at position 2, branch to increment year register by 1 
	movlw 0x02
	subwf output1
	bz year_up
	
day_up					; routine to increment day register by 1 within a month from 1 to 28/29/30/31 depending on a month
	movff time_day, output1 
	movff  month_days, WREG
	subwf output1
	bz no_increase
	incf time_day
	call write_date
	goto release
month_up				;routine to increment month register by 1 from January to December
	movff time_month, output1
	movlw 0x0c
	subwf output1
	bz no_increase
	call inc_month
	incf time_month
	movff month_days, WREG
	cpfsgt time_day
	goto fine
	movff month_days, time_day
	call write_date
	goto release
year_up					; routine to increment year register by 1 from 2000 
	movff time_year, output1
	incf time_year
	movlw 0x02
	cpfseq time_month
	bra year_finish
	movlw 0x1d
	cpfseq time_day
	bra feb_test
	decf time_day
	
feb_test				; routine to test wether a year is a leap year
	btfsc time_year, 0
	bra feb_no_leap
	btfsc time_year, 1
	bra feb_no_leap	
feb_leap				; if leap year, february allowed to be incremented up to 29
	movlw 0x1d
	movwf month_days
	bra year_finish
feb_no_leap				; if not a leap year, february allowed to be incremented up to 28
	movlw 0x1c
	movwf month_days
	bra year_finish
	
	
year_finish				
	call write_date
	goto release
	
no_increase
	goto release

up_alarm				;branch here if in alarm set mode 
	movff set_position, output1 	;if cursor at position 0, branch to increment alarm hour register
	movlw 0x00
	subwf output1
	bz hour_up_a
	
	movff set_position, output1	;if cursor at position 1, branch to increment alarm minutes register
	movlw 0x01
	subwf output1
	bz minute_up_a
	
	bra second_up_a			;otherwise branch to increment alarm seconds register
	
hour_up_a				; routine to increment alarm hour register between 0 and 23
	movff alarm_hour, output1
	movlw 0x17
	subwf output1
	bz no_increase
	incf alarm_hour
	call write_alarm
	goto release
minute_up_a				; routine to increment alarm minutes register between 0 and 59
	movff alarm_min, output1
	movlw 0x3b
	subwf output1
	bz no_increase
	incf alarm_min
	call write_alarm
	goto release
second_up_a				; routine to incriment alarm seconds register between 0 and 59 
	movff alarm_sec, output1
	movlw 0x3b
	subwf output1
	bz no_increase
	incf alarm_sec
	call write_alarm
	goto release
other1
	bra release
	
code_2					; branch here if in either of snooze modes
	movlw   0x04
	cpfseq  position
	goto    print2
	call	reset_position
print2					; display character 2 and input it into the code register
	movlw   0x32
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x02
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
character3	
	btfsc	mode_counter, 5 	; if in mode 5 or 6, branch to code_3, otherwise release 
	bra	code_3
	btfsc	mode_counter, 6
	bra	code_3
	goto	release
code_3					;set cursor to position 4, branch to print 3
	movlw   0x04
	cpfseq  position
	goto    print3
	call	reset_position
print3					; output character '3' onto screen and input the value into the code register
	movlw   0x33
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x03
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
character4				;acts as a left arrow or character '4' depending on mode 
	btfsc	mode_counter, 5
	bra	code_4
	btfsc	mode_counter, 6		; if in mode 5 or 6, branch to code_4 (same as code_3)
	bra	code_4
	btfsc   mode_counter, 0		; if in time set mode, branch to set cursor on time
	bra	left
	btfsc   mode_counter, 1		; if in date set mode, branch to set cursor on date
	bra     left_date
	btfsc	mode_counter, 2		; if in alarm set mode, branch to set cursor on alarm time
	bra	left
	bra	other1			; otherwise release 
	
	
left					; branch here if in time or alarm set mode

	movff set_position, 		; if cursor in position 0, release
	movlw 0x00
	subwf output1
	bz other1
	
	movff set_position, output1	;if cursor in position 1, branch to position_n1
	movlw 0x01
	subwf output1
	bz position_n1
	
	movff set_position, output1	;if cursor in position 2, branch position_n2
	movlw 0x02
	subwf output1
	bz position_n2
	
	movff set_position, output1	;if cursor in position 3, branch to position_n3
	movlw 0x03
	subwf output1
	bz position_n3
	
position_n1				;moves the cursor to the left, by decrimenting position register by 1 
					;and input chevrons under the cursor to help user see which variable they are changing
	decf set_position
	call Line_set_2
	call chevron
	call chevron
	call spaces1
	call spaces1
	call spaces1
	bra other1
	
position_n2				;moves the cursor to the left, by decrimenting position register by 1 
					;and input chevrons under the cursor to help user see which variable they are changing
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
	
position_n3				;moves the cursor to the left, by decrimenting position register by 1 
					;and input chevrons under the cursor to help user see which variable they are changing
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
	
left_date				;branch here if in date set mode

	movff set_position, output1	;if cursor in position 0, branch to release
	movlw 0x00
	subwf output1
	bz other
	
	movff set_position, output1 	;if cursor in position 1, branch to position_n1_date
	movlw 0x01
	subwf output1
	bz position_n1_date
	
	movff set_position, output1	;if cursor in position 2, branch to position_n2_date
	movlw 0x02
	subwf output1
	bz position_n2_date
	
position_n1_date			;moves the cursor to the left, by decrimenting position register by 1 
					;and input chevrons above the cursor to help user see which variable they are changing
	
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
					;moves the cursor to the left, by decrimenting position register by 1 
					;and input chevrons under the cursor to help user see which variable they are changing
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
	
code_4					;branch here if in modes 5 or 6
	movlw   0x04
	cpfseq  position
	goto    print4
	call	reset_position
print4					;print charachter 4 and input 4 into code register
	movlw   0x34
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x04
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
character5				; only in use with modes 5 and 6, otherwise release
	btfsc	mode_counter, 5
	bra	code_5
	btfsc	mode_counter, 6
	bra	code_5
	goto	release
code_5				
	movlw   0x04
	cpfseq  position
	goto    print5
	call	reset_position
print5					; print 5 and input 5 into code register
	movlw   0x35
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x05
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
character6				;acts as a right arrow to move cursor or character 6 in snooze modes 5 and 6 
	btfsc	mode_counter, 5		;if in mode 5 or 6, branch to code_6
	bra	code_6
	btfsc	mode_counter, 6
	bra	code_6
	btfsc   mode_counter, 0		;if in time set mode, branch to right arrow
	bra	right
	btfsc   mode_counter, 1		;if in date set mode, branch to right date arrow
	bra     right_date
	btfsc	mode_counter, 2    	;if in alarm set mode, branch to right arrow
	bra	right
	bra	other			;otherwise release 
	
right	
	movff set_position, output1	;if at position 3, release, otherwise follow through to position 1
	movlw 0x03
	subwf output1
	bz other
position_1	
	movff set_position, output1 	; if at position1, branch to poistion 2
	movlw 0x01
	subwf output1
	bz position_2
	
	movff set_position, output1	;if at position 2, branch to position 3 
	movlw 0x02
	subwf output1
	bz position_3
	
	incf set_position		; move right by incrementing position and set chevrons to point to variable being set
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
	
position_2				;move right by incrementing position and set chevrons to point to variable being set
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
	
position_3				; move right by incrementing position and set chevrons to point to variable being set
	btfsc mode_counter, 2		; if in alarm set mode, release
	goto release
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
	
right_date				; branch here if in date set mode 
	movff set_position, output1	; if in position 2, release 
	movlw 0x02
	subwf output1
	bz other2
	
position1_date
	
	movff set_position, output1	; if in position 1, branch to position 2 routine
	movlw 0x01
	subwf output1
	bz position2_date
	
	incf set_position		; increment position and set chevrons to point to variable being set
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
	bra other2
	
position2_date				; increment position and set chevrons to point to variable being set
	
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
	bra other2

code_6				;branch here if in modes 5,6 
	movlw   0x04
	cpfseq  position
	goto    print6
	call	reset_position
print6				;print 6 and input 6 into code register
	movlw   0x36
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x06
	movwf	output1
	call	code_in
	incf    position
	goto	release

character7			; only in use if in mode 5 or 6 
	btfsc	mode_counter, 5
	bra	code_7
	btfsc	mode_counter, 6
	bra	code_7
	goto	release
code_7
	movlw   0x04
	cpfseq  position
	goto    print7
	call	reset_position
print7				; print 7 and input 7 into code register
	movlw   0x37	
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x07
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
other2	
	goto	release
	
character8				; acts as a down arrow and character 8 depending on a mode
	btfsc	mode_counter, 5
	bra	code_8
	btfsc	mode_counter, 6
	bra	code_8
	btfsc   mode_counter, 0
	bra	down
	btfsc   mode_counter, 1
	bra	down_date
	btfsc   mode_counter, 2
	bra	down_alarm
	bra	other2
	
down						;branch here if in time set mode
	movff set_position, output1		;if in position 0, branch to decrement hour
	movlw 0x00
	subwf output1
	bz hour_down
	
	movff set_position, output1		;if in position 1, branch to decrement minute
	movlw 0x01
	subwf output1
	bz minute_down
	
	movff set_position, output1		; if in position 2, branch to decriment seconds
	movlw 0x02
	subwf output1
	bz second_down
	
	movff set_position, output1		; if in position 3, branch to decrement weekday 
	movlw 0x03
	subwf output1
	bz week_down
	
no_decrease1				;another release routine
	goto no_decrease
	
hour_down				;routine to decriment hour register by 1 from 23 to 0
	movff time_hour, output1
	movlw 0x00
	subwf output1
	bz no_decrease1
	decf time_hour
	call write_time
	goto release
minute_down				;routine to decriment minutes register by 1 from 59 to 0 
	movff time_min, output1
	movlw 0x00
	subwf output1
	bz no_decrease1
	decf time_min
	call write_time
	goto release
second_down				;routine to decriment seconds register by 1 from 59 to 0 
	movff time_sec, output1
	movlw 0x00
	subwf output1
	bz no_decrease1
	decf time_sec
	call write_time
	goto release
week_down				;routine to decriment weekdays register by 1 from Sunday to Monday  
	movff time_week, output1
	movlw 0x01
	subwf output1
	bz no_decrease1
	decf time_week
	call write_time
	goto release
	
down_date				; branch here if in date set mode
	movff set_position, output1	;if in position 0, branch to decrement day
	movlw 0x00
	subwf output1
	bz day_down
	
	movff set_position, output1	;if in position 1, branch to decrement month 
	movlw 0x01
	subwf output1
	bz month_down
	
	movff set_position, output1    ; if in poistion 2, branch to decrement year
	movlw 0x02
	subwf output1
	bz year_down
	
day_down				; decrement day of month by 1 from 31-28 to 0 depending on a month
	movff time_day, output1
	movlw 0x01
	subwf output1
	bz no_decrease1
	decf time_day
	call write_date
	goto release
	
month_down				; decrement month by 1 from Decemeber to January 
	movff time_month, output1
	movlw 0x01
	subwf output1
	bz no_decrease1
	decf time_month
	decf time_month
	call inc_month
	incf time_month
	movff month_days, WREG
	cpfsgt time_day
	bra fine
	movff month_days, time_day
fine	
	call write_date
	goto release
	
year_down				; decrement year by 1 down to 2000
	movff time_year, output1
	movlw 0x00
	subwf output1
	bz no_decrease1
	decf time_year
	movlw 0x02
	cpfseq time_month
	goto year_finish
	movlw 0x1d
	cpfseq time_day
	goto feb_test
	decf time_day
	goto feb_test
	
down_alarm				;branch here if in alarm set mode
	movff set_position, output1	; if in position 0, branch to decrement alarm hour
	movlw 0x00
	subwf output1
	bz hour_down_a
	
	movff set_position, output1	;if in position 1, branch to decrement alarm minutes
	movlw 0x01
	subwf output1
	bz minute_down_a
	
	bra second_down_a		;otherwise branc hto decrement alarm seconds

	
hour_down_a				;decrement alarm hour register by 1 from 23 to 0 
	movff alarm_hour, output1
	movlw 0x00
	subwf output1
	bz no_decrease
	decf alarm_hour
	call write_alarm
	goto release
minute_down_a				;routine to decriment minutes register by 1 from 59 to 0
	movff alarm_min, output1
	movlw 0x00
	subwf output1
	bz no_decrease
	decf alarm_min
	call write_alarm
	goto release
second_down_a				;routine to decriment seconds register by 1 from 59 to 0
	movff alarm_sec, output1
	movlw 0x00
	subwf output1
	bz no_decrease
	decf alarm_sec
	call write_alarm
	goto release
	
no_decrease
	goto release
	
code_8					;branch here if in modes 5 or 6
	movlw   0x04
	cpfseq  position
	goto    print8
	call	reset_position
print8					;print chrachter 8 and input 8 into code register
	movlw   0x38
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x08
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
character9				;only active when modes 5 or 6 are activated
	btfsc	mode_counter, 5
	bra	code_9
	btfsc	mode_counter, 6
	bra	code_9
	goto	release
code_9
	movlw   0x04
	cpfseq  position
	goto    print9
	call	reset_position
print9					;print 9 and input 9 into code register
	movlw   0x39
	movwf   output2
	movlw	1	; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x09
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
character0				;only active when modes 5 or 6 are activated
	btfsc	mode_counter, 5
	bra	code_0
	btfsc	mode_counter, 6
	bra	code_0
	goto	release
code_0
	movlw   0x04
	cpfseq  position
	goto    print0
	call	reset_position
print0					;print 0 and input 0 into code register
	movlw   0x30
	movwf   output2
	movlw	1			; output message to LCD
	lfsr	FSR2, output2
	call	LCD_Write_Message
	movlw	0x00
	movwf	output1
	call	code_in
	incf    position
	goto	release
	
characterA	

	btfsc   mode_counter, 4			; if mode_counter bit 4 set , branch to alarm_snooze
	bra     alarm_snooze
	btfsc   mode_counter, 5			; if mode_counter bit 5 set, branch to alarm_kill
	bra     alarm_kill
	btfsc   mode_counter, 6			; if mode_counter bit 6 set, branch to alarm_kill
	bra     alarm_kill
	bra     release				; otherwise release
	
alarm_snooze					;routine to snooze the alarm 
	bcf	LATH, 2				;set pin RH2 to 0 to snooze the alarm 
	bcf	mode_counter, 4			;clear bit 4 in mode_counter
	bsf	mode_counter, 5			;set bit 5 in mode_counter
	movlw	0x05				
	movwf	alarm_min_cnt			;set a 5 minute snooze alarm 
	clrf    alarm_sec_cnt
	clrf	position
	call    Line_set_2 			;set cursor onto line 2
	
	;next blocks are used to spell out "CODE:" and 6 spaces on the 2nd line of LCD
	
	movlw   0x43
	movwf   output1
	movlw	1	; output message to LCD
	lfsr	FSR2, output1
	call	LCD_Write_Message
	
	movlw   0x4F
	movwf   output1
	movlw	1	; output message to LCD
	lfsr	FSR2, output1
	call	LCD_Write_Message
	
	movlw   0x44
	movwf   output1
	movlw	1	; output message to LCD
	lfsr	FSR2, output1
	call	LCD_Write_Message
	
	movlw   0x45
	movwf   output1
	movlw	1	; output message to LCD
	lfsr	FSR2, output1
	call	LCD_Write_Message
	
	movlw   0x3A
	movwf   output1
	movlw	1	; output message to LCD
	lfsr	FSR2, output1
	call	LCD_Write_Message
	
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call spaces1
	call reset_position
	
	bra	release

alarm_kill				;routine which checks if passcode is entered correctly, and kills the alarm
	call	passcode_translate
	call	passcode_test
	bra	release
	
characterB	
	bra     release
	
characterC				;character C turns the alarm setting on or off
	btfss   mode_counter, 3		
	bra	alarm_on
	bra	alarm_off
alarm_on				
	bsf	mode_counter, 3		;set bit 3
	bsf	LATH, 0			;set RH0
	call	Toggle_Bell		;displays a bell symbol
	bra	alarm_finish
alarm_off
	bcf	mode_counter, 3		;clear bit 3
	bcf	LATH, 0			;clear RH0
	call	Toggle_Bell		;remove a bell symbol
	bra	alarm_finish
alarm_finish
	bra     release
	
characterD				;Alarm button
	btfsc	mode_counter, 0
	bra	alarm_finish
	btfsc	mode_counter, 1
	bra	alarm_finish
	btfsc	mode_counter, 5
	bra	alarm_finish
	btfsc	mode_counter, 6
	bra	alarm_finish
	btfsc	mode_counter, 2		;if bit 2 clear, turn on the alarm set mode
	bra	alarm_exit		;if bit 2 already set, release
	bra	alarm_set		
alarm_exit
	bcf	mode_counter, 2
	bra	alarm_finish
alarm_set				;routine to set chevrons and output alarm time
	bsf	mode_counter, 2		
	call	write_alarm		
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

characterE				;Date button 
	btfsc	mode_counter, 0
	bra     release
	btfsc	mode_counter, 2
	bra     release
	btfsc	mode_counter, 5
	bra	release
	btfsc	mode_counter, 6
	bra	release
	btfss   mode_counter, 1		;if bit 1 clear, turn on Date set mode by branching to set_date
	bra	set_date		;if bit 1 already set, release
	bra	start_date
set_date				;routine to write chevrons and output date
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
	
characterF				;Time button
	btfsc	mode_counter, 1
	bra	release
	btfsc	mode_counter, 2
	bra	release
	btfsc	mode_counter, 5
	bra	release
	btfsc	mode_counter, 6
	bra	release
	btfss   mode_counter, 0		;if bit 0 clear, turn on Time set mode by branching to set_time
	bra	set_time		;if bit 0 set, release
	bra	start_time
set_time				;routine to output chevrons and time
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
	btfsc	 mode_counter, 5
	bra	 finish2
	btfsc	 mode_counter, 6
	bra	 finish2
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
    
chevron			;routine to print chevron character
    movlw   0x5e
    movwf   output1
    movlw   1	; output message to LCD
    lfsr    FSR2, output1
    call    LCD_Write_Message
    return
    
chevron_v		;routine to print chevron_v character
    movlw   0x76
    movwf   output1
    movlw   1	; output message to LCD
    lfsr    FSR2, output1
    call    LCD_Write_Message
    return
    
spaces1			;routine to print space
	movlw   0x20
	movwf   output1
	movlw	1	; output message to LCD
	lfsr	FSR2, output1
	call	LCD_Write_Message
	return
	
code_in			
	movlw	0x00
	cpfseq	position
	bra	code_ina
	bra	code_in1
code_ina
	movlw	0x01	
	cpfseq	position
	bra	code_inb
	bra	code_in2
code_inb	
	movlw	0x02
	cpfseq	position
	bra	code_inc
	bra	code_in3
code_inc	
	movlw	0x03	
	cpfseq	position
	bra	death
	bra	code_in4
death
	goto	$
	
code_in1
	clrf  code_in_1
	movff output1, code_in_1
	return
code_in2
	clrf  code_in_2
	movff output1, code_in_2
	return
code_in3
	clrf  code_in_3
	movff output1, code_in_3
	return
code_in4
	clrf  code_in_4
	movff output1, code_in_4
	return
	
passcode_translate
	clrf	passcode_test
	clrf	passcode_test2
	clrf	0x50
	clrf	0x51
	clrf	0x52
	clrf	0x53
	movff	code_in_1, 0x50
	movff	code_in_2, 0x51
	movff	code_in_3, 0x52
	movff	code_in_4, 0x53
	movff	code_in_1, code_temp_1
	movff	code_in_2, code_temp_2
	movff	code_in_3, code_temp_3
	movff	code_in_4, code_temp_4
	swapf   code_temp_1, 1, 0
	swapf   code_temp_3, 1, 0
	movff	code_temp_1, WREG
	addwf	code_temp_2
	movff	code_temp_3, WREG
	addwf	code_temp_4
	movff	code_temp_2, passcode_test2
	movff	code_temp_4, passcode_test
	movff	code_temp_2, 0x54
	movff	code_temp_4, 0x55
	
	return
    end
