//////////////////////////////////////////////////////
//
// Date: 		4/14/2020
//
// Contributors: 	Lucy Rukstales, Michaela Mitchell
//
// Top Module:		Data_Collector.v
//
// Description: 	This file allows for 12 bits of data collection from an analog to digital converter (ADC)
//			This runs the ADC in PIC Mode, using a 100kHz clock
//
//////////////////////////////////////////////////////

module Slow_ADC_Read_12bit(clk,rst,CS,P3,P4,P5,sample,cnt20);
	
	input P4;  // MISO - Data from ADC
	input clk; // FPGA - 50MHz clock
	input rst; // Reset switch
	
	output reg CS; // Chip Select - Turns ADC on
	output reg P3; // ADC - 2MHz clock
	output reg P5; // MOSI - Control data for ADC
	
	output reg [11:0]sample; // 12-bit data sample
	output reg [6:0]cnt20;   // Counter to step through ADC control
	
	reg [4:0]counter; // Counter to establish 100kHz ADC clock
		
	//----------------------------------------------------
	// Create a counter to divide 50MHz FPGA clock to roughly 2MHz ADC clock
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) counter <= 5'd0;
		
		else begin
		
			if (counter < 5'd27) counter <= counter + 5'd1;
			
			else counter <= 5'd0;
			
		end
			
	end
	
	//----------------------------------------------------
	// Scale clock from 50MHz to roughly 2MHz
	// P3 to be ADC clock
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) P3 <= 1'b0;
		
		else begin
		
			if (counter == 5'd0) P3 <= 1'b0;
			
			else if (counter == 5'd14) P3 <= 1'b1;
		
		end
		
	end
		
	//----------------------------------------------------
	// Count to 20 to step through ADC initialization and data transfer
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) cnt20 <= 7'd0;
		
		else if (counter == 5'd0 && cnt20 <= 7'd21) cnt20 <= cnt20 + 7'd1;
		
		else cnt20 <= cnt20;
		
	end
	
	//----------------------------------------------------
	// Initialize the ADC to prepare for data transfer
	// P5 to be used for MOSI
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) CS <= 1'b1;
		
		else if (counter == 5'd0) begin
		
			case(cnt20)
				0: begin // Initialization
						CS <= 1'b1;
						P5 <= 1'b0;
					end
					
				1: begin // Start Bit
						CS <= 1'b0;
						P5 <= 1'b1;
					end
					
				2: begin // Control: Single Ended
						CS <= 1'b0;
						P5 <= 1'b1;
					end
					
				3: begin // Control: Don't Care
						CS <= 1'b0;
					end
					
				4: begin // Control: Channel 0
						CS <= 1'b0;
						P5 <= 1'b0;
					end
					
				5: begin // Control: Channel 0
						CS <= 1'b0;
						P5 <= 1'b0;
					end
				
				21: begin
						CS <= 1'b1;
					end
					
				default: CS <= 1'b0;
				
			endcase
			
		end
					
	end
	
	//----------------------------------------------------
	// Read from the ADC, 12-bits at a time
	// P4 to be used for MISO
	always @ (posedge clk or negedge rst) begin
	
		if (rst == 1'b0) sample[11:0] <= 12'd0;
		
		else if (counter == 5'd7 && cnt20 > 7'd8 && cnt20 < 7'd21) sample[11:0] <= {sample[10:0],P4};
		
		else sample <= sample;
		
	end
	
endmodule
