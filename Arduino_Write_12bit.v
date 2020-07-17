//////////////////////////////////////////////////////
//
// Date: 				7/16/2020
//
// Contributors: 		Lucy Rukstales, Michaela Mitchell
//
// Main Module:		ADC_Control.v
//
// Description: 		This file allows for 12 bits of data to be sent to the Arduino
//							CPOL: 0 (SCL starts low) CPHA: 1 (Sample MOSI on falling edge SCL)
//
//////////////////////////////////////////////////////

module Arduino_Write_12bit(clk,rst,sample,SCL,SS,MOSI,SCLtracker);

	input clk; //On board 50MHz clk
	input rst; //Manual switch
	
	input [11:0]sample;
	
	output reg SCL;  //Clk line to sync data transfer
	output reg SS;   //Child select line
	output reg MOSI; //Parent out child in

	output reg [5:0]SCLtracker;
	
	reg [7:0]countSCL; // 100kHz clk
	
	//----------------------------------------------------	
	always @ (posedge clk or negedge rst) begin
	
		if (rst == 1'b0) begin
		
			countSCL <= 8'd0;
			SCLtracker <= 6'd0;
			SCL <= 1'b0;
			
		end
		
		else begin
		
			if (countSCL >= 8'd249) countSCL <= 8'd0;
			
			else countSCL <= countSCL + 8'd1;
			
			if (countSCL == 8'd0) begin //implement a delay for MOSI to change
			
				SCLtracker <= SCLtracker + 6'd1; //SCL == +2 for each period
				
				if ((SCLtracker >= 6'd2 && SCLtracker <= 6'd17) || (SCLtracker >= 6'd20 && SCLtracker <= 6'd35)) SCL <= ~SCL;//1 period delay for SS to start and MOSI to intialize
					
				else SCL <= 1'b0;
				
			end
			
		end
			
	end

	//----------------------------------------------------	
	always @ (posedge clk or negedge rst) begin
	
		if (rst == 1'b0) begin	
		
			SS <= 1'b1;
			MOSI <= 1'b0;
			
		end
		
		else if (countSCL == 8'd0) begin
		
			case(SCLtracker)
			
				1: begin 
						MOSI <= 1'b0; 
						SS <= 1'b0; 
					end //Bring SS low
				//MSByte
				
				2: MOSI <= 1'b0; // dummy data, send 12 bits in 2 bytes, zero pad the front
				
				3: MOSI <= 1'b0; //
				
				4: MOSI <= 1'b0; //
				
				5: MOSI <= 1'b0; //
				
				6: MOSI <= 1'b0; //
				
				7: MOSI <= 1'b0; //
				
				8: MOSI <= 1'b0; //
				
				9: MOSI <= 1'b0; //
				
				10: MOSI <= sample[11];
				
				11: MOSI <= sample[11];
				
				12: MOSI <= sample[10];
				
				13: MOSI <= sample[10];
				
				14: MOSI <= sample[9];
				
				15: MOSI <= sample[9];
				
				16: MOSI <= sample[8];
				
				17: MOSI <= sample[8];
				
				18: begin
						MOSI <= 1'b0; 
						SS <= 1'b1; 
					end //Pause data transfer
					
				19: begin 
						MOSI <= 1'b0; 
						SS <= 1'b0; 
					end //Waiting for SS to go low
					
				//LSByte
				20: MOSI <= sample[7];
				
				21: MOSI <= sample[7];
				
				22: MOSI <= sample[6];
				
				23: MOSI <= sample[6];
				
				24: MOSI <= sample[5];
				
				25: MOSI <= sample[5];
				
				26: MOSI <= sample[4];
				
				27: MOSI <= sample[4];
				
				28: MOSI <= sample[3];
				
				29: MOSI <= sample[3];
				
				30: MOSI <= sample[2];
				
				31: MOSI <= sample[2];
				
				32: MOSI <= sample[1];
				
				33: MOSI <= sample[1];
				
				34: MOSI <= sample[0];
				
				35: MOSI <= sample[0];
				
				36: begin 
						MOSI <= 1'b0; 
						SS <= 1'b1; 
					end //End data transfer
					
				default: MOSI <= 1'b0;
				
			endcase
			
		end
		
	end

endmodule
