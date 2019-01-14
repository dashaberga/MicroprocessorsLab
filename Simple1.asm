	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start
	movlw 	0x0
	movwf	TRISC, ACCESS	    ; Port C all outputs
	bra 	test
loop	movlw   0x13		    
	movwf   0x05		    ; Reset first delay counter
	call    delay, 0	    ; Call delay loop
	movff 	0x06, PORTC	    ; Output value to Port C
	incf 	0x06, W, ACCESS
test	movwf	0x06, ACCESS	    ; Test for end of loop condition
	movf    PORTD, W
	cpfsgt 	0x06, ACCESS
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start
delay	movlw   0x13
	movwf   0x04		    ; Reset 2nd delay counter
	call delay2		    ; Call second nested delay loop
	decfsz  0x05		    ; Decremant counter, skip if zero
	bra     delay		    ; Loop back to delay
	return			    ; Return to loop
delay2  decfsz  0x04		    ; Decremant counter, skip if zero
	bra     delay2		    ; Loop back to delay2
	return			    ; Return to delay loop
	end