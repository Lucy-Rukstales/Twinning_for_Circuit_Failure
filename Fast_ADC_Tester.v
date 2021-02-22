////////////////////////////////////////////////////////////////////////////////
//
// Date: 	2/21/2021
//
// Contributors: 	Lucy Rukstales, Michaela Mitchell, Gillian Holman
//
// Description: 	This file allows for 12 bits of data to be collected from the 
//						high frequency analog to digital converter (ADC). This runs 
//						the ADC using a 2.5 MHz clock.
//
// Variables:		@SDO[in]			Data output stream from the ADC
//											Connected to GPIO PIN_AC15
//
//						@clk[in]			50 MHz FPGA clock
//											Internaally connected to Y2
//
//						@rst[in]			Manual reset switch to load another 12-bit
//											sample from the ADC
//											Connected to switch PIN_AB28
//
//						@SCK[out]		2.5 MHz clock that runs the ADC	
//											Connected to GPIO PIN_AB22			
//				
//						@CS[out]			Chip select line that turns the ADC on
//											Connected to GPIO PIN_AB21
//
//						@sample[out]	12-bit data sample, collected from the ADC
//											Connected the 12 green LEDs on the FPGA board
//
////////////////////////////////////////////////////////////////////////////////

module ADC_Tester(clk,rst,CS,SDO,SCK,sample,rstLED,collectLED);
	
	// Declare inputs
	input SDO; // Data output stream from the ADC
	input clk; // 50 MHz FPGA clock
	input rst; // Manual reset switch
	
	// Declare outputs and registers
	output reg SCK;				// 2.5 MHz clock that runs the ADC
	output reg CS;  				// Chip select line that turns the ADC on
	output reg [11:0]sample; 	// 12-bit data sample, collected from the ADC
	reg [4:0]cnt18;   			// Counter to step through ADC timing diagram
	reg [5:0]counter;				// Counter to scale a clock from 50 MHz to 2.5 MHz
	
	output rstLED; //temp
	assign rstLED = rst; // temp
	output reg collectLED; //temp

	/*
	 * Always block that creates a counter to divide the 50 MHz FPGA clock by 20
	 *
	 * @rst[in]			Manual reset. When low, it sets the counter to zero. When
	 *						When high, it allows the counter to increment.
	 *
	 * @counter[reg]	Register that counts from [0 19], for 20 full ticks of the
	 *						50 MHz FPGA clock. Once the counter reaches 19, counter
	 *						is set to 0, before counting back up.
	 */
	always @ (posedge clk or negedge rst) begin
	
		// If reset is low, set counter to 0
		if (rst == 1'b0) counter <= 6'd0;
		
		// If the user pulls rst high, increment counter
		else begin
		
			// Count from [0 19]
			if (counter < 6'd19) counter <= counter + 6'd1;
		
			// If counter is 19, set it back to 0
			else counter <= 6'd0;
			
		end
		
	end

	/*
	 * Always block that creats the 2.5 MHz clock to send to the ADC
	 *
	 * @rst[in]			Manual reset. When low, it pulls SCK low. When high, it 
	 *						allows the SCK to alternate between high and low states, 
	 *						depending on the value of the counter
	 *
	 * @SCK[out]		2.5 MHz 50% duty cycle clock that runs the ADC
	 *
	 * @counter[reg]	Counter that controls the state of SCK. When 0, it pulls
	 *						SCK high. When 10, it pulls SCK low.
	 */
	always @ (posedge clk or negedge rst) begin
	
		// If reset is low, do not run SCK
		if (rst == 1'b0) SCK <= 1'b0;
		
		// If the user pulls rst high, counter begins to modulate SCK
		else begin
		
			// Time high [0 10)
			if (counter == 6'd0) SCK <= 1'b1;
			
			// Time low [10 20)
			else if (counter == 6'd10) SCK <= 1'b0;
		
		end
   end
	
	/*
	 * Always block that creates a counter to step through the ADC timing 
	 * diagram. This code is based off the LTC2315 Serial Timing Interface
	 * Diagram with SCK continuous.
	 *
	 * @rst[in]			Manual reset. When low, it sets cnt18 to 0.
	 *
	 * @counter[reg]	Counter that creates cnt18, where every increment occurs
	 * 					on the falling edge of SCK, which coincides with
	 *						the counter value of 10
	 *
	 * @cnt18[reg]		Counter that keeps track of the steps in the ADC timing
	 *						diagram
	 */
	always @ (posedge clk or negedge rst) begin
	
		// If reset is low, do not begin ADC data transfer
		if (rst == 1'b0) cnt18 <= 5'd0; 
		
		// If counter is 10 (falling edge of SCK), increment cnt18 [0 18] to 
		// step through ADC timing diagram
		else if (counter == 6'd10 && cnt18 < 5'd18) cnt18 <= cnt18 + 5'd1;
		
		// If counter isn't 10 or cnt18 is 18, hold the value
		else cnt18 <= cnt18;
		
	end
	
////////////////////////////////////////////////////////////////////////////////
	/*
	 * Always block that collects data from the ADC
	 *
	 * @rst[in]			Manual reset. When low, it pulls CS high and sets sample
	 *						to all 0's
	 *
	 * @counter[reg]	Counter that allows data from SDO to be sampled in the
	 *						the middle of an SDO cycle, where the middle is a rising 
	 *						edge of SCK that coincides with the counter value of 0
	 *
	 * @cnt18[reg]
	 *
	 * @CS[out]			Chip select. When high, no data transfer will occur. When
	 *						low, data transfer may occur
	 *
	 * @sample[out]
	 */
	always @ (posedge clk or negedge rst) begin
		
		// If reset is low, initialize CS to high, and all 12-bits of sample to low
		if (rst == 1'b0) begin
			
			CS <= 1'b1; // CS MUST be pulled high before cnt18 increments from 0
			sample[11:0] <= 12'd0;
			collectLED <= 1'b0; // temp
		
		end
		
		// On the rising edge of SCK, begin stepping through the ADC serial
		// timing diagram
		else if (counter == 6'd0) begin
			
			// On the first rising edge of the ADC serial timing diagram, pull CS low
			// to begin data transfer
			if (cnt18 == 5'd0) CS <= 1'b0;
			
			// On the [2 13] rising edges of the ADC timing diagram, collect 12-bits 
			// from SDO. Note, we are looking at the middle of each bit sent on SDO
			else if (cnt18 > 5'd1 && cnt18 < 5'd14) begin
				
				// Shift SDO into the 12-bit sample so that it is MSB first
				sample[11:0] <= {sample[10:0],SDO};
				collectLED <= 1'b1; // temp
			
			end
			
			// On the [14 inf) rising edges of the ADC timing diagram, pull CS high
			// to signify the end of data transfer
			else if (cnt18 > 5'd13) CS = 1'b1;
			
			// On any missed (should be never) rising edges of the ADC timing diagram, 
			// do nothing but keep the 12-bit sample on the LEDs
			else sample <= sample;
			
		end
					
	end
	
endmodule
