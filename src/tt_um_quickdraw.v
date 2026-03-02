/*
 * Quick Draw Game - TinyTapeout Submission (Simplified)
 *
 * INPUTS (DIP switches on demo board):
 *   ui_in[0]  = Player A switch
 *   ui_in[1]  = Player B switch
 *   ui_in[2]  = GO switch (flip up to start round)
 *   ui_in[3]  = Cheat switch (both players fire simultaneously)
 *
 * OUTPUTS:
 *   uo_out[6:0] = 7-segment display (on-board demo board display)
 *                 Shows: A=Player A won, b=Player B won,
 *                        C=both win, L=both lose, blank=idle/running
 *   uo_out[7]   = decimal point (off)
 *
 * BIDIR (used as outputs):
 *   uio_out[0]  = Green light (high while countdown runs)
 *   uio_out[1]  = Player A wins this round
 *   uio_out[2]  = Player B wins this round
 *   uio_out[3]  = Both win this round
 *   uio_out[4]  = Both lose this round
 *   uio_out[5]  = Game over - Player A won the series
 *   uio_out[6]  = Game over - Player B won the series
 *   uio_out[7]  = unused
 *
 * Game rules:
 *   - First to 3 points wins the 5-round series
 *   - After series ends, reset with rst_n to play again
 */

`default_nettype none

module tt_um_quickdraw (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire rst = ~rst_n;
  // syncs 
    reg [1:0] sync_A, sync_B, sync_GO, sync_cheat;
    always @(posedge clk) begin
        sync_A <= {sync_A[0],     ui_in[0]};
        sync_B <= {sync_B[0],     ui_in[1]};
        sync_GO <= {sync_GO[0],    ui_in[2]};
        sync_cheat <= {sync_cheat[0], ui_in[3]};
    end
// list of inputs 
    wire sw_A     = sync_A[1];
    wire sw_B     = sync_B[1];
    wire sw_GO    = sync_GO[1];
    wire sw_cheat = sync_cheat[1];
    wire Anow     = sw_A | sw_cheat;
    wire Bnow     = sw_B | sw_cheat;

    //qsec stuff
    reg [23:0] qsec_cnt;
    reg        qsec;
    always @(posedge clk) begin
        if (rst) begin
            qsec_cnt <= 24'd0;
            qsec     <= 1'b0;
        end else if (qsec_cnt == 24'd12499999) begin
            qsec_cnt <= 24'd0;
            qsec     <= 1'b1;
        end else begin
            qsec_cnt <= qsec_cnt + 1'b1;
            qsec     <= 1'b0;
        end
    end

  // lsfr for random number generator and time touner witht he output of the lfsr module.
  
    wire [5:0] lfsr_out;
    LFSR_MOD lfsr_inst (.clk(clk), .rst(rst), .Q(lfsr_out));

    wire TimeUp, LoadTime, RunTime;
    wire [7:0] time_Q;
    TimeCounter my_time (
        .clk(clk),
        .DW(qsec & RunTime & ~TimeUp),
        .LD(LoadTime),
        .Din({2'b00, lfsr_out}),
        .DTC(TimeUp),
        .Q(time_Q)
    );

   // quick draw fsm 
    wire IncA, IncB;
    wire [6:0] fsm_Q;
    quickDrawChk fsm (
        .clk(clk),
        .rst(rst),
        .GO(sw_GO & ~game_over),  
        .TimeUp(TimeUp),
        .Anow(Anow),
        .Bnow(Bnow),
        .doneFlashDTC(1'b0),
        .LoadTime(LoadTime),
        .RunTime(RunTime),
        .IncA(IncA),
        .IncB(IncB),
        .ShowScore(),
        .FlashA(),
        .FlashB(),
        .Q(fsm_Q)
    );

    reg [2:0] ScoreA, ScoreB;

    wire scoreA_maxed = (ScoreA == 3'd3);
    wire scoreB_maxed = (ScoreB == 3'd3);
    wire game_over    = scoreA_maxed | scoreB_maxed;

    always @(posedge clk) begin
        if (rst) begin
            ScoreA <= 3'd0;
            ScoreB <= 3'd0;
        end else begin
            if (IncA & ~scoreA_maxed) ScoreA <= ScoreA + 3'd1;
            if (IncB & ~scoreB_maxed) ScoreB <= ScoreB + 3'd1;
        end
    end

   
    reg [6:0] seg;
    always @(*) begin
        if (fsm_Q[6])      seg = 7'b1110111; // A
        else if (fsm_Q[4]) seg = 7'b1111100; // b
        else if (fsm_Q[5]) seg = 7'b0111001; // C
        else if (fsm_Q[3]) seg = 7'b0111000; // L
        else               seg = 7'b0000000; // blank
    end

   // outputs 
    // 7-seg on uo_out 
    assign uo_out[6:0] = seg;
    assign uo_out[7]   = 1'b0; // decimal point off

    // Game status on uio (LEDs / external)
    assign uio_out[0] = RunTime;       // green light
    assign uio_out[1] = fsm_Q[6];     // A wins round
    assign uio_out[2] = fsm_Q[4];     // B wins round
    assign uio_out[3] = fsm_Q[5];     // both win round
    assign uio_out[4] = fsm_Q[3];     // both lose round
    assign uio_out[5] = scoreA_maxed; // A won series
    assign uio_out[6] = scoreB_maxed; // B won series
    assign uio_out[7] = 1'b0;
    assign uio_oe     = 8'hFF;

    wire _unused = ena | (|uio_in) | (|ui_in[7:4]);

endmodule
