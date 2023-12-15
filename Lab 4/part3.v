//part 3 TO DO: SIMULATE AND TEST EDGE CASES. CHECK TEST CASES GIVEN BY ECE TEAM

module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);

	input clock, reset, ParallelLoadn, RotateRight, ASRight;
	input [3:0] Data_IN;
	output [3:0] Q; 
	
	
	wire w0, w1, w2, w3, arithw1, arithw2;
	assign Q[0] = w0;
	assign Q[1] = w1;
	assign Q[2] = w2;
	assign Q[3] = w3;
	
	mux2to1 heyy (.x(arithw1), .y(arithw2), .switch(ASRight), .m(w3));

	subcircuit hey0 (.right(Q[3]), .left(Q[1]), .LoadLeft(RotateRight), .D(Data_IN[0]), .loadn(ParallelLoadn), .Q(w0), .clk(clock), .reset(reset)); //corresponds to the very right register
	subcircuit hey1 (.right(Q[0]), .left(Q[2]), .LoadLeft(RotateRight), .D(Data_IN[1]), .loadn(ParallelLoadn), .Q(w1), .clk(clock), .reset(reset)); //corresponds to the 2nd register
	subcircuit hey2 (.right(Q[1]), .left(Q[3]), .LoadLeft(RotateRight), .D(Data_IN[2]), .loadn(ParallelLoadn), .Q(w2), .clk(clock), .reset(reset)); 
	subcircuit arith1 (.right(Q[2]), .left(Q[0]), .LoadLeft(RotateRight), .D(Data_IN[3]), .loadn(ParallelLoadn), .Q(arithw1), .clk(clock), .reset(reset));
	subcircuit arith2 (.right(Q[2]), .left(Q[3]), .LoadLeft(RotateRight), .D(Data_IN[3]), .loadn(ParallelLoadn), .Q(arithw2), .clk(clock), .reset(reset));
	
endmodule 

module subcircuit (right, left, LoadLeft, D, loadn, Q, clk, reset);

	input reset, right, left, D, clk, LoadLeft, loadn;
	output reg Q; 
	
	always @ (posedge clk)
		begin
		
			if (reset)

				Q <= 1'b0;
				
			else 
			
				if (!loadn) Q<=D;
				
				else
		
					if (LoadLeft) Q<= left;
					 
					else Q<=right;
				
		end
		
	always @ (negedge clk) begin
	
	
			if (reset) Q<= 1'b0;
			
		end 	

endmodule 

module mux2to1 (x, y, switch, m);

	input x, y, switch;
	output m;
	assign m = (~switch&x)|(switch&y);
	
endmodule 