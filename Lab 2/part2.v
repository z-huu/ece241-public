`timescale 1ns/1ns
module part2(LEDR, SW); //top level module that takes in board inputs / outputs and creates an instance of mux2to1

input [9:0] SW;
output [9:0] LEDR;

	mux2to1 instance1 (
	
		.x(SW[0]),
		.y(SW[1]),
		.s(SW[9]),
		.m(LEDR[0])
	
	);
	
endmodule 

//modules for 7400 chips code + mux2to1

module v7404 (pin1, pin3, pin5, pin9, pin11, pin13,
pin2, pin4, pin6, pin8, pin10, pin12);

	//hex inverter / NOT chip. pins according to Lab 1 pin diagram
	input pin1, pin3, pin5, pin9, pin11, pin13;
	output pin2, pin4, pin6, pin12, pin10, pin8;

	assign pin2 = ~pin1;
	assign pin4 = ~pin3;
	assign pin6 = ~pin5;
	assign pin12 = ~pin13;
	assign pin10 = ~pin11;
	assign pin8 = ~pin9;
	
	
	

endmodule

module v7408 (pin1, pin3, pin5, pin9, pin11, pin13,
pin2, pin4, pin6, pin8, pin10, pin12);
//and gate

	input pin1, pin2, pin4, pin5, pin13, pin12, pin10, pin9;
	output pin3, pin6, pin11, pin8;
	
	assign pin3 = pin1&&pin2;
	assign pin6 = pin4&&pin5;
	assign pin11 = pin13&&pin12;
	assign pin8 = pin10&&pin9;

	
	
endmodule

module v7432 (pin1, pin3, pin5, pin9, pin11, pin13,
pin2, pin4, pin6, pin8, pin10, pin12);
//or gate

	input pin1, pin2, pin4, pin5, pin13, pin12, pin10, pin9;
	output pin3, pin6, pin11, pin8;
	
	assign pin3 = pin1||pin2;
	assign pin6 = pin4||pin5;
	assign pin11 = pin13||pin12;
	assign pin8 = pin10||pin9;
	
endmodule


module mux2to1 (x,y,s,m);

	input x,y,s;
	output m;
	
	wire w1, w2, w3;
	//w1 connects s to NOT and into and chip
	//w2 connects AND chip output into last OR chip
	//w3 connects bottom AND chip output into OR chip input
	v7404 notChip(.pin1(s), .pin2(w1));
	v7408 andChip(.pin1(w1), .pin2(x), .pin3(w2), .pin4(s), .pin5(y), .pin6(w3));
	v7432 orChip(.pin1(w2), .pin2(w3), .pin3(m));
	

endmodule 