module task_1
(
    input [3:0] SWITCH,
    output [4:0] LED
);

    assign LED [0] = ~ (SWITCH [0] & SWITCH [1]) | SWITCH [2] & ~ SWITCH [3] | SWITCH [0] & SWITCH [2] & SWITCH[3] | SWITCH[2] ;
    assign LED [1] = SWITCH [0];
    assign LED [2] = SWITCH [1];
    assign LED [3] = SWITCH [2];
    assign LED [4] = SWITCH [3];

endmodule
