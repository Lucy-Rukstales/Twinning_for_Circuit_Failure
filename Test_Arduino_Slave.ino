// FPGA-Arduino SPI Protocol
// Arduino Slave

//Notes:
//Pin defintions (SCL, MOSI, SS) are inherently defined when SPI slave mode enabled (from datasheet)
//SPCR is the "SPI Control Register"
  /* SPCR, default all are zeros, set to ones in setup
    | 7    | 6    | 5    | 4    | 3    | 2    | 1    | 0    |
    | SPIE | SPE  | DORD | MSTR | CPOL | CPHA | SPR1 | SPR0 |
    SPIE - Enables the SPI interrupt when 1
    SPE - Enables the SPI when 1
    DORD - Sends data least Significant Bit First when 1, most Significant Bit first when 0
    MSTR - Sets the Arduino in master mode when 1, slave mode when 0
    CPOL - Sets the data clock to be idle when high if set to 1, idle when low if set to 0
    CPHA - Samples data on the falling edge of the data clock when 1, rising edge when 0
    SPR1 and SPR0 - Sets the SPI speed, 00 is fastest (4MHz) 11 is slowest (250KHz) (master only) */

#include<SPI.h> //SPI library
volatile int i = 0; //volatile types to be sent to ISR
byte myArray[1];

void setup()
{
  Serial.begin(9600);
  SPCR |= _BV(SPE); //Enable slave mode and SPI
  SPCR |= _BV(SPIE); //Attach interrupts
  //SPCR |= _BV(CPHA); //Sample on falling edge of SCL (data mode 1)
}

void loop(void){
  if (i == 1){
    int x = (int)myArray[0]<<8|(int)myArray[1];
    Serial.print("Received data item from FPGA-Master: ");
    Serial.println(x, BIN); //Binary for testing, likely hex later
    i=0;
    Serial.println("=============================================");
  }
}

ISR (SPI_STC_vect)   //Interrput service "routine SPI trasnfer complete vector"
{
  myArray[i] = SPDR; //SPDR: SPI Data Register (Sampled data from MOSI)
  i++;
}
