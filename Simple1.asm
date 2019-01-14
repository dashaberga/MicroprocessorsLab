	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start
	movlw   0x13
	movwf   0x05
	movlw 	0x0
	movwf	TRISC, ACCESS	    ; Port C all outputs
	bra 	test
loop	call    delay, 0
	movff 	0x06, PORTC
	incf 	0x06, W, ACCESS
test	movwf	0x06, ACCESS	    ; Test for end of loop condition
	movf    PORTD, W
	cpfsgt 	0x06, ACCESS
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start
delay	decfsz  0x05
	bra     delay
	return
	
	end
