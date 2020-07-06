//Test Arduino Master

#include<SPI.h>
byte data = 255;

void setup()
{
  Serial.begin(9600);
  SPI.begin();
  SPCR |= _BV(CPHA); //Sample on falling edge of clock signal
  SPCR |= _BV(SPR1); //SCL speed = 250kHz
  SPCR |= _BV(SPR0);
  SPI.setClockDivider(SPI_CLOCK_DIV128); //bit rate = 16 MHz/128 = 125 kbit/sec
  digitalWrite(SS, LOW);   //Slave is selected
}

void loop()
{
  SPI.transfer(highByte(data));
  SPI.transfer(lowByte(data));
  //-----------------------
  delay(3000);  //test interval
}
