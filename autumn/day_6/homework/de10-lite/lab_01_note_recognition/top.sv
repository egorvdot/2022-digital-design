module top
# (
    parameter clk_mhz = 50
)
(
    input               MAX10_CLK1_50,
    input   [  1:0 ]    KEY,
    output  [  7:0 ]    HEX0,
    output  [  7:0 ]    HEX1,
    output  [  7:0 ]    HEX2,
    output  [  7:0 ]    HEX3,
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

    logic [15:0] prev_value;
    logic [19:0] counter;
    logic [19:0] distance;

    localparam [15:0] threshold = 16'h1100; // порог для фильтрации шума.

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
            else if (counter != ~ 20'h0)  // для избежания переполнения
            begin
               counter <= counter + 20'h1;
            end
        end


    //------------------------------------------------------------------------
    //
    //  Determining the note
    //
    //------------------------------------------------------------------------
    // Задание 1. Заполнить таблицу параметров в соответствии с частотами нот четвертой октавы в Гц.
    // Сейчас здесь правильная нота только C(До)=261.63 Гц и A(Ля)=440.00 Гц

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

    function [19:0] high_distance (input [18:0] freq_100);            // Пересчёт частоты ноты в число тактов 
                                                                      // основной частоты CLK 50MHZ +4% (50MHz/f)*(104/100)
       high_distance = clk_mhz * 1000 * 1000 / freq_100 * 104;
    endfunction

    //------------------------------------------------------------------------

    function [19:0] low_distance (input [18:0] freq_100);             // Пересчёт частоты ноты в число тактов 
                                                                      // основной частоты CLK 50MHZ -4% (50MHz/f)*(96/100)
       low_distance = clk_mhz * 1000 * 1000 / freq_100 * 96;
    endfunction

    //------------------------------------------------------------------------

    function [19:0] check_freq_single_range (input [18:0] freq_100);  // Проверяем входит ли число посчитанных тактов distance 
                                                                      // в диапазон тактов, который вычисляли выше

       check_freq_single_range =    distance > low_distance  (freq_100)
                                  & distance < high_distance (freq_100);
    endfunction

    //------------------------------------------------------------------------

    function [19:0] check_freq (input [18:0] freq_100);               // Проверяем ноту на следующие две верхних октавы, 
                                                                      // так как частота каждой октавы отличается ровно в 2 раза
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
    //  The output to seven segment display
    //
    //------------------------------------------------------------------------
//
//    always_ff @ (posedge clk or posedge reset)
//        if (reset)
//           HEX0 <= 8'b11111111;
//        else
//            case (t_note)
//                C  : HEX0 <= 8'b11000110;  // C   // hgfedcba
//                Cs : HEX0 <= 8'b01000110;  // C#
//                D  : HEX0 <= 8'b10100001;  // D   //   --a-- 
//                Ds : HEX0 <= 8'b00100001;  // D#  //  |     |
//                E  : HEX0 <= 8'b10000110;  // E   //  f     b
//                F  : HEX0 <= 8'b10001110;  // F   //  |     |
//                Fs : HEX0 <= 8'b00001110;  // F#  //   --g-- 
//                G  : HEX0 <= 8'b11000010;  // G   //  |     |
//                Gs : HEX0 <= 8'b01000010;  // G#  //  e     c
//                A  : HEX0 <= 8'b10001000;  // A   //  |     |
//                As : HEX0 <= 8'b00001000;  // A#  //   --d--  h
//                B  : HEX0 <= 8'b10000011;  // B
//                default : HEX0 <= 8'b11111111;
//            endcase
    
//------------------------------------------------------------------------
   // Задание 2. Вывести на семисегментные индикаторы буквы С О Л Ь, когда микрофон распознает ноту G
   // Сейчас здесь выводится "0" на все разряды

	  assign HEX3 = (t_note == G) ? 8'b11000110: 8'b11111111;
	  assign HEX2 = (t_note == G) ? 8'b11000000: 8'b11111111;
	  assign HEX1 = (t_note == G) ? 8'b11001000: 8'b11111111;
	  assign HEX0 = (t_note == G) ? 8'b10000011: 8'b11111111;

endmodule
