#include p18f87k22.inc

    global DAC_Setup, time_sec, time_min, time_hour, time_day, time_week, time_month, time_year, month_days, inc_month, alarm_sec, alarm_min, alarm_hour, alarm_min_cnt, alarm_sec_cnt
    
    extern mode_counter
    extern random, random2
    extern passcode_set
    
acs0    udata_acs   ; named variables in access ram
time_millisec res 1 ; Hex numbers for storing current time (milliseconds counts +1 every 4 milliseconds)
time_sec  res 1
time_min  res 1
time_hour res 1
time_day  res 1		; day of the month
time_week res 1		; day of the week
time_month res 1
time_year res 1
time_leap res 1
alarm_sec  res 1    ; alarm time 
alarm_min  res 1
alarm_hour res 1
alarm_sec_cnt  res 1    ; counters for alarm snooze
alarm_min_cnt  res 1 
temp_storage res 1  ; temporary value storage register
month_days res 1    ; stores the number of days in the current month



int_hi code 0x0008                      ; high vector, no low vector
    btfss PIR1,TMR2IF                   ; check that this is timer0 interrupt 
    retfie FAST                         ; if not then return 
    btfsc mode_counter, 0		; check if time is being set
    bra time_stop			; return if time is being set
    movff time_millisec, temp_storage
    movlw 0xf9                          ; postscaler of 250 for timer 2
    subwf temp_storage
    bz inc_second			; increment second when postscaler overflows
    incf time_millisec			; increment postscaler
    btfsc mode_counter, 4		; play alarm tone if mode 4 is active
    call alarm_tone
    btfsc mode_counter, 6		; play alarm tone if mode 6 is active
    call alarm_tone
    bcf PIR1,TMR2IF                     ; clear interrupt flag
    retfie FAST                         ; fast return from interrupt
    
inc_second                              ;routine to increment seconds register every second
    btfss mode_counter, 2
    call  alarm_test			; if alarm is enabled, check if alarm should be activated
    btfsc mode_counter, 5
    call  snooze_dsec			; if snooze counter is active, decrement it
    clrf time_millisec			; clear timer 2 postscaler
    movff time_sec, temp_storage
    movlw 0x3b				;increment minute if seconds = 60
    subwf temp_storage
    bz inc_minute
    incf time_sec    
    bcf PIR1,TMR2IF                       ; clear interrupt flag
    retfie FAST                          ; fast return from interrupt
    
inc_minute                              ;routine to incriment minute register, every 60 seconds and branch to incriment hour after 60 minutes
    clrf time_sec
    movff time_min, temp_storage
    movlw 0x3b				;increment hour if minutess = 60
    subwf temp_storage
    bz inc_hour
    incf time_min
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
inc_hour                                ;routine to incriment hour register, every 60 minutes and branch to incriment day after 24 hours
    movlw 0x00
    movwf time_min
    movff time_hour, temp_storage
    movlw 0x17
    subwf temp_storage
    bz inc_day
    incf time_hour
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
inc_day                                 ;routine to incriment week day register, every 24 hours and branch to new_week after 7 days
    movlw 0x00
    movwf time_hour
    movff time_week, temp_storage
    movlw 0x07
    subwf temp_storage
    bz new_week
    incf time_week
    
date                                    ;routine to incriment day of month register, every 24 hours and branch to incriment month after 28-31 days depending on a month
    btfsc mode_counter, 1
    bra   time_stop
    movff time_day, temp_storage
    movf  month_days, W
    subwf temp_storage
    bz inc_month
    incf time_day
    bcf PIR1,TMR2IF                     ; clear interrupt flag
    retfie FAST                         ; fast return from interrupt

new_week                                ;routine to reset weekdays back to monday after sunday
    movlw 0x01
    movwf time_week
    bra date
    
inc_month                               ;a block of if statements to point to a number of days in each month
    movff time_month, temp_storage
    movlw    0x01
    subwf    temp_storage
    bz       february
    
    movff time_month, temp_storage
    movlw    0x02
    subwf    temp_storage
    bz       month31
    
    movff time_month, temp_storage
    movlw    0x03
    subwf    temp_storage
    bz       month30
    
    movff time_month, temp_storage
    movlw    0x04
    subwf    temp_storage
    bz       month31
    
    movff time_month, temp_storage
    movlw    0x05
    subwf    temp_storage
    bz       month30
    
    movff time_month, temp_storage
    movlw    0x06
    subwf    temp_storage
    bz       month31
    
    movff time_month, temp_storage
    movlw    0x07
    subwf    temp_storage
    bz       month31
    
    movff time_month, temp_storage
    movlw    0x08
    subwf    temp_storage
    bz       month30
    
    movff time_month, temp_storage
    movlw    0x09
    subwf    temp_storage
    bz       month31
    
    movff time_month, temp_storage
    movlw    0x0A
    subwf    temp_storage
    bz       month30
    
    bra       month31
    
