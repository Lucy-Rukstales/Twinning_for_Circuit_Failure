//////////////////////////////////////////////////////
// Date: 				7/5/2020
// Contributors: 		Lucy Rukstales, Michaela Mitchell
//
// Description: 		This file allows for data collection from an analog to digital converter (ADC)
//							This trial runs the ADC in PIC Mode, using a 50kHz clock
//
// Components Used:	MIKROE-340
//////////////////////////////////////////////////////

module ADC_Control(clk,rst,CS,P3,P4,P5,storage);

	input P4;  // MISO
	input clk; // 50MHz FPGA clock
	input rst;
	
	output CS; // Chip Select
	output P3; // 50kHz ADC clock
	output P5; // MOSI
	
	output reg [11:0]storage;
	
	reg storage_size;
	wire storage_limit;
	
	assign storage_limit = 1'd1;
	
	Read_ADC my_ADC(clk,rst,CS,P3,P4,P5,sample);
	
	//----------------------------------------------------
	// Run the ADC to collect enough data to fill storage
	always @(negedge clk or negedge rst) begin
	
		if (rst == 1'b0) storage <= 1'd0;
		
		else begin
		
			if (storage_size < storage_limit) begin
				//storage[767:12] <= storage[755:0];
				storage[11:0] <= sample;
				storage_size <= storage_size + 1'd1;
			end
				
			else storage <= storage;
			
		end
		
	end
	
endmodule

module Read_ADC(clk,rst,CS,P3,P4,P5,sample);
	
	input P4;  // MISO
	input clk; // 50MHz FPGA clock
	input rst;
	
	output reg CS; // Chip Select
	output reg P3; // 100kHz ADC clock
	output reg P5; // MOSI
	
	reg [9:0]counter;
	reg [4:0]cnt20;
	output reg [11:0]sample; // Only for testing 12 bits
		
	//----------------------------------------------------
	// Create a counter to divide 50MHz to 100kHz
	always @ (negedge clk or negedge rst) begin
		
		if (rst == 1'b0) counter <= 10'd0;
		
		else begin
		
			if (counter < 10'd499) counter <= counter + 1'b1;
			
			else counter <= 1'b0;
			
		end
			
	end
	
	//----------------------------------------------------
	// Scale clock from 50MHz to 100kHz
	// P3 to be ADC clock
	always @ (negedge clk) begin
		
		if (counter == 10'd0) P3 <= 1'b0;
		
		else if (counter == 10'd250) P3 <= 1'b1;
		
	end
		
	//----------------------------------------------------
	// Count to 20 to step through ADC initialization and data transfer
	always @ (negedge clk) begin
		
		if (rst == 1'b0) cnt20 <= 1'b0;
		
		else if (counter == 10'd0) cnt20 <= cnt20 + 1'b1;
		
	end
	
	//----------------------------------------------------
	// Initialize the ADC to prepare for data transfer
	// P5 to be used for MOSI
	always @ (negedge clk) begin
	
		if (counter == 10'd0) begin
		
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
					
				20: begin
						CS <= 1'b1;
					end
					
				default: CS <= 1'b0;
				
			endcase
			
		end
					
	end
	
	//----------------------------------------------------
	// Read from the ADC, 12-bits at a time
	// P4 to be used for MISO
	always @ (negedge clk or negedge rst) begin
	
		if (rst == 1'b0) sample <= 12'd0;
		
		else if (counter == 10'd125) begin
		
			if (cnt20 >= 5'd8 && cnt20 < 5'd20) begin
			
				sample[11:1] <= sample[10:0];
				sample[0] <= P4;
				
			end
			
			else sample <= sample;
		
		end
		
	end
	
endmodule
