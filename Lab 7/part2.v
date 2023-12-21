//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2 (iResetn, iPlotBox, iBlack, iColour, iLoadX, iXY_Coord, iClock, oX, oY, oColour, oPlot, oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-2)
   output wire 	   oPlot;       // Pixel drawing enable
   output wire       oDone;       // goes high when finished drawing frame
   
  // Your code goes here
  
	wire [4:0] counter; 
	wire [7:0] loopX;
	wire [6:0] loopY;
	
	//wires to connect datapath and control
	
	wire loadedX, loadedY, controlBlack, controlWrite;
	
	control u0(.done(oDone), .in_Reset(iResetn), .iLoadX(iLoadX), .plotBox(iPlotBox), 
				.clock(iClock), .clear(iBlack), .drawCount(counter), .loopX(loopX), 
				.loopY(loopY), .loadX(loadedX), .loadY(loadedY), .bGo(controlBlack), 
				.oPlot(oPlot), .writeGo(controlWrite));

	datapath u1(.clock(iClock), .in_Reset(iResetn), .writeGo(controlWrite), .bGo(controlBlack),  
					.loadedX(loadedX), .loadedY(loadedY), .out_X(oX), .out_Y(oY), .out_Colour(oColour),
					.in_Colour(iColour), .loopX(loopX), .loopY(loopY), .drawCount(counter), .iXY(iXY_Coord) );

	endmodule 


module control(

  input [7:0] loopX,
  input [6:0] loopY,
  input [4:0] drawCount,
    
  input iLoadX, clock, plotBox, clear, in_Reset,
  
  output reg writeGo, bGo, loadX, loadY, done, oPlot //, out_Colour
  
);

  reg [3:0] nState, cState;

  parameter  loading_x = 3'b000,
             waiting_x = 3'b001,
             loading_y = 3'b010,
             waiting_y = 3'b011,
             drawing   = 3'b100,
             blkScreen = 3'b101,
				 drawDone  = 3'b110,
				waiting_B = 3'b111;
				 
// State Transition Table baybeeeee

  always @ (*)
    begin
            case (cState)
             loading_x: begin
					
								if (iLoadX) nState = waiting_x;
								else nState = loading_x;
				 
								end
								
             waiting_x: begin
				 
								if (iLoadX) nState = waiting_x;
								else nState = loading_y;
				 
								end 
								
             loading_y: begin
				 
								if (plotBox) nState = waiting_y;
								else nState = loading_y;
				 
								end
								
             waiting_y: begin
				 
								if (plotBox) nState = waiting_y;
								else nState = drawing;
				 
								end 
								
             drawing: begin
				 
								if (drawCount == 5'b10000) nState = drawDone;
								//counter goes until hitting a value of 16 (4*4 square) 
								
								else nState = cState;
					  
							 end

		waiting_B: begin

			if (clear) nState = waiting_B; //if clear is held, we stay in this state.
			else nState = blkScreen; //once clear pulses low (let go of), we move to clearing screen state


			  end

              blkScreen: begin
				  
								//if the coordinate we draw at has reached the end of the screen (bottom right)
								 if ((loopX == 8'd159) && (loopY == 7'd119)) nState = drawDone;
								 else nState = cState;
					 
								 end
             
				  drawDone: begin
					
								nState = loading_x;
							
								end
								
				  default: nState = loading_x;
				  
        endcase
    end 

//State flip flops

    always @ (posedge clock)
    
	 begin
        if (!in_Reset) begin //active low synchronous reset
		  
            cState <= loading_x;
				done <= 1'b0;
				//cState <= waiting_x;
				
						 end
        else begin

		if (clear == 1'b1) cState <= waiting_B; //to wipe the screen
			else cState <= nState;
		
		if (cState == drawDone) done <= 1'b1; //high once we finish drawing, low once we iBlack or iPlotX
		else if (cState == loading_y) done <= 1'b0;
		else if (cState == blkScreen) done <= 1'b0;

		  end //else end
		  
	 end //begin end
	 
//Control Signals

    always @(*)
    begin
      
      writeGo = 1'b0; 
      bGo = 1'b0;
		loadX = 1'b0;
      loadY = 1'b0;
      //out_Colour = 1'b0;
		oPlot = 1'b0;

      case (cState)
            loading_x: begin
				
								 loadX = 1'b1;
								 loadY = 1'b0;
								 
					 
							  end
        
        		loading_y: begin
					
								loadX = 1'b0;
								loadY = 1'b1;
								

							  end
        
            drawing: begin

							 writeGo = 1'b1;
							 
							 oPlot = 1'b1;
							 
					 
							end
        
            blkScreen: begin
				
							 bGo = 1'b1;
							 
							 oPlot = 1'b1;
							 

								end
       endcase
		 
		end //end begin
	

endmodule
    
module datapath(

  input loadedX, loadedY, in_Reset, clock, writeGo, bGo,
  input [6:0] iXY,
  input [2:0] in_Colour,
  output reg [7:0] out_X, loopX,
  output reg [6:0] out_Y, loopY,
  output reg [2:0] out_Colour,
  output reg [4:0] drawCount
  
 );
 
  // Value registers
  reg [7:0] regX;
  reg [6:0] regY;
  reg [2:0] regColour;
 
  
  //Filling register values
  always @ (posedge clock) begin 
  
					 if (loadedX == 1'b1) regX <= {1'b0, iXY}; // to fill in unused MSB
					 if (loadedY == 1'b1) begin
					 
												regY <= iXY; 
												regColour <= in_Colour;
												
												 end
					 
					 //if (in_Colour == 1'b1) regColour <= in_Colour;  
        
									end

//output result
	always @ (posedge clock) begin
	

	
						if(!in_Reset) begin //reset to 0 on active low
						
							 loopX <= 8'b00000000;
							 loopY <= 7'b0000000;
							 out_X <= 8'b00000000;
							 out_Y <= 7'b0000000;
							 out_Colour <= 3'b000;           
							 drawCount <= 5'b00000;
			
										  end
										  
		
		
      else if (bGo)  begin  //clear the whole display to blkScreen

			out_Colour <= 3'b000;
		
        if ((loopX == 8'd159) && (loopY != 7'd119))  begin //reached the right side of monitor, increment row
			 
            loopX <= 7'b0000000; 
            loopY <= loopY + 1'b1; 
				
																	  end
			 
		   else begin 
			
					loopX <= loopX + 1'b1; //proceed within the row
			
				  end
				  
			out_X <= loopX;
			out_Y <= loopY;
			
							end //end bGo
		
		
    else if (writeGo) begin  // begin writeGo
	 
		if (drawCount < 5'b10000) begin //square is not finished yet
		
			  drawCount <= drawCount + 5'd00001;
			  out_X <= regX + drawCount[1:0];
			  out_Y <= regY + drawCount[3:2];
			  out_Colour <= regColour;
			  
									  end
				 
								end // end writeGo
  
	if(drawCount == 5'b10000) begin //square has been completed
	
						loopX <= 8'd0; //set everything back to normal values
					   loopY <= 7'd0;
					   drawCount <= 5'd0;
		  
								  end 
	 
	end //end always
	
endmodule 