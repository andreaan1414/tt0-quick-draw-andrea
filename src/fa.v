module FA(
    input a,
    input b,
    input C_i,
    output FA_sum,
    output C_o
);
    assign C_o = a & b | C_i & (a ^ b);
    assign FA_sum = (a ^ b) ^ C_i;
endmodule
