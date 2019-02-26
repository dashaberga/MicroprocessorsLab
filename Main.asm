	#include p18f87k22.inc

	global  mode_counter, write_date, write_time, write_alarm
	
	extern  LCD_Setup, LCD_Write_Message, LCD_clear, Line_set_2, Line_set_1,LCD_Write_Hex, Line_set_code ; external LCD subroutines
	extern  Press_test, Keypad_Setup	; external Keypad subroutines
	extern  Multiply_Setup, multiply, random, random2, multiply_random		    ; external Math routines
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
	clrf    mode_counter	; clear mode counter
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
	
	call    LCD_clear	; clear LCD
	call    Line_set_2	; set cursor to second line
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	call    Line_set_1	; set cursor to line 1
	
       	call    DAC_Setup	; call setup for clock timers & interrupts
magic_code			; main loop for displaying time & date
	btfsc	mode_counter, 0	; check if in time set mode
	bra	time_set	; branch to time/date/alarm set loop
	btfsc	mode_counter, 1	; check if in date set mode
	bra	time_set	; branch to time/date/alarm set loop
	btfsc	mode_counter, 2	; check if in alarm set mode
	bra	time_set	; branch to time/date/alarm set loop
	btfsc	mode_counter, 5	; check if in snooze countdown mode
	bra	snooze_countdown; branch to snooze countdown loop
	btfsc	mode_counter, 6	; check if in snooze alarm mode
	bra	Final_alarm	; branch to snooze alarm loop
write_time	; subroutine for writing time. Runs in main loop, may be called
	call	Line_set_1	; set cursor to line 1
	movff	time_hour, WREG	; move current hour to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write hour to LCD
	call	colon		; write a colon to LCD
	movff	time_min, WREG	; move current minute to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write minute to LCD
	call	colon		; write a colon to LCD
	movff	time_sec, WREG	; move current second to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write second to LCD
	call	spaces		; write a space to LCD
	call	spaces
	call	weekday		; call weekday subroutine
	
	btfsc	mode_counter, 0	; If called as subroutine from time_set, return
	return
write_date	; subroutine for writing date. Runs in main loop, may be called
	call	Line_set_2	; set cursor to line 2
	movff	time_day, WREG	; move current day to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write date to LCD
	call	spaces		; write a space to LCD
	call	month		; call month subroutine
	call	spaces		; write a space to LCD
	call	twenty		; write "20" to LCD
	movff	time_year, WREG	; move current year to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write year to LCD
	call	spaces		; write a space to LCD
	call	spaces
	
	btfsc	mode_counter, 1	; If called as subroutine from date_set, return
	return
	
	call	Press_test	; call keypad button press test subroutine
	bra	magic_code	; return to beginning of loop

time_set    ; loop for checking clock mode for setting time/date/alarm
	btfsc	mode_counter, 0	; branch to menu loop if in time set mode
	bra	menu_loop
	btfsc	mode_counter, 1	; branch to menu loop if in date set mode
	bra	menu_loop
	btfsc	mode_counter, 2 ; branch to menu loop if in alarm set mode
	bra	menu_loop
	bra	magic_code	; branch to main loop if not in above modes
	
menu_loop   ; loop for checking for button presses while time_set is active	
	call	Press_test	; call keypad button press test subroutine
	bra	time_set	; branch to mode check loop
	
write_alarm ; subroutine for displaying current alarm time
	call	Line_set_1	; set cursor to line 1
	movff	alarm_hour, WREG; move alarm hour to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write hour to LCD
	call	colon		; write a colon to LCD
	movff	alarm_min, WREG	; move alarm minute to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write minute to LCD
	call	colon		; write a colon to LCD
	movff	alarm_sec, WREG	; move alarm second to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write second to LCD
	call	spaces		; clear remaining line by writing spaces
	call	spaces
	call	spaces
	call	spaces
	call	spaces
	return
	
