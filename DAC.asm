#include p18f87k22.inc

    global DAC_Setup, time_sec, time_min, time_hour, time_day, time_week, time_month, time_year
    
    extern mode_counter
    
acs0    udata_acs   ; named variables in access ram
time_millisec res 1
time_sec  res 1
time_min  res 1
time_hour res 1
time_day  res 1		; day of the month
time_week res 1		; day of the week
time_month res 1
time_year res 1
time_leap res 1
temp_storage res 1
month_days res 1



int_hi code 0x0008 ; high vector, no low vector
    btfss PIR1,TMR2IF ; check that this is timer0 interrupt 
    retfie FAST ; if not then return 
    btfsc mode_counter, 0
    bra time_stop
    movff time_millisec, temp_storage
    movlw 0xf9
    subwf temp_storage
    bz inc_second
    incf time_millisec
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
inc_second
    movlw 0x00
    movwf time_millisec
    movff time_sec, temp_storage
    movlw 0x3b
    subwf temp_storage
    bz inc_minute
    incf time_sec    
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
inc_minute
    movlw 0x00
    movwf time_sec
    movff time_min, temp_storage
    movlw 0x3b
    subwf temp_storage
    bz inc_hour
    incf time_min
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
inc_hour
    movlw 0x00
    movwf time_min
    movff time_hour, temp_storage
    movlw 0x17
    subwf temp_storage
    bz inc_day
    incf time_hour
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
inc_day
    movlw 0x00
    movwf time_hour
    movff time_week, temp_storage
    movlw 0x07
    subwf temp_storage
    bz new_week
    incf time_week
date
    movff time_day, temp_storage
    movf  month_days, W
    subwf temp_storage
    bz inc_month
    incf time_day
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt

new_week
    movlw 0x01
    movwf time_week
    bra date
    
inc_month
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
    
    movff time_month, temp_storage
    movlw    0x0B
    subwf    temp_storage
    bz       month31
    
    movff time_month, temp_storage
    movlw    0x0C
    subwf    temp_storage
    bz       month31
inc_month2
    movlw 0x01
    movwf time_day
    movff time_month, temp_storage
    movlw 0x0C
    subwf temp_storage
    bz inc_year
    incf time_month
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt

month30
    movlw 0x1e
    movwf month_days
    bra inc_month2
    
month31
    movlw 0x1f
    movwf month_days
    bra inc_month2
    
february
    btfsc time_leap, 2
    bra february_leap
    movlw 0x1c
    movwf month_days
    movlw 0x01
    addwf time_leap
    bra inc_month2
    
february_leap
    movlw 0x1d
    movwf month_days
    movlw 0x01
    movwf time_leap
    bra inc_month2
    
inc_year
    movlw 0x01
    movwf time_month
    incf time_year
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
time_stop
    bcf PIR1,TMR2IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
DAC code

DAC_Setup
    movlw b'01111111' ; Set timer0 to 16-bit, Fosc/4/256 
    movwf T2CON ; = 62.5KHz clock rate, approx 1sec rollover
    movlw 0xF9
    movwf PR2
    bsf PIE1,TMR2IE ; Enable timer0 interrupt 
    bsf INTCON,GIE ; Enable all interrupts return
    bsf INTCON,PEIE ; Enable all interrupts return
    movlw 0x00
    movwf time_millisec
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
    return
    
    end

