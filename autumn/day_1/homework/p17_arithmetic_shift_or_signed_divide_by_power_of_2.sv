module arithmetic_right_shift_of_N_by_S_using_arithmetic_right_shift_operation
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output [N - 1:0] res);

  wire signed [N - 1:0] as = a;
  assign res = as >>> S;

endmodule

module arithmetic_right_shift_of_N_by_S_using_concatenation
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output [N - 1:0] res);

  // TODO
  wire [S - 1:0] prefix = a[N - 1] ? (3'b111) : (S * 1'b0);  // Как исправить ??
  assign res = { prefix, a[N - 1:S]};

endmodule

module arithmetic_right_shift_of_N_by_S_using_for_inside_always
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output logic [N - 1:0] res);

  // TODO
  always_comb
    for(int i = N - 1; i >= 0; i --)
      res [i] = (i > N - S - 1) ? a[N - 1] : a[i + S];

endmodule

module arithmetic_right_shift_of_N_by_S_using_for_inside_generate
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output [N - 1:0] res);
  
  // TODO
  genvar i;

  generate
    for(i = N - 1; i >= 0; i --)
      if (i > N - S - 1)
        assign res[i] = a[N - 1];
      else
        assign res[i] = a[i + S];
  endgenerate

endmodule

//----------------------------------------------------------------------------

module testbench;

  localparam N = 8, S = 3;

  logic signed [N - 1:0] a, res [0:3];

  arithmetic_right_shift_of_N_by_S_using_arithmetic_right_shift_operation
  # (.N (8), .S (3)) i4 (a, res [0]);

  arithmetic_right_shift_of_N_by_S_using_concatenation
  # (.N (8), .S (3)) i5 (a, res [1]);

  arithmetic_right_shift_of_N_by_S_using_for_inside_always
  # (.N (8), .S (3)) i6 (a, res [2]);

  arithmetic_right_shift_of_N_by_S_using_for_inside_generate
  # (.N (8), .S (3)) i7 (a, res [3]);

  initial
  begin
    repeat (20)
    begin
      a = $urandom ();
      # 1

      $write ("TEST %d %b", a, a);

      for (int i = 0; i < 4; i ++)
        $write (" %d %b", res [i], res [i]);

      $display;

      for (int i = 1; i < 4; i ++)
        if (res [i] !== res [0])
        begin
          $display ("%s FAIL. EXPECTED %d %b",
            `__FILE__, res [0], res [0]);

          $finish;
        end

        /*
        if (res [i] !== a / 2 ** S)
        begin
          $display ("%s FAIL. EXPECTED %d %b",
            `__FILE__, a / (8'sd2 ** S), a / (8'sd2 ** S));

          $finish;
        end
        */
    end

    $display ("%s PASS", `__FILE__);
    $finish;
  end

endmodule
