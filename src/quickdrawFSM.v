module quickdrawFSM(
    input            clk,
    input            rst,
    input            GO,
    input            TimeUp,
    input            Anow,
    input            Bnow,
    input            doneFlashDTC,  // unused, kept for port compatibility

    output           LoadTime,
    output           RunTime,
    output           IncA,
    output           IncB,
    output           ShowScore,
    output           FlashA,   
    output           FlashB,   // tied low
    output reg [6:0] Q
);
    reg [6:0] D;

    // Next-state logic
    always @(*) begin
        D[0] = (Q[0] & (~GO | Anow | Bnow))
             | (Q[5] & ~Anow & ~Bnow)
             | (Q[3] & ~Anow & ~Bnow)
             | (Q[4] & ~Anow & ~Bnow)
             | (Q[6] & ~Anow & ~Bnow);

        D[1] = (Q[0] & GO & ~Anow & ~Bnow)
             | (Q[1] & ~TimeUp & ~Anow & ~Bnow);

        D[2] = (Q[1] & TimeUp & ~Anow & ~Bnow)
             | (Q[2] & ~Anow & ~Bnow);

        D[3] = (Q[1] & Anow & Bnow & ~TimeUp)
             | (Q[3] & (Anow | Bnow));

        D[4] = (Q[2] & ~Anow & Bnow)
             | (Q[1] & Anow & ~Bnow & ~TimeUp)
             | (Q[4] & (Anow | Bnow));

        D[5] = (Q[2] & Anow & Bnow)
             | (Q[5] & (Anow | Bnow));

        D[6] = (Q[2] & Anow & ~Bnow)
             | (Q[1] & ~Anow & Bnow & ~TimeUp)
             | (Q[6] & (Anow | Bnow));
    end

    // State register
    always @(posedge clk) begin
        if (rst) Q <= 7'b0000001;
        else     Q <= D;
    end

    // Outputs
    assign LoadTime  = Q[0] & GO & ~Anow & ~Bnow;
    assign RunTime   = Q[1] & ~TimeUp;
    assign ShowScore = Q[0] | Q[4] | Q[5] | Q[6];
    assign IncA      = (Q[2] & Anow & ~Bnow)
                     | (Q[1] & ~Anow & Bnow)
                     | (Q[2] & Anow & Bnow);
    assign IncB      = (Q[1] & Anow & ~Bnow)
                     | (Q[2] & Anow & Bnow)
                     | (Q[2] & ~Anow & Bnow);
    assign FlashA    = 1'b0;
    assign FlashB    = 1'b0;

endmodule
