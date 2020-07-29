//////////////////////////////////////////////////////
//
// Date: 				7/29/2020
//
// Contributors: 		Lucy Rukstales, Michaela Mitchell
//
// Sub Modules:		ADC_Read_12bit.v
//							Arduino_Write_12bit.v
//
// Description: 		This file uses ADC_Read_12bit.v to collect a "user-defined" amt of data from an analog to digital converter (ADC)
//							The data is then sent to an Arduino using Arduino_Write_12bit.v
//
// Components Used:	MIKROE-340
//
//////////////////////////////////////////////////////

module Data_Collector(clk,rst,CS,P3,P4,P5,SCL,SS,MOSI);

	input P4;  	 // ADC - MISO
	input clk; 	 // 50MHz FPGA clock
	input rst;	 // Reset switch
	
	output CS; 	 // ADC - Chip Select
	output P3; 	 // ADC - 100kHz clock
	output P5; 	 // ADC - MOSI
	output SCL;  // Arduino - 100kHz clk
	output SS; 	 // Arduino - Chip Select
	output MOSI; // Arduino - Parent out child in

	reg collection_status,read_status;
	
	reg [1199:0]storage;
	reg [11:0]Arduino_Sample;  // Current 12-bit sample for Arduino
	reg [6:0]collected_amt;    // Number of samples from the ADC
	reg [6:0]transmitted_amt;  // Number of samples sent to the Arduino
	
	wire [11:0]ADC_Sample;		// Current 12-bit sample from ADC
	wire [6:0]cnt20;
	wire [5:0]SCLtracker;
	wire [6:0]storage_limit;   // User-defined amount of data to collect from ADC
	
	assign storage_limit = 7'd100;
	
	ADC_Read_12bit my_ADC(clk,read_status,CS,P3,P4,P5,ADC_Sample,cnt20);
	
	Arduino_Write_12bit my_Arduino(clk,collection_status,Arduino_Sample,SCL,SS,MOSI,SCLtracker);
	
	//----------------------------------------------------
	// Collect data from the ADC 12-bits at a time
	always @(posedge clk or negedge rst) begin

		if (rst == 1'b0) begin 
		
			storage[1199:0] <= 1200'd0;
			collected_amt <= 7'd0;
			transmitted_amt <= 7'd0;
			read_status <= 1'b0;
			collection_status <= 1'b0;
			Arduino_Sample <= 12'd0;
			
		end
		
		else if (collected_amt < storage_limit) begin
			
			if(cnt20 == 7'd0) read_status <= 1'b1;
			
			else if(cnt20 == 7'd21) begin
			
				storage[1199:0] <= {storage[1187:0],ADC_Sample[11:0]};
				collected_amt <= collected_amt + 7'd1;
				read_status <= 1'b0;
				
			end
			
		end
		
		else if (collected_amt == storage_limit && transmitted_amt < storage_limit) begin
			
			if (SCLtracker >= 6'd0 && SCLtracker < 6'd36) begin
				
				Arduino_Sample[11:0] <= storage[1199:1188];	
				collection_status <= 1'b1;
				
			end				
			
			else if (SCLtracker == 6'd36 && collection_status == 1'b1) begin
			
				collection_status <= 1'b0;
				transmitted_amt <= transmitted_amt + 7'd1;
				storage <= storage << 12'd12;
				
			end
			
		end
		
	end
	
endmodule
