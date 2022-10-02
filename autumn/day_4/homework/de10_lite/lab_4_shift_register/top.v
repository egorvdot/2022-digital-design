`include "config.vh"

module top
(
    input           adc_clk_10,
    input           max10_clk1_50,
    input           max10_clk2_50,

    input   [ 1:0]  key,
    input   [ 9:0]  sw,
    output  [ 9:0]  led,

    output  [ 7:0]  hex0,
    output  [ 7:0]  hex1,
    output  [ 7:0]  hex2,
    output  [ 7:0]  hex3,
    output  [ 7:0]  hex4,
    output  [ 7:0]  hex5,

    output          vga_hs,
    output          vga_vs,
    output  [ 3:0]  vga_r,
    output  [ 3:0]  vga_g,
    output  [ 3:0]  vga_b,

    inout   [35:0]  gpio
);

    assign hex0 = 8'hff;
    assign hex1 = 8'hff;
    assign hex2 = 8'hff;
    assign hex3 = 8'hff;
    assign hex4 = 8'hff;

    wire clk   = max10_clk1_50;
    wire reset = sw [9];

    //------------------------------------------------------------------------

    reg [31:0] cnt;

    always @ (posedge clk or posedge reset)
      if (reset)
        cnt <= 32'b0;
      else
        cnt <= cnt + 32'b1;

    wire enable = (cnt [22:0] == 23'b0);

    //------------------------------------------------------------------------
//
//    assign hex5 = 8'hff;
//    wire button_on = ~ key [0];
//
//    reg [9:0] shift_reg;
//    
//    always @ (posedge clk or posedge reset)
//      if (reset)
//        shift_reg <= 10'b0;
//      else if (enable)
//        shift_reg <= { button_on, shift_reg [9:1] };
//
//    assign led = shift_reg;

    // Exercise 1: Make the light move in the opposite direction.

//    assign hex5 = 8'hff;
//    wire button_on = ~ key [0];
//
//    reg [9:0] shift_reg;
//
//    always @ (posedge clk or posedge reset)
//      if (reset)
//        shift_reg <= 10'b0;
//      else if (enable)
//        shift_reg <= { shift_reg [8:0], button_on };
//
//    assign led = shift_reg;

    // Exercise 2: Make the light moving in a loop.
    // Use another key to reset the moving lights back to no lights.

//    assign hex5 = 8'hff;
//    wire button_on = ~ key [0];
//    wire button_off = ~ key [1];
//
//    reg [9:0] shift_reg;
//
//    always @ (posedge clk or posedge reset)
//      if (reset)
//        shift_reg <= 10'b1;
//      else if (enable) begin
//		  if (button_on)
//		    shift_reg <= { shift_reg [8:0], shift_reg[9] };
//		  if (button_off)
//		    shift_reg <= 10'b0;
//		end
//
//    assign led = shift_reg;

    // Exercise 3: Display the state of the shift register
    // on a seven-segment display, moving the light in a circle.

    reg [7:0] shift_reg = 8'b11111110;

    always @ (posedge clk)
	   if (enable)
		  shift_reg <= { 2'b11, { shift_reg [4:0], shift_reg[5] } };
	 
    assign hex5 = shift_reg;

endmodule
