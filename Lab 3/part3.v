module part3 (A, B, Function, ALUout);

	parameter N = 4;
	input [1:0] Function;
	input [N-1:0] A, B;
	output reg [2*N-1:0] ALUout;
	//there are no c_in or c_out

	wire [N-1:0] cout, s; //to replace variables missing from the input
		
	
	always @ (*)
		begin
		
			case (Function)
			//first function is adding A & B
				2'b00: ALUout = A+B; 
			//second function is using the OR operator to check for 1s in the input. 
				2'b01: ALUout = |{A, B};
			//third function is using the AND operator to check if all inputs are 1.
				2'b10: ALUout = &{A, B};
				2'b11: ALUout = {A, B};
				default: ALUout = {2*N{1'b0}};
			endcase
		
		end

endmodule 
