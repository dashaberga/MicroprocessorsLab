	#include p18f87k22.inc

	global  mode_counter, write_date, write_time, write_alarm
	
	extern  LCD_Setup, LCD_Write_Message, LCD_clear, Line_set_2, Line_set_1,LCD_Write_Hex, Line_set_code ; external LCD subroutines
	extern  Press_test, Keypad_Setup
	extern  Multiply_Setup, multiply, random, random2, multiply_random		    ; external ADC routines
	extern  DAC_Setup, time_sec, time_min, time_hour, time_day, time_week, time_month, time_year, alarm_sec, alarm_min, alarm_hour, alarm_min_cnt, alarm_sec_cnt
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
delay_cnt_2 res 1   ; reserve one byte for counter in the delay routine
mode_counter res 1  ; reserve one byte for testing whether to run clock, set alarm etc
character res 1
 
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Loading\n"	; message, plus carriage return
	constant    myTable_l=.8	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	call    Keypad_Setup	; setup Keypad
	call	Multiply_Setup	; setup ADC
	movlw   0x00
	movwf   mode_counter
	goto	start
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	
	call    LCD_clear
	call    Line_set_2
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	call    Line_set_1
	
       	call    DAC_Setup
magic_code
	btfsc mode_counter, 0
	bra time_set
	btfsc mode_counter, 1
	bra time_set
	btfsc mode_counter, 2
	bra time_set
	btfsc mode_counter, 5
	bra snooze_countdown
	btfsc mode_counter, 6
	bra Final_alarm
write_time	
	call Line_set_1
	movff time_hour, WREG
	call multiply
	call LCD_Write_Hex
	call colon
	movff time_min, WREG
	call multiply
	call LCD_Write_Hex
	call colon
	movff time_sec, WREG
	call multiply
	call LCD_Write_Hex
	call spaces
	call spaces
	call weekday
	
	btfsc mode_counter, 0
	return
write_date	
	call Line_set_2
	movff time_day, WREG
	call multiply
	call LCD_Write_Hex
	call spaces
	call month
	call spaces
	call twenty
	movff time_year, WREG
	call multiply
	call LCD_Write_Hex
	call spaces
	call spaces
	
	
	btfsc mode_counter, 1
	return
	
	call Press_test
	bra magic_code

time_set
	btfsc mode_counter, 0
	bra   menu_loop
	btfsc mode_counter, 1
	bra   menu_loop
	btfsc mode_counter, 2
	bra   menu_loop
	bra   magic_code
	
menu_loop	
	call Press_test
	bra  time_set
	
write_alarm	
	call Line_set_1
	movff alarm_hour, WREG
	call multiply
	call LCD_Write_Hex
	call colon
	movff alarm_min, WREG
	call multiply
	call LCD_Write_Hex
	call colon
	movff alarm_sec, WREG
	call multiply
	call LCD_Write_Hex
	call spaces
	call spaces
	call spaces
	call spaces
	call spaces
	return
	
snooze_countdown
	call Line_set_1
	call spaces
	call spaces
	call spaces
	movff alarm_min_cnt, WREG
	call multiply
	call LCD_Write_Hex
	call colon
	movff alarm_sec_cnt, WREG
	call multiply
	call LCD_Write_Hex
	call spaces
	call spaces
	call spaces
	call spaces
	call spaces
	
	call Line_set_code
	
	call Press_test
	
	movlw 0x00
	cpfseq alarm_sec_cnt
	bra snooze_cont
	cpfseq alarm_min_cnt
	bra snooze_cont
	bcf mode_counter,5
	bsf mode_counter,6
	
snooze_cont
	btfss mode_counter,5
	bra magic_code
	bra snooze_countdown
	
Final_alarm
	btfss mode_counter,6
	bra magic_code
	call Press_test
	bra Final_alarm
	
	goto	$		; goto current line in code , time_day, time_week, time_month, time_year
	
	
	; a delay subroutine if you need one, times around loop in delay_count

delay_4us		    ; delay given in chunks of 4 microsecond in W
	movwf	delay_count   ; now need to multiply by 16
	swapf   delay_count,F ; swap nibbles
	movlw	0x0f	    
	andwf	delay_count,W ; move low nibble to W
	movwf	delay_cnt_2   ; then to cnt_h
	movlw	0xf0	    
	andwf	delay_count,F ; keep high nibble in cnt_l
	call	delay
	return

delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1	decf 	delay_count,F	; no carry when 0x00 -> 0xff
	subwfb 	delay_cnt_2,F	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return
	
colon
	movlw   0x3A
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	return
	
spaces
	movlw   0x20
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	return
	
twenty
	movlw   0x32
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	movlw   0x30
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	return
	
weekday
	movff time_week, character
	movlw 0x01
	subwf character
	bz monday
	
	movff time_week, character
	movlw 0x02
	subwf character
	bz tuesday
	
	movff time_week, character
	movlw 0x03
	subwf character
	bz wednesday
	
	movff time_week, character
	movlw 0x04
	subwf character
	bz thursday
	
	movff time_week, character
	movlw 0x05
	subwf character
	bz friday
	
	movff time_week, character
	movlw 0x06
	subwf character
	bz saturday
	
	goto sunday
	
set_week	
	return

monday
	movlw   0x4d
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4f
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	bra set_week
	
tuesday
	movlw   0x54
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	bra set_week
	
wednesday
	movlw   0x57
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x44
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	bra set_week
	
thursday
	movlw   0x54
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x48
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	bra set_week
	
friday
	movlw   0x46
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x52
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x49
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	bra set_week
	
saturday
	movlw   0x53
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x54
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	bra set_week
	
sunday
	movlw   0x53
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	bra set_week
	
month
	movff time_month, character
	movlw 0x01
	subwf character
	bz january1
	
	movff time_month, character
	movlw 0x02
	subwf character
	bz february1
	
	movff time_month, character
	movlw 0x03
	subwf character
	bz march1
	
	movff time_month, character
	movlw 0x04
	subwf character
	bz april1
	
	movff time_month, character
	movlw 0x05
	subwf character
	bz may1
	
	movff time_month, character
	movlw 0x06
	subwf character
	bz june1
	
	movff time_month, character
	movlw 0x07
	subwf character
	bz july1
	
	movff time_month, character
	movlw 0x08
	subwf character
	bz august1
	
	movff time_month, character
	movlw 0x09
	subwf character
	bz september1
	
	movff time_month, character
	movlw 0x0A
	subwf character
	bz october1
	
	movff time_month, character
	movlw 0x0B
	subwf character
	bz november1
	
	movff time_month, character
	movlw 0x0C
	subwf character
	bz december1
	
set_month	
	return
	
january1
	goto january
february1
	goto february
march1
	goto march
april1
	goto april
may1
	goto may
june1
	goto june
july1
	goto july
august1
	goto august
september1
	goto september
october1
	goto october
november1
	goto november
december1
	goto december

january
	movlw   0x4a
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
february
	movlw   0x46
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x42
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
march
	movlw   0x4d
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x52
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
april
	movlw   0x41
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x50
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x52
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
may
	movlw   0x4d
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x59
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
june
	movlw   0x4a
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
july
	movlw   0x4a
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4c
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
august
	movlw   0x41
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x47
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
september
	movlw   0x53
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x50
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
october
	movlw   0x4f
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x43
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x54
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	
november
	movlw   0x4e
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4f
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x56
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month

december
	movlw   0x44
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x43
	movwf   character
	movlw	1	; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	goto set_month
	

	end
