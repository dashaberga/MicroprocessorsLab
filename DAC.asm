#include p18f87k22.inc

    global DAC_Setup, time_sec
    
acs0    udata_acs   ; named variables in access ram
time_sec  res 1
time_min  res 1
time_hour res 1

int_hi code 0x0008 ; high vector, no low vector
    
    btfss INTCON,TMR0IF ; check that this is timer0 interrupt 
    retfie FAST ; if not then return 
    incf time_sec
    bcf INTCON,TMR0IF ; clear interrupt flag
    
    retfie FAST ; fast return from interrupt

DAC code

DAC_Setup
DAC_Setup
    movlw b'10000111' ; Set timer0 to 16-bit, Fosc/4/256 
    movwf T0CON ; = 62.5KHz clock rate, approx 1sec rollover
    bsf INTCON,TMR0IE ; Enable timer0 interrupt 
    bsf INTCON,GIE ; Enable all interrupts return
    movlw 0x00
    movwf time_sec
    movwf time_hour
    movwf time_min
    return
    
    end

