//////////////////////////////////////////////////////
// Date: 				6/20/2020
// Contributors: 		Lucy Rukstales, Michaela Mitchell
//
// Description: 		This file allows for data collection from an analog to digital converter (ADC)
//							This trial runs the ADC in PIC Mode, using a 50kHz clock
//
// Components Used:	MIKROE-340
//////////////////////////////////////////////////////

module ADC_Control(clk,P3,CS,P4);//,NC,P3,P5,clk);

	input P4;  // MISO
	input clk; // 50MHz FPGA clock
	
	output reg CS;//,NC;
	output reg P3; // 50kHz ADC clock
	//output reg P5; // MOSI
	
	reg [9:0]counter;
	reg [4:0]cnt12;
	reg [11:0]sample;
	
	initial CS = 1'b1;
	
	//----------------------------------------------------
	// Scale the clk from 50MHz to 50kHz
	// P3 to be used with the ADC
	always @ (posedge clk) begin
		
		if(counter < 10'd500) begin
			P3 <= 1'b1;
			counter <= counter + 1'b1;
		end
		
		else if (counter < 10'd999) begin
			P3 <= 1'b0;
			counter <= counter + 1'b1;
		end
		
		else
			counter <= 1'b0;
			
	end
	
	//----------------------------------------------------
	// Enable the ADC
	always @ (posedge P3) CS <= 1'b0;
	
	//----------------------------------------------------
	// Count to 12 using cnt12
	always @ (posedge P3) begin
	
		if(CS == 1'b0) begin
		
			if (cnt12 == 4'd11) cnt12 <= 1'b0;
				
			cnt12 <= cnt12 + 1'b1;
		
		end
		
	end
	
	//----------------------------------------------------
	// Read from the ADC, 12-bits at a time
	// P4 to be used for MISO
	always @ (posedge P3) begin
	
		if (CS == 1'b0) begin

			if (cnt12 < 4'd12) begin
				sample[11:1] <= sample[10:0];
				sample[0] <= P4;
			end
		
		end
		
	end
	
endmodule
