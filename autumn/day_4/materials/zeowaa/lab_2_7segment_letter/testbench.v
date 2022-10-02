`include "config.vh"

module testbench;

    reg [3:0] key;
    reg [7:0] sw;

    top i_top (.key (key), .sw (sw));

    initial
    begin
        #0
        $dumpvars;

        repeat (8) #10 { key, sw } <= $random;

        `ifdef MODEL_TECH  // Mentor ModelSim and Questa
            $stop;
        `else
            $finish;
        `endif
    end

endmodule
