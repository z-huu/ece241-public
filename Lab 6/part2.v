//part 2
module part2(Clock, Reset, Go, DataIn, DataResult, ResultValid);
    input Clock;
    input Reset;
    input Go;
    input [7:0] DataIn;
    output [7:0] DataResult;
    output ResultValid;

    // lots of wires to connect our datapath and control
    wire ld_a, ld_b, ld_c, ld_x, ld_r;
    wire ld_alu_out;
    wire [1:0]  alu_select_a, alu_select_b;
    wire alu_op;

    control C0(
        .clk(Clock),
        .resetn(Reset),
        
        .go(Go),
        
        .ld_alu_out(ld_alu_out), 
        .ld_x(ld_x),
        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c), 
        .ld_r(ld_r), 
        
        .alu_select_a(alu_select_a),
        .alu_select_b(alu_select_b),
        .alu_op(alu_op),
		  .result_valid(ResultValid)
    );

    datapath D0(
        .clk(Clock),
        .resetn(Reset),

        .ld_alu_out(ld_alu_out), 
        .ld_x(ld_x),
        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c), 
        .ld_r(ld_r), 

        .alu_select_a(alu_select_a),
        .alu_select_b(alu_select_b),
        .alu_op(alu_op),

        .data_in(DataIn),
        .data_result(DataResult)
    );
                
 endmodule        

module control (input clk, resetn, go, output reg  ld_a, ld_b, ld_c, ld_x, 
					ld_r, ld_alu_out, output reg [1:0]  alu_select_a, alu_select_b,
					output reg alu_op, output reg result_valid);

				reg [5:0] current_state, next_state; 
				localparam  S_LOAD_A 		 = 5'd0,
								S_LOAD_A_WAIT   = 5'd1,
								S_LOAD_B        = 5'd2,
								S_LOAD_B_WAIT   = 5'd3,
								S_LOAD_C        = 5'd4,
								S_LOAD_C_WAIT   = 5'd5,
								S_LOAD_X        = 5'd6,
								S_LOAD_X_WAIT   = 5'd7,
								S_CYCLE_0       = 5'd8,
								S_CYCLE_1       = 5'd9,
								S_CYCLE_2       = 5'd10,
								S_CYCLE_3       = 5'd11;
				// state table
				
				always @(*)
				begin

				case (current_state)
					// loop in current state until value is input
					S_LOAD_A: next_state = go ? S_LOAD_A_WAIT : S_LOAD_A;
					// loop in current state until go signal goes low
					S_LOAD_A_WAIT: next_state = go ? S_LOAD_A_WAIT : S_LOAD_B;
					// loop in current state until value is input
					S_LOAD_B: next_state = go ? S_LOAD_B_WAIT : S_LOAD_B; 
					// loop in current state until go signal goes low
					S_LOAD_B_WAIT: next_state = go ? S_LOAD_B_WAIT : S_LOAD_C;
					// loop in current state until value is input
					S_LOAD_C: next_state = go ? S_LOAD_C_WAIT : S_LOAD_C; 
					// loop in current state until go signal goes low
					S_LOAD_C_WAIT: next_state = go ? S_LOAD_C_WAIT : S_LOAD_X;
					// loop in current state until value is input
					S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; 
					// loop in current state until go signal goes low
					S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_CYCLE_0; 
					S_CYCLE_0: next_state = S_CYCLE_1;
					S_CYCLE_1: next_state = S_CYCLE_2;
					S_CYCLE_2: next_state = S_CYCLE_3;
					// start over after
					S_CYCLE_3: next_state = S_LOAD_A; 
					default: next_state = S_LOAD_A;
				endcase

				end // state_table
   

				// output logic for datapath control signals
				always @(*)
				begin
				// all signals are 0 by default, to avoid latches.

					ld_alu_out = 1'b0;
					ld_a = 1'b0;
					ld_b = 1'b0;
					ld_c = 1'b0;
					ld_x = 1'b0;
					ld_r = 1'b0;
					alu_select_a = 2'b0;
					alu_select_b = 2'b0;
					alu_op       = 1'b0;

					case (current_state)
						S_LOAD_A: begin
										ld_a = 1'b1;
									 end
						S_LOAD_B: begin
										ld_b = 1'b1;
									 end
						S_LOAD_C: begin
										ld_c = 1'b1;
									 end
						S_LOAD_X: begin
										ld_x = 1'b1;
									 end
						S_CYCLE_0: begin // do B <- B * x 
										ld_alu_out = 1'b1; ld_b = 1'b1; // store result back into B
										alu_select_a = 2'd1; // select register B
										alu_select_b = 2'd3; // also select register x
										alu_op = 1'b1; // do multiply operation
									  end
						S_CYCLE_1: begin // do A <- A + B
										ld_alu_out = 1'b1; ld_a = 1'b1; // store result back into A
										alu_select_a = 2'd0; // select register A
										alu_select_b = 2'd1; // also select register B
										alu_op = 1'b0; // do addition operation
									  end
						S_CYCLE_2: begin // do A <- A * x
										ld_alu_out = 1'b1; ld_a = 1'b1; // store result back into A
										alu_select_a = 2'd0; // select register A
										alu_select_b = 2'd3; // also select register x
										alu_op = 1'b1; // do multiply operation
									  end
						S_CYCLE_3: begin // do A + C
										ld_r = 1'b1; // store result in result register
										alu_select_a = 2'd0; // select register A
										alu_select_b = 2'd2; // select register C
										alu_op = 1'b0; // do addition operation
										result_valid <= 1;
									  end
						// no default needed; all of our outputs were assigned a value
					endcase		 
				
				end // enable_signals

				// current_state registers
				always @(posedge clk)
				begin
					if(!resetn)
						current_state <= S_LOAD_A;
					else
						current_state <= next_state;
				end // state_FFS
				
endmodule // control



module datapath( //same from given part 2 template code
    input clk,
    input resetn,
    input [7:0] data_in,
    input ld_alu_out,
    input ld_x, ld_a, ld_b, ld_c,
    input ld_r,
    input alu_op,
    input [1:0] alu_select_a, alu_select_b,
    output reg [7:0] data_result
    );

    // input registers
    reg [7:0] a, b, c, x;

    // output of the alu
    reg [7:0] alu_out;
    // alu input muxes
    reg [7:0] alu_a, alu_b;

    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            a <= 8'b0;
            b <= 8'b0;
            c <= 8'b0;
            x <= 8'b0;
        end
        else begin
            if(ld_a)
                a <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_b)
                b <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_x)
                x <= data_in;

            if(ld_c)
                c <= data_in;
        end
    end

    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            data_result <= 8'b0;
        end
        else
            if(ld_r)
                data_result <= alu_out;
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            2'd0:
                alu_a = a;
            2'd1:
                alu_a = b;
            2'd2:
                alu_a = c;
            2'd3:
                alu_a = x;
            default: alu_a = 8'b0;
        endcase

        case (alu_select_b)
            2'd0:
                alu_b = a;
            2'd1:
                alu_b = b;
            2'd2:
                alu_b = c;
            2'd3:
                alu_b = x;
            default: alu_b = 8'b0;
        endcase
    end

    // The ALU
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            1: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
            default: alu_out = 8'b0;
        endcase
    end

endmodule 