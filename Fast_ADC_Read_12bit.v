//////////////////////////////////////////////////////
//
// Date: 		8/5/2020
//
// Contributors: 	Lucy Rukstales, Michaela Mitchell
//
// Top Module:		Data_Collector.v
//
// Description: 	This file allows for 12 bits of data collection from an analog to digital converter (ADC)
//			This runs the ADC using the 25MHz FPGA clock; 12-bit samples sent at roughly 1.5MHz
//
//////////////////////////////////////////////////////

module Fast_ADC_Read_12bit(clk,rst,CS,SCK,SDO,sample,cnt15);
	
	input SDO; // MISO - Data from ADC
	input clk; // FPGA - 50MHz clock
	input rst; // Reset switch
	
	output reg CS;  // Chip Select - Turns ADC on
	output reg SCK; // ADC - 25MHz clock
	
	output reg [11:0]sample; // 12-bit data sample
	output reg [4:0]cnt15;   // Counter to step through ADC control
	
	reg [1:0]counter; // Counter to establish 25MHz ADC clock
		
	//----------------------------------------------------
	// Create a counter to divide 50MHz FPGA clock to 25MHz ADC clock
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) counter <= 2'd0;
		
		else begin
		
			if (counter == 2'd0) counter <= 2'd1;
			
			else counter <= 2'd0;
			
		end
			
	end
	
	//----------------------------------------------------
	// Scale clock from 50MHz to 25MHz
	// SCK to be ADC clock
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) SCK <= 1'b0;
		
		else begin
		
			if (counter == 2'd0) SCK <= 1'b0;
			
			else if (counter == 2'd1) SCK <= 1'b1;
		
		end
		
	end
		
	//----------------------------------------------------
	// Count to 15 to step through ADC initialization and data transfer
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) cnt15 <= 5'd0;
		
		else if (counter == 2'd0 && cnt15 <= 5'd16) cnt15 <= cnt15 + 5'd1;
		
		else cnt15 <= cnt15;
		
	end
	
	//----------------------------------------------------
	// Data transfer
	// SDO to be used for MISO
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) begin
			
			CS <= 1'b1;
			sample[11:0] <= 12'd0;
		
		end
		
		else if (counter == 2'd1 && (cnt15 == 5'd0 || cnt15 == 5'd15)) CS <= 1'b0;
		
		else if (counter == 2'd0) begin
			
			if (counter == 3'd1 && cnt15 > 5'd1 && cnt15 < 5'd14) sample[11:0] <= {sample[10:0],SDO};
		
			else sample <= sample;
			
		end
					
	end
	
endmodule
