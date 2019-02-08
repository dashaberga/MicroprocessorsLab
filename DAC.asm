#include p18f87k22.inc

    global DAC_Setup, time_sec, time_min, time_hour
    
acs0    udata_acs   ; named variables in access ram
time_sec  res 1
time_min  res 1
time_hour res 1
temp_storage res 1

int_hi code 0x0008 ; high vector, no low vector
    
    btfss INTCON,TMR1IF ; check that this is timer0 interrupt 
    retfie FAST ; if not then return
    movlw  0xdc
    movwf  TMR1L
    movlw  0x0b
    movlw  TMR1H 
    movff time_sec, temp_storage
    movlw 0x3b
    subwf temp_storage
    bz inc_minute
    incf time_sec
    bcf INTCON,TMR1IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
inc_minute
    movlw 0x00
    movwf time_sec
    movff time_min, temp_storage
    movlw 0x3b
    subwf temp_storage
    bz inc_hour
    incf time_min
    bcf INTCON,TMR1IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
inc_hour
    movlw 0x00
    movwf time_min
    movff time_hour, temp_storage
    movlw 0x17
    subwf temp_storage
    bz new_day
    incf time_hour
    bcf INTCON,TMR1IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
new_day
    movlw 0x00
    movwf time_sec
    movwf time_min
    movwf time_hour
    bcf INTCON,TMR1IF ; clear interrupt flag
    retfie FAST ; fast return from interrupt
    
DAC code

DAC_Setup
    movlw b'10000111' ; Set timer0 to 16-bit, Fosc/4/256 
    movwf T1CON ; = 62.5KHz clock rate, approx 1sec rollover
    bsf INTCON,TMR1IE ; Enable timer0 interrupt 
    bsf INTCON,GIE ; Enable all interrupts return
    movlw 0x30
    movwf time_sec
    movlw 0x17
    movwf time_hour
    movlw 0x3b
    movwf time_min
    return
    
    end

