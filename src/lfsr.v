module LFSR_MOD(
    input            clk,
    input            rst,   // synchronous reset, active high
    output     [5:0] Q
);
    reg [7:0] rnd;
    wire      xor_fb;

    assign xor_fb = rnd[0] ^ rnd[5] ^ rnd[6] ^ rnd[7];
    assign Q       = rnd[5:0];

    always @(posedge clk) begin
        if (rst)
            rnd <= 8'b10000000; 
        else
            rnd <= {rnd[6:0], xor_fb};
    end
endmodule
