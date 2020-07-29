//////////////////////////////////////////////////////
//
// Date:          7/29/2020
//
// Contributors:  Lucy Rukstales, Michaela Mitchell
//
// Description:   This file utilizes SPI Protocols to collect data from the FPGA.
//                The FPGA is the master/parent while the Arduino is the slave/child.
//
// Notes:         Pin defintions (SCL, MOSI, SS) are inherently defined when SPI slave mode enabled (from datasheet).
//                SPCR is the "SPI Control Register"
//
//////////////////////////////////////////////////////

#include<SPI.h> //SPI library
volatile int i = 0; //volatile types to be sent to ISR
const int numberOfSamples = 100; //Change based on how much data user wishes to collect //2048
byte twelveBitArray[numberOfSamples * 2]; //temporary storage array from ISR (2 bytes for each 12 bit sample)// 4096
int sampleNumber = 0; //Intialize counter
int sample[numberOfSamples]; // Final storage array
int x, y, z;

void setup() {
  Serial.begin(9600);
  SPCR |= _BV(SPE); //Enable slave mode and SPI
  SPCR |= _BV(SPIE); //Attach interrupts
}

void loop(void) { // variable "processupto"
  if (i == numberOfSamples * 2) {
    noInterrupts();
    for (int j = 0; j < numberOfSamples * 2; j++) {
      if (j % 2 == 0) {
        x = (int)twelveBitArray[j];
        x = x << 8;
      } else {
        y = (int)twelveBitArray[j];
        sample[j / 2] = x | y;
      }
    } for (int k = 0; k < numberOfSamples; k++) {
      Serial.println(sample[k]);
      //Serial.println(((double)sample[k] / 4096.0) * 5.0);
      delay(5000);
    }
    interrupts();
    i = 0;
  }
}

ISR (SPI_STC_vect) {  //Interrput service "routine SPI transfer complete vector" // this is fine as is // turn of ISR when get to 4096
  twelveBitArray[i] = SPDR; //SPDR: SPI Data Register (Sampled data from MOSI)
  i++;
}
