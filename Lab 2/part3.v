
module part3(HEX0, SW);

	input [3:0] SW;
	output [6:0] HEX0;

	hex_decoder instance1 (
	
		.c(SW),
		.display(HEX0)
	
	);

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