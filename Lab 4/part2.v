module part2(Clock, Reset_b, Data, Function, ALUout);

	input [3:0] Data;
	input [1:0] Function;
	input Clock, Reset_b;
	output reg [7:0] ALUout;

// implement ALU

	always @ (posedge Clock)
		begin
		
		if (Reset_b) ALUout <= 8'b0;
		
		else 
		
			case (Function)
			
				2'b00: ALUout <= {4'b0, Data} + {4'b0, ALUout[3:0]};
				2'b01: ALUout <= {4'b0, Data} * {4'b0, ALUout[3:0]};
				2'b10: ALUout <= {4'b0, ALUout[3:0]} << Data;
				2'b11: ALUout <= ALUout;
				default: ALUout <= 8'b0;
		
			endcase
			
		end
		
endmodule 

