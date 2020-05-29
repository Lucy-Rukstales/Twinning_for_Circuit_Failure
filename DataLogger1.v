module DataLogger1(clk, rst, SCL, MOSI, MISO, SS);
	input rst; //reset switch
	input clk; //50MHz on board FPGA clock
	output reg SCL; //Master serial clock line
	output reg MOSI; //Master out slave in data line
	input MISO; //Master in slave out data line
	output reg SS; //Slave select line
	
	//Data to be sent from FPGA to Arduino (1 byte)
	wire[7:0] txData = 8'd0;
	
	//SCL Clock Generation
	reg[25:0] countSCL;
	always @ (posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			countSCL <= 26'd0;
			SCL <= 1'b0;
		end
		else
		begin
			if (countSCL >= 26'd2499) //10kHz
				countSCL <= 26'd0;
			else
				countSCL <= countSCL + 26'd1;
			if (countSCL == 26'd0) //Toggle SCL clock
				SCL <= ~SCL;
		end
	end
	
	//Count SCL for SPI timing
	reg[12:0] count;
	always @ (negedge SCL or negedge rst)
	begin
		if(rst == 1'b0)
			count <= 13'd0;
		else
			count <= count + 13'd1;
	end
	
	//Definitions for MOSI and SS line, 1 byte
	always @ (*)
	begin
		if (count == 13'd1)
		begin
			SS = 1'b1;
			MOSI = 1'b0;;
		end
		else if (count == 13'd2)
		begin
			SS = 1'b0;
			MOSI = txData[7];
		end
		else if (count == 13'd3)
		begin
			SS = 1'b0;
			MOSI = txData[6];
		end
		else if (count == 13'd4)
		begin
			SS = 1'b0;
			MOSI = txData[5];
		end
		else if (count == 13'd5)
		begin
			SS = 1'b0;
			MOSI = txData[4];
		end
		else if (count == 13'd6)
		begin
			SS = 1'b0;
			MOSI = txData[3];
		end
		else if (count == 13'd7)
		begin
			SS = 1'b0;
			MOSI = txData[2];
		end
		else if (count == 13'd8)
		begin
			SS = 1'b0;
			MOSI = txData[1];
		end
		else if (count == 13'd9)
		begin
			SS = 1'b0;
			MOSI = txData[0];
		end
	end
	
endmodule
	
	/*
		else if (count == 13'd10)
		begin
			SS = 1'b0;
			MOSI = address[6];
		end
		else if (count == 13'd11)
		begin
			SS = 1'b0;
			MOSI = address[5];
		end
		else if (count == 13'd12)
		begin
			SS = 1'b0;
			MOSI = address[4];
		end
		else if (count == 13'd13)
		begin
			SS = 1'b0;
			MOSI = address[3];
		end
		else if (count==13'd14)
		begin
			SS = 1'b0;
			MOSI = address[2];
		end
		else if (count == 13'd15)
		begin
			SS = 1'b0;
			MOSI = address[1];
		end
		else if (count == 13'd16)
		begin
			SS = 1'b0;
			MOSI = address[0];
		end
		*/
			
	
			
	
	
			
	