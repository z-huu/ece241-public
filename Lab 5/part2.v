//part 2

/*
	module part2 (CLOCK_50, SW, HEX); //toplevelmodule
	
		input [9:0] SW;
		input CLOCK_50;
		output [6:0] HEX;
		
		wire [3:0] counterToHex;
		wire wEnable, Reset;
		wire [1:0] Speed;
		
		always @ (*)
			begin
				
				Reset <= SW[9];
				Speed <= SW[1:0];
				
		end
		
		RateDivider ahh (CLOCK_50, Reset, Speed, wEnable);
		DisplayCounter ugh (wEnable, CLOCK_50, SW[9], counterToHex);
		hex_decoder wow (.c(counterToHex), .display(HEX[0]));

	endmodule
*/

module part2 #(parameter CLOCK_FREQUENCY = 50000000) (ClockIn, Reset, Speed, CounterValue);

	input ClockIn, Reset;
	input [1:0] Speed;
	output [3:0] CounterValue;
	
	wire wEnable; //to connect RateDivider and DisplayCounter
	
	//probably some module instantiations here
	
	RateDivider #(CLOCK_FREQUENCY) bruh (ClockIn, Reset, Speed, wEnable);
	DisplayCounter dang (ClockIn, Reset, wEnable, CounterValue);

endmodule 


module RateDivider #(parameter CLOCK_FREQUENCY = 50000000) (ClockIn, Reset, Speed, Enable);
	input ClockIn, Reset;
	input [1:0] Speed;
	output reg Enable; 

	reg [27:0] upperBound;
	reg [27:0] counter;
	
	//upper bound of CLOCK FREQUENCY = 50000000
	
	always @ (*) //make these upperbounds dependent on CLOCK_FREQUENCY as it's something that can change
		begin
		
			case (Speed)
			2'b00: upperBound = 28'b0; 				//ticks once per clock period, aka 50MHz
			2'b01: upperBound = CLOCK_FREQUENCY-1; 	//49 999 999 once per second --> 1Hz
			2'b10: upperBound = (CLOCK_FREQUENCY*2)-1; //99 999 999 -> once per 2 seconds --> 0.5Hz
			2'b11: upperBound = (CLOCK_FREQUENCY*4)-1; //199 999 999 --> once per 4 seconds --> 0.25Hz
			endcase
		
			/* for simulations
			case (Speed)
			2'b00: upperBound = 28'b0;
			2'b01: upperBound = 28'b0 + 2;
			2'b10: upperBound = 28'b0 + 4;
			2'b11: upperBound = 28'b0 + 8;
			endcase
			*/
		end
		
	always @ (posedge ClockIn)
		begin
		
			if (Reset) counter <= upperBound;
			else if (counter == 28'b0) //IF OUR COUNTER HITS 0, WE GENERATE A POSITIVE ENABLE PULSE AAYEEE
				begin
					
					counter <= upperBound; //and then hit a reset
				
				end
			else
				begin
				
					
					counter <= counter - 1;
				
				end
		end
		
	always @ (*)
		begin
			
			if (counter == 28'b0) Enable = 1'b1;
			else Enable = 1'b0;
				
		
		end
	
endmodule 

module DisplayCounter (Clock, Reset, EnableDC, CounterValue);

	input Clock, Reset, EnableDC;
	output reg [3:0] CounterValue;
	
	always @ (posedge Clock)
		begin
		
			if (Reset == 1'b1) CounterValue <= 4'b0;
			else if (EnableDC == 1'b1) CounterValue <= CounterValue+1;
		
		end

endmodule 

module hex_decoder (c, display);

	input [3:0] c; //4 input bits
	output [6:0] display; //7 outputs
	
	//handle taking in inputs
	
	wire wire0, wire1, wire2, wire3, wire4, wire5, wire6, wire7, wire8, wire9, wireA, wireB, wireC, wireD, wireE, wireF;
	
	assign wire0 = ~c[3]&~c[2]&~c[1]&~c[0];//0000
	assign wire1 = ~c[3]&~c[2]&~c[1]&c[0]; //0001
	assign wire2 = ~c[3]&~c[2]&c[1]&~c[0]; //0010
	assign wire3 = ~c[3]&~c[2]&c[1]&c[0];  //0011    0
	assign wire4 = ~c[3]&c[2]&~c[1]&~c[0]; //0100    _ 
	assign wire5 = ~c[3]&c[2]&~c[1]&c[0];  //0101 5 | |  1
	assign wire6 = ~c[3]&c[2]&c[1]&~c[0];  //0110    - 6
	assign wire7 = ~c[3]&c[2]&c[1]&c[0];	//0111 4 | |  2
	assign wire8 = c[3]&~c[2]&~c[1]&~c[0]; //1000    -
	assign wire9 = c[3]&~c[2]&~c[1]&c[0];	//1001
	assign wireA = c[3]&~c[2]&c[1]&~c[0];	//1010    3
	assign wireB = c[3]&~c[2]&c[1]&c[0];	//1011
	assign wireC = c[3]&c[2]&~c[1]&~c[0];	//1100
	assign wireD = c[3]&c[2]&~c[1]&c[0];	//1101
	assign wireE = c[3]&c[2]&c[1]&~c[0];	//1110
	assign wireF = c[3]&c[2]&c[1]&c[0];		//1111
	
	assign display[0] = ~(wire0||wire2||wire3||wire5||wire6||wire7||wire8||wire9||wireA||wireC||wireE||wireF);
	assign display[1] = ~(wire0||wire1||wire2||wire3||wire4||wire7||wire8||wire9||wireA||wireD);
	assign display[2] = ~(wire0||wire1||wire3||wire4||wire5||wire6||wire7||wire8||wire9||wireA||wireB||wireD);
	assign display[3] = ~(wire0||wire2||wire3||wire5||wire6||wire8||wire9||wireB||wireC||wireD||wireE);
	assign display[4] = ~(wire0||wire2||wire6||wire8||wireA||wireB||wireC||wireD||wireE||wireF);
	assign display[5] = ~(wire0||wire4||wire5||wire6||wire8||wire9||wireA||wireB||wireC||wireE||wireF);
	assign display[6] = ~(wire2||wire3||wire4||wire5||wire6||wire8||wire9||wireA||wireB||wireD||wireE||wireF);
		//anodes display 0 values as positive

endmodule 