snooze_countdown    ; loop for displaying snooze timer countdown
	call	Line_set_1	; set cursor to line 1
	call	spaces		; display blank spaces on LCD
	call	spaces
	call	spaces
	movff alarm_min_cnt, WREG; snooze counter min to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write minute to LCD
	call	colon		; write a colon to LCD
	movff alarm_sec_cnt, WREG; snooze counter sec to working register (hex)
	call	multiply	; convert hex to decimal
	call	LCD_Write_Hex	; write hour to LCD
	call	spaces		; clear remaining line by writing spaces
	call	spaces
	call	spaces
	call	spaces
	call	spaces
	
	call	Line_set_code	; set cursor to current place in unlock code
	
	call	Press_test	; call keypad button press test subroutine
	
	movlw	0x00
	cpfseq	alarm_sec_cnt	; check if counter seconds = zero
	bra	snooze_cont
	cpfseq	alarm_min_cnt   ; check if counter minutes = zero
	bra	snooze_cont
	bcf	mode_counter,5	; stop countdown & activate snooze alarm
	bsf	mode_counter,6
	
snooze_cont ; loop to check if snooze countdown should still be active
	btfss	mode_counter,5	; check if snooze countdown mode is on
	bra	magic_code	; branch to main loop if no
	bra	snooze_countdown; branch to snooze countdown loop if yes
	
Final_alarm ; loop to check if snooze alarm should still be active
	btfss	mode_counter,6	; check if snooze alarm mode is on
	bra	magic_code	; branch to main loop if no
	call	Press_test	; call keypad button press test subroutine
	bra	Final_alarm	; branch to snooze alarm loop if yes
	
	goto	$		; goto current line in code
	
	
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
	
colon	;subroutine for writing a colon
	movlw   0x3A		; ascii for colon
	movwf   character	; move ascii code into "character"
	movlw	1		; output message to LCD
	lfsr	FSR2, character	; set FSR2 to location of character
	call	LCD_Write_Message; call LCD write ascii character subroutine
	return
	
spaces	;subroutine for writing a space
	movlw   0x20		; ascii for space
	movwf   character
	movlw	1	    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	return
	
twenty	;subroutine for writing "20"
	movlw   0x32		; ascii for 2
	movwf   character
	movlw	1		; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	movlw   0x30		; ascii for 0
	movwf   character
	movlw	1		; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	return
	
weekday	; collection of if statements pointing to weekday writing routines
	movff time_week, character  ; move weekday (hex number 1-7) to character
	movlw	0x01
	subwf	character	    ; if 1, branch to monday
	bz	monday
	
	movff time_week, character
	movlw	0x02
	subwf	character	    ; if 2, branch to tuesday
	bz	tuesday
	
	movff time_week, character
	movlw	0x03
	subwf	character	    ; if 3, branch to wednesday
	bz	wednesday
	
	movff time_week, character
	movlw	0x04
	subwf	character	    ; if 4, branch to thursday
	bz	thursday
	
	movff time_week, character
	movlw	0x05
	subwf	character	    ; if 5, branch to friday
	bz	friday
	
	movff time_week, character
	movlw	0x06
	subwf	character	    ; if 6, branch to saturday
	bz	saturday
	
	goto	sunday		    ; otherwise, branch to sunday