inc_month2                          ;routine to reset date at the end of the year and increment year
    btfsc mode_counter, 1
    return
    movlw 0x01
    movwf time_day
    movff time_month, temp_storage
    movlw 0x0C
    subwf temp_storage
    bz inc_year
    incf time_month
    bcf PIR1,TMR2IF                  ; clear interrupt flag
    retfie FAST                     ; fast return from interrupt

month30                     ;routine for month with 30 days
    movlw 0x1e
    movwf month_days
    bra inc_month2
    
month31                     ;routine for month with 31 days
    movlw 0x1f
    movwf month_days
    bra inc_month2
    
february                    ;block of routines to figure out leap/not a leap year in order to set february days
    btfsc time_year, 1
    bra february_no_leap
    btfsc time_year, 0
    bra february_no_leap
    bra february_leap
    
february_no_leap
    movlw 0x1c		    ; set month_days to 28
    movwf month_days
    movlw 0x01
    addwf time_leap
    bra inc_month2
    
february_leap
    movlw 0x1d		    ; set month_days to 29
    movwf month_days
    movlw 0x01
    movwf time_leap
    bra inc_month2
    
inc_year                    ;routine to increment year
    movlw 0x01
    movwf time_month
    incf time_year
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
time_stop                   ;routine to stop time
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
    goto    $
    
DAC code
                            ;Setup for initial date, time and timers
DAC_Setup
    movlw b'01111111'   ; Set timer2 to 8-bit, Fosc/4
    movwf T2CON         ; = 16MHz clock rate, 62.5KHz rollover
    movlw 0xF9
    movwf PR2           ; 250x prescaler to interrupt, interrupt frequency 250Hz
    bsf PIE1,TMR2IE     ; Enable timer2 interrupt 
    bsf INTCON,GIE      ; Enable all interrupts return
    bsf INTCON,PEIE     ; Enable all interrupts return
    movlw 0x00
    movwf TRISH	    ; enable outputs on LATH and clear it
    movwf LATH
    movwf time_millisec	; set initial values for various file registers on startup
    movlw 0x1f
    movwf time_day
    movlw 0x07
    movwf time_week
    movlw 0x0c
    movwf time_month
    movlw 0x00
    movwf time_year
    movlw 0x04
    movwf time_leap
    movlw 0x37
    movwf time_sec
    movlw 0x3b
    movwf time_min
    movlw 0x17
    movwf time_hour
    movlw 0x1f
    movwf month_days
    movlw 0x00
    movwf alarm_sec
    movwf alarm_min
    movlw 0x07
    movwf alarm_hour
    movlw 0x78
    movwf random2
    movlw 0xdc
    movwf random
    call  passcode_set
    return
    
alarm_test              ;test if alarm on 
    btfss mode_counter, 3
    return    
    movff alarm_hour, WREG
    cpfseq time_hour
    return
    movff alarm_min, WREG
    cpfseq time_min
    return
    movff alarm_sec, WREG
    cpfseq time_sec
    return
    bsf  mode_counter, 4
    bsf	 LATH, 1
    return
    
                        ;set alarm to beep, instead of constant output
alarm_tone
    movlw 0x28
    cpfseq time_millisec
    bra alarm_tone2
    call alarm_tone_toggle
alarm_tone2
    movlw 0x32
    cpfseq time_millisec
    bra alarm_tone3
    call alarm_tone_toggle
alarm_tone3
    movlw 0x5A
    cpfseq time_millisec
    bra alarm_tone4
    call alarm_tone_toggle
alarm_tone4
    movlw 0x64
    cpfseq time_millisec
    bra alarm_tone5
    call alarm_tone_toggle
alarm_tone5
    movlw 0x8c
    cpfseq time_millisec
    bra alarm_tone6
    call alarm_tone_toggle
alarm_tone6
    movlw 0x96
    cpfseq time_millisec
    bra alarm_tone7
    call alarm_tone_toggle
alarm_tone7
    movlw 0xbe
    cpfseq time_millisec
    bra alarm_tone8
    call alarm_tone_toggle
alarm_tone8
    movlw 0xcb
    cpfseq time_millisec
    bra alarm_tone_end
    call alarm_tone_toggle
alarm_tone_end
    return
    
alarm_tone_toggle	;toggles alarm beep on & off
    btfss LATH, 2
    bra tone_on
    bra tone_off
    
tone_on
    bsf LATH, 2    
    return
tone_off
    bcf LATH, 2
    return
    
                                    ;decrement snooze timer
snooze_dsec
    movlw 0x00
    cpfseq alarm_sec_cnt
    bra snooze_dsec2
    bra snooze_dsec3
snooze_dsec2
    decf alarm_sec_cnt
    return
snooze_dsec3
    movlw 0x00
    cpfseq alarm_min_cnt
    bra snooze_dsec4
    return
snooze_dsec4
    call snooze_dmin
    movlw 0x3b
    movwf alarm_sec_cnt
    return
snooze_dmin
    movlw 0x00
    cpfseq alarm_min_cnt
    bra snooze_dmin2
    bra snooze_dmin3
snooze_dmin2
    decf alarm_min_cnt
    return
snooze_dmin3
    return

    end
