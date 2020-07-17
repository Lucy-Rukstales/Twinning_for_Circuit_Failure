//////////////////////////////////////////////////////
//
// Date: 				7/16/2020
//
// Contributors: 		Lucy Rukstales, Michaela Mitchell
//
// Main Module:		ADC_Control.v
//
// Description: 		This file allows for 12 bits of data collection from an analog to digital converter (ADC)
//							This runs the ADC in PIC Mode, using a 100kHz clock
//
//////////////////////////////////////////////////////

module ADC_Read_12bit(clk,rst,CS,P3,P4,P5,sample,cnt20);
	
	input P4;  // MISO
	input clk; // 50MHz FPGA clock
	input rst;
	
	output reg CS; // Chip Select
	output reg P3; // 100kHz ADC clock
	output reg P5; // MOSI
	
	output reg [11:0]sample;
	output reg [6:0]cnt20;
	
	reg [9:0]counter;
		
	//----------------------------------------------------
	// Create a counter to divide 50MHz to 100kHz
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) counter <= 10'd0;
		
		else begin
		
			if (counter < 10'd499) counter <= counter + 1'b1;
			
			else counter <= 1'b0;
			
		end
			
	end
	
	//----------------------------------------------------
	// Scale clock from 50MHz to 100kHz
	// P3 to be ADC clock
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) P3 <= 1'b0;
		
		else begin
		
			if (counter == 10'd0) P3 <= 1'b0;
			
			else if (counter == 10'd250) P3 <= 1'b1;
		
		end
		
	end
		
	//----------------------------------------------------
	// Count to 20 to step through ADC initialization and data transfer
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) cnt20 <= 1'b0;
		
		else if (counter == 10'd0 && cnt20 <= 7'd21) cnt20 <= cnt20 + 1'b1;
		
		else cnt20 <= cnt20;
		
	end
	
	//----------------------------------------------------
	// Initialize the ADC to prepare for data transfer
	// P5 to be used for MOSI
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) CS <= 1'b1;
		
		else if (counter == 10'd0) begin
		
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
		
		else if (counter == 10'd125) begin
		
			case(cnt20)
			
				9: sample[11] <= P4;
					
				10: sample[10] <= P4;
				
				11: sample[9] <= P4;
					
				12: sample[8] <= P4;
				
				13: sample[7] <= P4;
					
				14: sample[6] <= P4;
					
				15: sample[5] <= P4;
					
				16: sample[4] <= P4;
					
				17: sample[3] <= P4;
					
				18: sample[2] <= P4;
					
				19: sample[1] <= P4;
					
				20: sample[0] <= P4;
					
				default: sample <= sample;
					
			endcase
		
		end
		
		else sample <= sample;
		
	end
	
endmodule
