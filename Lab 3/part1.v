module part1(a, b, c_in, s, c_out);

//a and b are 4bit inputs
//s is 4bit sum output
//c out is the 4 bit vector of the
//four carry out sums of each FA

	input [3:0] a, b;
	input c_in;
	output [3:0] s, c_out;

	//create four instances of fulladderrrsssssssssssss
	fulladder adder1(a[0], b[0], c_in, s[0], c_out[0]);
	fulladder adder2(a[1], b[1], c_out[0], s[1], c_out[1]);
	fulladder adder3(a[2], b[2], c_out[1], s[2], c_out[2]);
	fulladder adder4(a[3], b[3], c_out[2], s[3], c_out[3]);
	// carry out bit from each instance is being passed to the next
endmodule 


module fulladder (a, b, cin, s, cout);

	input a, b, cin;
	output s, cout;
	
	assign s = a^b^cin; //a XOR b XOR cin
	assign cout = (a&b)|(cin&b)|(cin&a); //expression from lecture notes

endmodule 