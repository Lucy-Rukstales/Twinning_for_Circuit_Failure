//////////////////////////////////////////////////////
//
// Date: 		4/14/2020
//
// Contributors: 	Lucy Rukstales, Michaela Mitchell
//
// Sub Modules:		Slow_ADC_Read_12bit.v
//			Arduino_Write_12bit.v
//
// Description: 	This file uses ADC_Read_12bit.v to collect a "user-defined" amt of data from an analog to digital converter (ADC)
//			The data is then sent to an Arduino using Arduino_Write_12bit.v
//
// Components Used:	MIKROE-340
//
//////////////////////////////////////////////////////

module Data_Collector(clk,rst,CS,P3,P4,P5,SCL,SS,MOSI);

	input P4;  	 // ADC - MISO
	input clk; 	 // FPGA - 50MHz clock
	input rst;	 // Reset switch
	
	output CS; 	 // ADC - Chip Select
	output P3; 	 // ADC - 100kHz clock
	output P5; 	 // ADC - MOSI
	output SCL;  	 // Arduino - 100kHz clk
	output SS; 	 // Arduino - Chip Select
	output MOSI; 	 // Arduino - Parent out child in

	reg adc_rst;	   // ADC reset switch - turns on ADC module
	reg arduino_rst;   // Arduino reset switch - turns on Arduino module
	reg wren;
	
	reg [5:0]address;
	
	wire [11:0]ADC_Sample;	   // Current 12-bit sample from ADC
	wire [11:0]Arduino_Sample;  // Current 12-bit sample for Arduino
	wire [6:0]cnt20;	         // Signal from ADC module
	wire [5:0]SCLtracker;	   // Signal from Arduino module
	wire [5:0]storage_limit;   // "User-defined" amount of data to collect from ADC
	
	assign storage_limit = 6'd34;
	
	Slow_ADC_Read_12bit my_ADC(clk,adc_rst,CS,P3,P4,P5,ADC_Sample,cnt20);
	
	Arduino_Write_12bit my_Arduino(clk,arduino_rst,Arduino_Sample,SCL,SS,MOSI,SCLtracker);
	
	data memory(address,clk,ADC_Sample,wren,Arduino_Sample);
	
	//----------------------------------------------------
	// Collect data from the ADC 12-bits at a time
	// Send data to the Arduino 12-bits at a time
	always @(posedge clk or negedge rst) begin
		
		// Clears everything
		if (rst == 1'b0) begin 
		
			adc_rst <= 1'b0; 
			arduino_rst <= 1'b0;
			address <= 6'd0;
			wren <= 1'b1;
			
		end
		
		// Collect data from ADC until storage is filled
		else if (wren == 1'b1) begin
			
			if (address < storage_limit) begin
			
				if (cnt20 < 7'd21) adc_rst <= 1'b1;
				
				else if (adc_rst == 1'b1) begin
				
					address <= address + 6'd1;
					adc_rst <= 1'b0;
					
				end
			
			end
			
			else begin
				
				address <= 6'd0;
				wren <= 1'b0;
				
			end
			
		end
		
		// Send data to Arduino until storage is emptied
		else if (address < storage_limit) begin
			
			if (SCLtracker < 6'd36) arduino_rst <= 1'b1;
			
			else if (arduino_rst == 1'b1) begin
			
				address <= address + 6'd1;
				arduino_rst <= 1'b0;
								
			end
			
		end
		
	end
	
endmodule
