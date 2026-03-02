module addSub5(
    input  [3:0] A,
    input  [3:0] B,
    input        sub,
    output [3:0] S,
    output       ovfl
);
    wire       cout;
    wire [3:0] b_sub;
    assign b_sub = B ^ {4{sub}};
    add5 subi0 (.A(A), .B(b_sub), .Cin(sub), .Cout(cout), .S(S), .ovfl(ovfl));
endmodule
