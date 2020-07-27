
#include <SPI.h>

char buf [100];
int tracker = 0;
volatile byte pos;
volatile boolean process_it;

int storedData[11] = {0}; //Final storage array

void setup (void)
{
  Serial.begin (9600);  // debugging
  
  // turn on SPI in slave mode
  SPCR |= bit (SPE);

  // have to send on master in, *slave out*
  pinMode(MISO, OUTPUT);
  
  // get ready for an interrupt 
  pos = 0;   // buffer empty
  process_it = false;

  // now turn on interrupts
  SPI.attachInterrupt();

}  // end of setup


// SPI interrupt routine
ISR (SPI_STC_vect)
{
byte c = SPDR;  // grab byte from SPI Data Register
  
  // add to buffer if room
  if (pos < (sizeof (buf) - 1))
    buf [pos++] = c;
    
  // example: newline means time to process buffer
  if (c == '\n')
    process_it = true;
      
}  // end of interrupt routine SPI_STC_vect

// main loop - wait for flag set in interrupt routine
void loop (void)
{
  if (process_it)
    {
    buf [pos] = 0;  
    //Serial.println (buf);
    storedData[tracker] = buf; 
    pos = 0;
    process_it = false;
    tracker++;
    }  // end of flag set

  if (tracker > 11) {
    for (int i = 0; i<12; i++) {
    Serial.println(storedData[i]);
    }
  }
    
}  // end of loop
