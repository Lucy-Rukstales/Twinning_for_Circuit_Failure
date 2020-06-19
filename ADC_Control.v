//////////////////////////////////////////////////////
// Date: 				6/19/2020
// Contributors: 		Lucy Rukstales, Michaela Mitchell
//
// Description: 		This file allows for data collection from an analog to digital converter (ADC)
//							This trial runs the ADC in PIC Mode, using a 50kHz clock
//
// Components Used:	MIKROE-340
//////////////////////////////////////////////////////

module ADC_Control(clk,P3);//CS,P4,NC,P3,P5,clk);

	//input P4;  // MISO
	input clk; // 50MHz FPGA clock
	
	//output CS,NC;
	
	output reg P3; // 50kHz ADC clock
	//output reg P5; // MOSI
	
	reg [9:0]counter;
	
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
	
endmodule
