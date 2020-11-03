//////////////////////////////////////////////////////
//
// Date: 	11/3/2020
//
// Contributors: 	Lucy Rukstales, Michaela Mitchell, Gillian Holman
//
// Top Module:		None
//
// Description: 	This file allows for 12 bits of data collection from an analog to digital converter (ADC)
//			This runs the ADC using a 1MHz clock
//
//////////////////////////////////////////////////////

module ADC_Tester(clk,rst,CS,SDO,SCK,sample);
	
	input SDO; // MISO - Data from ADC
	input clk; // FPGA - 50MHz clock
	input rst; // Reset switch
	
	output reg SCK;
	output reg CS;           // Chip Select - Turns ADC on
	output reg [11:0]sample; // 12-bit data sample
	reg [4:0]cnt18;          // SCK to step through ADC control
	reg [5:0]counter;
	
	//----------------------------------------------------
	// Create a counter to slow down processing
	always @ (posedge clk or negedge rst) begin
	
		if(rst == 1'b0) counter <= 6'b0;
		
		else begin
		
			if (counter < 6'd49) counter <= counter + 6'd1;
		
			else counter <= 6'd0;
			
		end
		
	end
	
	//----------------------------------------------------
	// Scale the 50MHz FPGA clock to 1MHz
	always @ (posedge clk or negedge rst) begin
	
		if (rst == 1'b0) SCK <= 1'b0;
		
		else begin
		
			if (counter == 6'd0) SCK <= 1'b1;
			
			else if (counter == 6'd25) SCK <= 1'b0;
		
		end
   end
	
	//----------------------------------------------------
	// Count to 18 to step through ADC initialization and data transfer
	always @ (posedge clk or negedge rst) begin
	
		if (rst == 1'b0) cnt18 <= 5'd0;
		
		else if (counter == 6'd25 && CS == 1'b0) begin
			
			if (cnt18 < 5'd18) cnt18 <= cnt18 + 5'd1;
			
			else cnt18 <= cnt18;
			
		end
		
	end
	
	//----------------------------------------------------
	// Data transfer
	// SDO to be used for MISO
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) begin
			
			CS <= 1'b1;
			sample[11:0] <= 12'd0;
		
		end
		
		else if (counter == 6'd0) begin
			
			if (cnt18 == 5'd0) CS <= 1'b0;
			
			else if (cnt18 > 5'd1 && cnt18 < 5'd15) sample[11:0] <= {sample[10:0],SDO};
			
			else if (cnt18 >= 5'd18) CS = 1'b1;
			
			else sample <= sample;
			
		end
					
	end
	
endmodule
