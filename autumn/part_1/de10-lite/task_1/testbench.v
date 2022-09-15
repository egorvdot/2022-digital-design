`timescale 1ns / 1ps
module testbench;
    reg [3:0] switch;
    wire [4:0] led;

    task_1 dut ( switch, led );
    initial
        begin
            switch = 4'b0000;
            #10;
            switch = 4'b0001;
            #10;
            switch = 4'b0010;
            #10;
            switch = 4'b0011;
            #10;
            switch = 4'b0100;
            #10;
            switch = 4'b0101;
            #10;
            switch = 4'b0110;
            #10;
            switch = 4'b0111;
            #10;
            switch = 4'b1000;
            #10;
            switch = 4'b1001;
            #10;
            switch = 4'b1010;
            #10;
            switch = 4'b1011;
            #10;
            switch = 4'b1100;
            #10;
            switch = 4'b1101;
            #10;
            switch = 4'b1110;
            #10;
            switch = 4'b1111;
            #10;
        end
    initial
        $monitor("switch=%b led=%b", switch, led);
    initial
        $dumpvars;
endmodule