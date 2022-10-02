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
    assign hex5 = 8'hff;

    wire clk   = max10_clk1_50;
    wire reset = sw [9];

    // Exercise 1: Free running counter.
    // How do you change the speed of LED blinking?
    // Try different bit slices to display.

//    reg [31:0] cnt;
//    
//    always @ (posedge clk or posedge reset)
//      if (reset)
//        cnt <= 32'b0;
//      else
//        cnt <= cnt + 32'b1;
//        
//    assign led = cnt [30:21];

    // Exercise 2: Key-controlled counter.
    // Comment out the code above.
    // Uncomment and synthesize the code below.
    // Press the key to see the counter incrementing.
    //
    // Change the design, for example:
    //
    // 1. One key is used to increment, another to decrement.
    //
    // 2. Two counters controlled by different keys
    // displayed in different groups of LEDs.

    //*

    reg key_inc, key_dec;
    
    always @ (posedge clk or posedge reset)
      if (reset) begin
        key_inc <= 1'b0;
		  key_dec <= 1'b0;
      end else begin
        key_inc <= key [0];
        key_dec <= key [1];
		end
        
    wire key_inc_pressed = ~ key [0] & key_inc;
    wire key_dec_pressed = ~ key [1] & key_dec;

    reg [9:0] cnt;

    always @ (posedge clk or posedge reset)
      if (reset)
        cnt <= 10'b0;
      else begin
		  if (key_inc_pressed)
          cnt <= cnt + 10'b1;
		  if (key_dec_pressed)
		    cnt <= cnt - 10'b1;
		end
        
    assign led = cnt;

    //*/

endmodule
