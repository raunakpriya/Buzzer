
// Sounds buzzer while LED lit
// Interrupts on input high->low edges, LPM4 while waiting
// LED1,2 active low on P2.3,4
//   buttons B1, B2 active low on P2.1, P1.2


#include <io430x11x1.h>	
#include <intrinsics.h>				

#define	LED1	BIT3
#define	LED2	BIT4
#define	B1	BIT1
#define	B2	BIT2
#define	PIEZO1	BIT0
#define	PIEZO2	BIT5

void main (void)
{
	WDTCTL = WDTPW|WDTHOLD;			// Stop watchdog timer
	P2OUT = PIEZO1|LED1|LED2;		
	P2DIR = PIEZO1|PIEZO2|LED1|LED2;	
	P2IES = B1;						
	P1IES = B2;						
	TACCR0 = 32;					
	TACCTL0 = CCIE;					
	for (;;) {						
		while ((P2IN & B1) == 0 || (P1IN & B2) == 0) {
		}				
		do {
			P1IFG = 0;				
			P2IFG = 0;				
		} while ((P1IFG != 0) || (P2IFG != 0));
		P2IE = B1;					
		P1IE = B2;
		__low_power_mode_4();		
		P2IE = 0;					
		P1IE = 0;
		TACTL = MC_1|TASSEL_1|TACLR;	
		__low_power_mode_3();		

		TACTL = 0;					
		P2OUT |= (LED1|LED2);		
	}
}

#pragma vector = PORT2_VECTOR
__interrupt void PORT2_ISR (void)
{
	P2IFG = 0;						
	P2OUT &= ~LED1;					
	__low_power_mode_off_on_exit();	
}
#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR (void)
{
	P1IFG = 0;						
	P2OUT &= ~LED2;					
	__low_power_mode_off_on_exit();	
}
#define SECONDLOOPS	1000
#pragma vector = TIMERA0_VECTOR
__interrupt void TA0_ISR (void)
{
	static unsigned int ticks = SECONDLOOPS;	

	P2OUT ^= PIEZO1|PIEZO2;				
	if (--ticks == 0) {					
		ticks = SECONDLOOPS;			
		__low_power_mode_off_on_exit();
	}
}
