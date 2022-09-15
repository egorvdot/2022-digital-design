module lab_1
(
    input [1:0] KEY,
    output [9:0] LED
);
    wire a = ~ KEY [0];
    wire b = ~ KEY [1];

    assign LED [0] = a & b;
    assign LED [1] = a | b;
    assign LED [2] = ~ a;
    assign LED [3] = a ^ b;
    assign LED [4] =  (a | b) & ~ (a & b);
    assign LED [5] = a ^ 1'b1;
    assign LED [6] = ~ ( a & b );
    assign LED [7] = ~ a | ~ b;
    assign LED [8] = ~ ( a | b );
    assign LED [9] = ~ a & ~ b;

endmodule
