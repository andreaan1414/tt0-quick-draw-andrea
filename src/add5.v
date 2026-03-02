module add5(
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] S,
    output       ovfl,
    output       Cout
);
    wire [3:0] Carry;
    FA my1 (.a(A[0]), .b(B[0]), .C_i(Cin),      .FA_sum(S[0]), .C_o(Carry[0]));
    FA my2 (.a(A[1]), .b(B[1]), .C_i(Carry[0]), .FA_sum(S[1]), .C_o(Carry[1]));
    FA my3 (.a(A[2]), .b(B[2]), .C_i(Carry[1]), .FA_sum(S[2]), .C_o(Carry[2]));
    FA my4 (.a(A[3]), .b(B[3]), .C_i(Carry[2]), .FA_sum(S[3]), .C_o(Carry[3]));
    assign ovfl = Carry[3] ^ Carry[2];
    assign Cout = Carry[3];
endmodule
