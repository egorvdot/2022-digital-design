module top
# (
    parameter clk_mhz = 50
)
(
    input               MAX10_CLK1_50,
    input   [  1:0 ]    KEY,
    output  [  7:0 ]    HEX3,
    output  [  7:0 ]    HEX2,
    output  [  7:0 ]    HEX1,
    output  [  7:0 ]    HEX0,
    inout   [ 35:0 ]    GPIO
);

    // global signals
    wire clk   = MAX10_CLK1_50;
    wire reset = ~KEY[0];

    //------------------------------------------------------------------------
    //
    //  The microphone receiver
    //
    //------------------------------------------------------------------------

    // MIC3 connection table
    // PIN     GPIO     ALS   direction
    // ==== ========== ===== ===========
    //  29   VCC        VCC
    //  31   GPIO[26]   GND   output
    //  33   GPIO[28]   SCK   output
    //  35   GPIO[30]   MISO  input
    //  37   -          94V-0 -
    //  39   GPIO[34]   SS    output

    assign GPIO[26] = 1'b0;
    wire [15:0] value;

    digilent_pmod_mic3_spi_receiver i_microphone
    (
        .clk   ( clk      ),
        .reset ( reset    ),
        .cs    ( GPIO[34] ), 
        .sck   ( GPIO[28] ),
        .sdo   ( GPIO[30] ),
        .value ( value    )
    );

    //------------------------------------------------------------------------
    //
    //  Measuring frequency
    //
    //------------------------------------------------------------------------

    // It is enough for the counter to be 20 bit. Why?

    logic [15:0] prev_value;
    logic [19:0] counter;
    logic [19:0] distance;

    localparam [15:0] threshold = 16'h1100;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
        begin
            prev_value <= 16'h0;
            counter    <= 20'h0;
            distance   <= 20'h0;
        end
        else
        begin
            prev_value <= value;

            if (  value      >= threshold
                & prev_value < threshold)
            begin
               distance <= counter;
               counter  <= 20'h0;
            end
            else if (counter != ~ 20'h0)  // To prevent overflow
            begin
               counter <= counter + 20'h1;
            end
        end

    //------------------------------------------------------------------------
    //
    //  Determining the note
    //
    //------------------------------------------------------------------------



    // Custom measured frequencies

    localparam freq_100_C  = 26163,
               freq_100_Cs = 27718,
               freq_100_D  = 29366,
               freq_100_Ds = 31113,
               freq_100_E  = 32963,
               freq_100_F  = 34923,
               freq_100_Fs = 36999,
               freq_100_G  = 39200,
               freq_100_Gs = 41530,
               freq_100_A  = 44000,
               freq_100_As = 46616,
               freq_100_B  = 49388;


    //------------------------------------------------------------------------

    function [19:0] high_distance (input [18:0] freq_100);
       high_distance = clk_mhz * 1000 * 1000 / freq_100 * 104;
    endfunction

    //------------------------------------------------------------------------

    function [19:0] low_distance (input [18:0] freq_100);
       low_distance = clk_mhz * 1000 * 1000 / freq_100 * 96;
    endfunction

    //------------------------------------------------------------------------

    function [19:0] check_freq_single_range (input [18:0] freq_100);

       check_freq_single_range =    distance > low_distance  (freq_100)
                                  & distance < high_distance (freq_100);
    endfunction

    //------------------------------------------------------------------------

    function [19:0] check_freq (input [18:0] freq_100);

       check_freq =   check_freq_single_range (freq_100 * 4)
                    | check_freq_single_range (freq_100 * 2)
                    | check_freq_single_range (freq_100);

    endfunction

    //------------------------------------------------------------------------

    wire check_C  = check_freq (freq_100_C );
    wire check_Cs = check_freq (freq_100_Cs);
    wire check_D  = check_freq (freq_100_D );
    wire check_Ds = check_freq (freq_100_Ds);
    wire check_E  = check_freq (freq_100_E );
    wire check_F  = check_freq (freq_100_F );
    wire check_Fs = check_freq (freq_100_Fs);
    wire check_G  = check_freq (freq_100_G );
    wire check_Gs = check_freq (freq_100_Gs);
    wire check_A  = check_freq (freq_100_A );
    wire check_As = check_freq (freq_100_As);
    wire check_B  = check_freq (freq_100_B );

    //------------------------------------------------------------------------

    localparam w_note = 12;

    wire [w_note - 1:0] note = { check_C  , check_Cs , check_D  , check_Ds ,
                                 check_E  , check_F  , check_Fs , check_G  ,
                                 check_Gs , check_A  , check_As , check_B  };

    localparam [w_note - 1:0] no_note = 12'b0,

                              C  = 12'b1000_0000_0000,
                              Cs = 12'b0100_0000_0000,
                              D  = 12'b0010_0000_0000,
                              Ds = 12'b0001_0000_0000,
                              E  = 12'b0000_1000_0000,
                              F  = 12'b0000_0100_0000,
                              Fs = 12'b0000_0010_0000,
                              G  = 12'b0000_0001_0000,
                              Gs = 12'b0000_0000_1000,
                              A  = 12'b0000_0000_0100,
                              As = 12'b0000_0000_0010,
                              B  = 12'b0000_0000_0001;

    localparam [w_note - 1:0] Df = Cs, Ef = Ds, Gf = Fs, Af = Gs, Bf = As;

    //------------------------------------------------------------------------
    //
    //  Note filtering
    //
    //------------------------------------------------------------------------

    logic  [w_note - 1:0] d_note;  // Delayed note

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            d_note <= no_note;
        else
            d_note <= note;

    logic  [17:0] t_cnt;           // Threshold counter
    logic  [w_note - 1:0] t_note;  // Thresholded note

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            t_cnt <= 0;
        else
            if (note == d_note)
                t_cnt <= t_cnt + 1;
            else
                t_cnt <= 0;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            t_note <= no_note;
        else
            if (& t_cnt)
                t_note <= d_note;

    //------------------------------------------------------------------------
    //
    //  FSMs
    //
    //------------------------------------------------------------------------

    localparam w_state = 4;  // Let's keep to 16 states
    localparam n_fsms  = 3;

    localparam [3:0] recognized = 4'hf;

    logic [w_state - 1:0] states [0:n_fsms - 1];

    //------------------------------------------------------------------------

/*
 * Задание 1:
 * Изменить набор мелодий. Закодировать свою мелодию
 */

    // No 1. Simple sequence

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            states [2] <= 0;
        else
            case (states [2])
                0: if ( t_note == C  ) states [2] <=  1;
                1: if ( t_note == A  ) states [2] <=  2;
                2: if ( t_note == D  ) states [2] <=  3;
                3: if ( t_note == C  ) states [2] <=  4;
                4: if ( t_note == A  ) states [2] <=  recognized;            
            endcase
    // No 2. Fur Elize

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            states [0] <= 0;
        else
            case (states [0])
                0: if ( t_note == E  ) states [0] <=  1;
                1: if ( t_note == Ef ) states [0] <=  2;
                2: if ( t_note == E  ) states [0] <=  3;
                3: if ( t_note == Ef ) states [0] <=  4;
                4: if ( t_note == E  ) states [0] <=  5;
                5: if ( t_note == B  ) states [0] <=  6;
                6: if ( t_note == D  ) states [0] <=  7;
                7: if ( t_note == C  ) states [0] <=  8;
                8: if ( t_note == A  ) states [0] <=  recognized;
            endcase

    // No 3. Godfather

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            states [1] <= 0;
        else
            case (states [1])
             0: if ( t_note == G  ) states [1] <=  1;
             1: if ( t_note == C  ) states [1] <=  2;
             2: if ( t_note == Ef ) states [1] <=  3;
             3: if ( t_note == D  ) states [1] <=  4;
             4: if ( t_note == C  ) states [1] <=  5;
             5: if ( t_note == Ef ) states [1] <=  6;
             6: if ( t_note == C  ) states [1] <=  7;
             7: if ( t_note == D  ) states [1] <=  8;
             8: if ( t_note == C  ) states [1] <=  9;
             9: if ( t_note == Af ) states [1] <= 10;
            10: if ( t_note == Bf ) states [1] <= 11;
            11: if ( t_note == G  ) states [1] <= recognized;
            endcase

    //------------------------------------------------------------------------
    //
    //  The dynamic seven segment display logic
    //
    //------------------------------------------------------------------------

    logic [15:0] digit_enable_cnt;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            digit_enable_cnt <= 0;
        else
            digit_enable_cnt <= digit_enable_cnt + 1;

    wire digit_enable = & digit_enable_cnt;

    //------------------------------------------------------------------------
    //
    //  The output to seven segment display
    //
    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge reset)
        if (reset)
        begin
            HEX3 <= 8'b11111111;
            HEX2 <= 8'b11111111;
            HEX1 <= 8'b11111111;
            HEX0 <= 8'b11111111;
        end
        else if (digit_enable)
        begin
            case (t_note)
                C       : HEX3 <= 8'b11000110;  // C   // HEX0
                Cs      : HEX3 <= 8'b01000110;  // C#
                D       : HEX3 <= 8'b10100001;  // D   //   --a-- 
                Ds      : HEX3 <= 8'b00100001;  // D#  //  |     |
                E       : HEX3 <= 8'b10000110;  // E   //  f     b
                F       : HEX3 <= 8'b10001110;  // F   //  |     |
                Fs      : HEX3 <= 8'b00001110;  // F#  //   --g-- 
                G       : HEX3 <= 8'b11000010;  // G   //  |     |
                Gs      : HEX3 <= 8'b01000010;  // G#  //  e     c
                A       : HEX3 <= 8'b10001000;  // A   //  |     |
                As      : HEX3 <= 8'b00001000;  // A#  //   --d--  h
                B       : HEX3 <= 8'b10000011;  // B
                default : HEX3 <= 8'b11111111;
            endcase
            case (states [2])
                    4'h0: HEX2 <= 8'b11000000;
                    4'h1: HEX2 <= 8'b11111001;
                    4'h2: HEX2 <= 8'b10100100;
                    4'h3: HEX2 <= 8'b10110000;
                    4'h4: HEX2 <= 8'b10011001;
                    4'h5: HEX2 <= 8'b10010010;
                    4'h6: HEX2 <= 8'b10000010;
                    4'h7: HEX2 <= 8'b11111000;
                    4'h8: HEX2 <= 8'b10000000;
                    4'h9: HEX2 <= 8'b10011000;
                    4'ha: HEX2 <= 8'b10001000;
                    4'hb: HEX2 <= 8'b10000011;
                    4'hc: HEX2 <= 8'b11000110;
                    4'hd: HEX2 <= 8'b10100001;
                    4'he: HEX2 <= 8'b10000110;
                    // 4'hf: HEX2 <= 8'b10011100;  // F
                    4'hf: HEX2 <= 8'b10011100;  // Upper o - recognized
            endcase
            case (states [1])
                    4'h0: HEX1 <= 8'b11000000;
                    4'h1: HEX1 <= 8'b11111001;
                    4'h2: HEX1 <= 8'b10100100;
                    4'h3: HEX1 <= 8'b10110000;
                    4'h4: HEX1 <= 8'b10011001;
                    4'h5: HEX1 <= 8'b10010010;
                    4'h6: HEX1 <= 8'b10000010;
                    4'h7: HEX1 <= 8'b11111000;
                    4'h8: HEX1 <= 8'b10000000;
                    4'h9: HEX1 <= 8'b10011000;
                    4'ha: HEX1 <= 8'b10001000;
                    4'hb: HEX1 <= 8'b10000011;
                    4'hc: HEX1 <= 8'b11000110;
                    4'hd: HEX1 <= 8'b10100001;
                    4'he: HEX1 <= 8'b10000110;
                    // 4'hf: HEX1 <= 8'b10011100;  // F
                    4'hf: HEX1 <= 8'b10011100;  // Upper o - recognized
            endcase
            case (states [0])
                    4'h0: HEX0 <= 8'b11000000;
                    4'h1: HEX0 <= 8'b11111001;
                    4'h2: HEX0 <= 8'b10100100;
                    4'h3: HEX0 <= 8'b10110000;
                    4'h4: HEX0 <= 8'b10011001;
                    4'h5: HEX0 <= 8'b10010010;
                    4'h6: HEX0 <= 8'b10000010;
                    4'h7: HEX0 <= 8'b11111000;
                    4'h8: HEX0 <= 8'b10000000;
                    4'h9: HEX0 <= 8'b10011000;
                    4'ha: HEX0 <= 8'b10001000;
                    4'hb: HEX0 <= 8'b10000011;
                    4'hc: HEX0 <= 8'b11000110;
                    4'hd: HEX0 <= 8'b10100001;
                    4'he: HEX0 <= 8'b10000110;
                    // 4'hf: HEX0 <= 8'b10011100;  // F
                    4'hf: HEX0 <= 8'b10011100;  // Upper o - recognized
            endcase
        end

endmodule
