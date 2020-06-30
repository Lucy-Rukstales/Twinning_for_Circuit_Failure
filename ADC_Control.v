//////////////////////////////////////////////////////
// Date: 				6/26/2020
// Contributors: 		Lucy Rukstales, Michaela Mitchell
//
// Description: 		This file allows for data collection from an analog to digital converter (ADC)
//							This trial runs the ADC in PIC Mode, using a 50kHz clock
//
// Components Used:	MIKROE-340
//////////////////////////////////////////////////////

module ADC_Control(clk,rst,CS,P3,P4,P5);

	input P4;  // MISO
	input clk; // 50MHz FPGA clock
	input rst;
	
	output reg CS; // Chip Select
	output reg P3; // 50kHz ADC clock
	output reg P5; // MOSI
	
	reg [9:0]counter;
	reg [4:0]cnt20;
	reg [11:0]sample;
	
	//----------------------------------------------------
	// Create a counter to divide 50MHz to 50kHz
	always @ (posedge clk or negedge rst) begin
		
		if (rst == 1'b0) counter <= 10'd0;
		
		else begin
		
			if (counter < 10'd999) counter <= counter + 1'b1;
			
			else counter <= 1'b0;
			
		end
			
	end
	
	//----------------------------------------------------
	// Scale clock from 50MHz to 50kHz
	// P3 to be ADC clock
	always @ (*) begin
		
		if (counter == 10'd0) P3 = 1'b1;
		
		else if (counter == 10'd500) P3 = 1'b0;
		
	end
		
	//----------------------------------------------------
	// Count to 20 to step through ADC initialization and data transfer
	always @ (*) begin
		
		if (counter == 10'd0) begin
		
			//if (cnt20 == 5'd19) cnt20 = 1'b0;
				
			cnt20 = cnt20 + 1'b1;
		
		end
		
	end
	
	//----------------------------------------------------
	// Initialize the ADC to prepare for data transfer
	// P5 to be used for MOSI
	always @ (*) begin
	
		if (counter == 10'd500) begin
		
			case(cnt20)
				0: begin // Initialization
						CS = 1'b1;
						P5 = 1'b0;
					end
					
				1: begin // Start Bit
						CS = 1'b0;
						P5 = 1'b1;
					end
					
				2: begin // Control: Single Ended
						CS = 1'b0;
						P5 = 1'b1;
					end
					
				3: begin // Control: Don't Care
						CS = 1'b0;
					end
					
				4: begin // Control: Channel 0
						CS = 1'b0;
						P5 = 1'b0;
					end
					
				5: begin // Control: Channel 0
						CS = 1'b0;
						P5 = 1'b0;
					end
					
				20: begin
						CS = 1'b1;
					end
					
				default: CS = 1'b0;
				
			endcase
			
		end
					
	end
	
	//----------------------------------------------------
	// Read from the ADC, 12-bits at a time
	// P4 to be used for MISO
	always @ (posedge clk or negedge rst) begin
	
		if (rst == 1'b0) sample <= 12'd0;
		
		else begin
		
			if (counter == 10'd250) begin
		
				if (cnt20 >= 5'd8 && cnt20 < 5'd20) begin
				
					sample[11:1] <= sample[10:0];
					sample[0] <= P4;
					
				end
			
			end
			
		end
		
	end
	
endmodule
