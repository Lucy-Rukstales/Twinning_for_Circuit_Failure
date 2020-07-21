// FPGA-Arduino SPI Protocol
// Arduino Child

//Notes:
//Pin defintions (SCL, MOSI, SS) are inherently defined when SPI slave mode enabled (from datasheet)
//SPCR is the "SPI Control Register"

#include<SPI.h> //SPI library
volatile int i = 0; //volatile types to be sent to ISR
byte twelveBitArray[2]; //temporary storage array from ISR (2 bytes for each 12 bit sample)


const int numberOfSamples = 10; //Change based on how much data user wishes to collect
int sampleNumber = 0; //Intialize counter
int storedData[numberOfSamples+1] = {0}; //Final storage array

void setup()
{
  Serial.begin(9600);
  SPCR |= _BV(SPE); //Enable slave mode and SPI
  SPCR |= _BV(SPIE); //Attach interrupts
}

void loop(void){
  if (i >= 1){
    int x = (int)twelveBitArray[0];
    x = x<<8;
    int y = (int)twelveBitArray[1];
    int z = x|y;

    //Store new sample in storage array, print it out if finished
    if (sampleNumber <= numberOfSamples) {
      storedData[sampleNumber] = z;
      sampleNumber = sampleNumber+1;
    }
    else {
      Serial.print(numberOfSamples);
      Serial.print(" samples have been stored: ");
      for(int j = 0; j < numberOfSamples; j++) {
        Serial.println(storedData[j]);
      } 
    }
    
    Serial.print("Received data item from FPGA-Master: ");
    Serial.println(z, BIN); //Binary for testing, likely hex later
    i=0;
    Serial.println("=============================================");
  }
}

ISR (SPI_STC_vect)   //Interrput service "routine SPI transfer complete vector"
{
  twelveBitArray[i] = SPDR; //SPDR: SPI Data Register (Sampled data from MOSI)
  i++;
}
