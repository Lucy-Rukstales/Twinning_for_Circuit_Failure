// FPGA-Arduino SPI Protocol
// Arduino Child

//Notes:
//Pin defintions (SCL, MOSI, SS) are inherently defined when SPI slave mode enabled (from datasheet)
//SPCR is the "SPI Control Register"

#include<SPI.h> //SPI library
volatile int i = 0; //volatile types to be sent to ISR
byte twelveBitArray[2]; //temporary storage array from ISR (2 bytes for each 12 bit sample)


const int numberOfSamples = 1; //Change based on how much data user wishes to collect
int sampleNumber = 0; //Intialize counter
int storedData[numberOfSamples] = {0}; //Final storage array
int x, y;

void setup() {
  Serial.begin(9600);
  SPCR |= _BV(SPE); //Enable slave mode and SPI
  SPCR |= _BV(SPIE); //Attach interrupts
}

void loop(void) {
  if (i >= 1) {
    
    //Store new sample in storage array, print it out if finished
    if (sampleNumber < numberOfSamples) {
      x = (int)twelveBitArray[0];
      x = x << 8;
      delay(50);
      y = (int)twelveBitArray[1];
      noInterrupts();
      storedData[sampleNumber] = x | y;
      sampleNumber = sampleNumber + 1;
      interrupts();
    }else if (sampleNumber == numberOfSamples) {
      noInterrupts();
      Serial.print(sampleNumber);
      Serial.println(" samples have been stored: ");
      for (int j = 0; j < sampleNumber; j++) {
        Serial.println(storedData[j],BIN);
      }
      interrupts();
    }
    
    i = 0;
  }
}

ISR (SPI_STC_vect)   //Interrput service "routine SPI transfer complete vector"
{
  twelveBitArray[i] = SPDR; //SPDR: SPI Data Register (Sampled data from MOSI)
  i++;
}
