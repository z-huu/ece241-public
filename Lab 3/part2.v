`timescale 1ns/1ns
/*
module part2 (KEY, SW, LEDR, HEX0, HEX2, HEX3, HEX4); 

	input [7:0] SW; 
	output [6:0] HEX0, HEX2, HEX3, HEX4;
	input [1:0] KEY;
	output [7:0] LEDR;
		
	//assignments according to lab handout
	ALU U0 (.A(SW[7:4]), .B(SW[3:0]), .Function(KEY[1:0]), .ALUout(LEDR[7:0]));
	hex_decoder decoder1(.c(SW[3:0]), .display(HEX0));
	hex_decoder decoder2(.c(SW[7:4]), .display(HEX2));
	hex_decoder decoder3(.c(LEDR[3:0]), .display(HEX3));
	hex_decoder decoder4(.c(LEDR[7:4]), .display(HEX4));
	
endmodule 
*/
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

module part2(A, B, Function, ALUout);

	input [1:0] Function;
	input [3:0] A, B;
	output reg [7:0] ALUout;
	//there are no c_in or c_out
	
	
	wire [3:0] s, cout; //to replace variables missing from the input
	
	
	part1 adder(A, B, 1'b0, s, cout);


	always @ (*)
		begin
		
			case (Function)
			//first function is using FA to add the two 4-bit inputs. modify the ALUout accordingly
				2'b00: ALUout = {3'b000, cout[3], s}; //curly brackets concatenate its contents!
			//second function is using the OR operator to check for 1s in the input. 
				2'b01: ALUout = |{A, B};
			//third function is using the AND operator to check if all inputs are 1.
				2'b10: ALUout = &{A, B};
				2'b11: ALUout = {A, B};
				default: ALUout = 8'b00000000;
			endcase
			
		end

endmodule 

module fulladder (a, b, cin, s, cout);

	input a, b, cin;
	output s, cout;
	
	assign s = a^b^cin; //a XOR b XOR cin
	assign cout = (a&b)|(cin&b)|(cin&a); //expression from lecture notes

endmodule 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
endmodule 

module part1(a, b, c_in, s, c_out);

	input [3:0] a, b;
	input c_in;
	output [3:0] s, c_out;

	fulladder adder1(a[0], b[0], c_in, s[0], c_out[0]);
	fulladder adder2(a[1], b[1], c_out[0], s[1], c_out[1]);

	fulladder adder3(a[2], b[2], c_out[1], s[2], c_out[2]);

	fulladder adder4(a[3], b[3], c_out[2], s[3], c_out[3]);


endmodule 
