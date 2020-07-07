//FPGA SPI Master Test Code in ModelSim
// Transmit 1 byte of defined data on 250kHz SCL
//CPOL: 0 (SCL starts low) CPHA: 1 (Sample MOSI on falling edge SCL)

module MySPI (clk, rst, SCL, SS, MOSI);
input clk; //On board 50MHz clk
input rst; //Manual switch
output reg SCL; //Clk line to sync data transfer
output reg SS; //Slave select line
output reg MOSI; //Master out slave in

//SCL Generation and "Tracking"
//Note: MOSI line needs to change to correct state for first bit, THEN SCL starts pulsing
reg[25:0] countSCL;
reg[25:0] SCLtracker;
always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		SCL <= 1'b0;
		countSCL <= 26'd0;
		SCLtracker <= 26'd0;
	end
	else
	begin
		if (countSCL >= 26'd99) //yeilds 250kHz clk --> (50M/250k)/2
			countSCL <= 26'd0;
		else
			countSCL <= countSCL + 26'd1;
		if (countSCL == 26'd0) //implement a delay for MOSI to change
		begin
			SCLtracker <= SCLtracker + 26'd1; //SCL == +2 for each period
			if (SCLtracker >= 26'd2 && SCLtracker <= 26'd17) //1 period delay for SS to start and MOSI to intialize
				SCL <= ~SCL;
			else
				SCL <= 1'b0;
		end
	end
		
end

//Define SS line
always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		SS <= 1'b1;
	else
	begin
		if (SCLtracker == 26'd1) //1st SCL clock cycle
			SS <= 1'b0;
		else if (SCLtracker == 26'd18) //After MOSI done transmitting
			SS <= 1'b1;
	end
end

//Define MOSI line
reg[7:0] txData = 8'b10101011; //test data
always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		MOSI <= 1'b0;
	else
	begin
		case(SCLtracker)
			0: begin MOSI <= 1'b0; end //Waiting for SS to go low
			1: begin MOSI <= 1'b0; end //Waiting for SS to go low
			2: begin MOSI <= txData[7]; end
			3: begin MOSI <= txData[7]; end
			4: begin MOSI <= txData[6]; end
			5: begin MOSI <= txData[6]; end
			6: begin MOSI <= txData[5]; end
			7: begin MOSI <= txData[5]; end
			8: begin MOSI <= txData[4]; end
			9: begin MOSI <= txData[4]; end
			10: begin MOSI <= txData[3]; end
			11: begin MOSI <= txData[3]; end
			12: begin MOSI <= txData[2]; end
			13: begin MOSI <= txData[2]; end
			14: begin MOSI <= txData[1]; end
			15: begin MOSI <= txData[1]; end
			16: begin MOSI <= txData[0]; end
			17: begin MOSI <= txData[0]; end
			default: MOSI <= 1'b0;
		endcase
	end
end

endmodule