monday	; collection of code to write "MON" to LCD
	movlw   0x4d		    ; ascii for M
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4f		    ; ascii for O
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e		    ; ascii for N
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
tuesday	; collection of code to write "TUE" to LCD
	movlw   0x54		    ; ascii for T
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55		    ; ascii for U
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45		    ; ascii for E
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
wednesday; collection of code to write "WED" to LCD
	movlw   0x57		    ; ascii for W
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45		    ; ascii for E
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x44		    ; ascii for D
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
thursday; collection of code to write "THU" to LCD
	movlw   0x54		    ; ascii for T
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x48		    ; ascii for H
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55		    ; ascii for U
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
friday	; collection of code to write "FRI" to LCD
	movlw   0x46		    ; ascii for F
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x52		    ; ascii for R
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x49		    ; ascii for I
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
saturday; collection of code to write "SAT" to LCD
	movlw   0x53		    ; ascii for S
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41		    ; ascii for A
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x54		    ; ascii for T
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
sunday	; collection of code to write "SUN" to LCD
	movlw   0x53		    ; ascii for S
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55		    ; ascii for U
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e		    ; ascii for N
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
month	; collection of if statements pointing to month writing routines
	movff time_month, character ; move month (hex number 1-12) to character
	movlw	0x01
	subwf	character	    ; if 1, branch to january
	bz	january1
	
	movff time_month, character
	movlw	0x02
	subwf	character	    ; if 2, branch to february
	bz	february1
	
	movff time_month, character
	movlw	0x03
	subwf	character	    ; if 3, branch to march
	bz	march1
	
	movff time_month, character
	movlw	0x04
	subwf	character	    ; if 4, branch to april
	bz	april1
	
	movff time_month, character
	movlw	0x05
	subwf	character	    ; if 5, branch to may
	bz	may1
	
	movff time_month, character
	movlw	0x06
	subwf	character	    ; if 6, branch to june
	bz	june1
	
	movff time_month, character
	movlw	0x07
	subwf	character	    ; if 7, branch to july
	bz	july1
	
	movff time_month, character
	movlw	0x08
	subwf	character	    ; if 8, branch to august
	bz	august1
	
	movff time_month, character
	movlw	0x09
	subwf	character	    ; if 9, branch to september
	bz	september1
	
	movff time_month, character
	movlw	0x0A
	subwf	character	    ; if 10, branch to october
	bz	october1
	
	movff time_month, character
	movlw	0x0B
	subwf	character	    ; if 11, branch to november
	bz	november1
	
	movff time_month, character
	movlw	0x0C
	subwf	character	    ; if 12, branch to december
	bz	december1
; collection of goto instructions to overcome the relative branch limit of bz
january1
	goto	january
february1
	goto	february
march1
	goto	march
april1
	goto	april
may1
	goto	may
june1
	goto	june
july1
	goto	july
august1
	goto	august
september1
	goto	september
october1
	goto	october
november1
	goto	november
december1
	goto	december

january	; collection of code to write "JAN" to LCD
	movlw   0x4a		    ; ascii for J
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41		    ; ascii for A
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e		    ; ascii for N
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
february; collection of code to write "FEB" to LCD
	movlw   0x46		    ; ascii for F
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45		    ; ascii for E
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x42		    ; ascii for B
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
march	; collection of code to write "MAR" to LCD
	movlw   0x4d		    ; ascii for M
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41		    ; ascii for A
	movwf   character
	movlw	1		; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x52		    ; ascii for R
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
april	; collection of code to write "APR" to LCD
	movlw   0x41		    ; ascii for A
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x50		    ; ascii for P
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x52		    ; ascii for R
	movwf   character
	movlw	1		; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
may	; collection of code to write "MAY" to LCD
	movlw   0x4d		    ; ascii for M
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x41		    ; ascii for A
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x59		    ; ascii for Y
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
june	; collection of code to write "JUN" to LCD
	movlw   0x4a		    ; ascii for J
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55		    ; ascii for U
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4e		    ; ascii for N
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
july	; collection of code to write "JUL" to LCD
	movlw   0x4a		    ; ascii for J
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55		    ; ascii for U
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4c		    ; ascii for L
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
august	; collection of code to write "AUG" to LCD
	movlw   0x41		    ; ascii for A
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x55		    ; ascii for U
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x47		    ; ascii for G
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
september; collection of code to write "SEP" to LCD
	movlw   0x53		    ; ascii for S
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45		    ; ascii for E
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x50		    ; ascii for P
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
october	; collection of code to write "OCT" to LCD
	movlw   0x4f		    ; ascii for O
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x43		    ; ascii for C
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x54		    ; ascii for T
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	
november; collection of code to write "NOV" to LCD
	movlw   0x4e		    ; ascii for N
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x4f		    ; ascii for O
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x56		    ; ascii for V
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return

december; collection of code to write "DEC" to LCD
	movlw   0x44		    ; ascii for D
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x45		    ; ascii for E
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	movlw   0x43		    ; ascii for C
	movwf   character
	movlw	1		    ; output message to LCD
	lfsr	FSR2, character
	call	LCD_Write_Message
	
	return
	

	end