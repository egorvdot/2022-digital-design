`include "config.vh"

module top
(
    input        clk,
    input        reset_n,
    
    input  [3:0] key_sw,
    output [3:0] led,

    output [7:0] abcdefgh,
    output [3:0] digit,

    output       buzzer,

    output       hsync,
    output       vsync,
    output [2:0] rgb
);

    wire reset = ~ reset_n;

    assign buzzer    = 1'b0;
    assign hsync     = 1'b1;
    assign vsync     = 1'b1;
    assign rgb       = 3'b0;
    
    //------------------------------------------------------------------------

    reg [31:0] cnt;
    
    always @ (posedge clk or posedge reset)
      if (reset)
        cnt <= 32'b0;
      else
        cnt <= cnt + 32'b1;
        
    wire enable = (cnt [22:0] == 23'b0);

    //------------------------------------------------------------------------


//    assign abcdefgh  = 8'hff;
//    assign digit     = 4'he;
//    wire button_on = ~ key_sw [0];
//
//    reg [3:0] shift_reg;
//    
//    always @ (posedge clk or posedge reset)
//      if (reset)
//        shift_reg <= 4'b0;
//      else if (enable)
//        shift_reg <= { button_on, shift_reg [3:1] };
//
//    assign led = ~ shift_reg;

    // Exercise 1: Make the light move in the opposite direction.
	 

//    assign abcdefgh  = 8'hff;
//    assign digit     = 4'hf;
//    wire button_on = ~ key_sw [0];
//
//    reg [3:0] shift_reg;
//    
//    always @ (posedge clk or posedge reset)
//      if (reset)
//        shift_reg <= 4'b0;
//      else if (enable)
//        shift_reg <= { shift_reg [2:0], button_on };
//
//    assign led = ~ shift_reg;

    // Exercise 2: Make the light moving in a loop.
    // Use another key to reset the moving lights back to no lights.

    assign abcdefgh  = 8'hff;
    assign digit     = 4'he;
    wire button_on = ~ key_sw [0];

    reg [3:0] shift_reg;
	 reg direction;

    always @ (posedge clk or posedge reset)
      if (reset) begin
        shift_reg <= 4'b1;
		  direction <= 1'b1;
      end else if (enable) begin
		  if (button_on)
		    direction = ~direction;
        if (direction)
		    shift_reg <=  { shift_reg [2:0], shift_reg [3] };
		  else
		    shift_reg <=  { shift_reg [0], shift_reg [3:1] };
		 end

    assign led = ~ shift_reg;

    // Exercise 3: Display the state of the shift register
    // on a seven-segment display, moving the light in a circle.
	 
//	 assign led = 4'b1111;
//	 assign digit = 4'b0111;
//    reg [7:0] shift_reg;
//    
//    always @ (posedge clk or posedge reset)
//      if (reset)
//        shift_reg <= 8'b01111111;
//      else if (enable)
//        shift_reg <= { { shift_reg [6:2], shift_reg [7] }, 2'b11 };
//	 
//	 assign abcdefgh = shift_reg;

endmodule
