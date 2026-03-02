module counter4L(
    input            clkin,
    input            UP,
    input            DW,
    input            LD,
    input      [3:0] Din,
    output reg [3:0] Q = 4'b0000,
    output           UTC,  // all ones
    output           DTC   // all zeros
);
    wire       ovfl;
    wire [3:0] addsub_result;
    wire [3:0] mux2_o;
    wire       enable_count;

    assign UTC          = Q[3] & Q[2] & Q[1] & Q[0];
    assign DTC          = ~Q[3] & ~Q[2] & ~Q[1] & ~Q[0];
    assign enable_count = (UP ^ DW) | LD;

    AddSub5 my_addOrSub (
        .A(Q),
        .B(4'b0001),
        .sub(DW & ~UP),
        .S(addsub_result),
        .ovfl(ovfl)
    );

    mux2to1 my_mux2 (
        .s(LD),
        .i0(addsub_result),
        .i1(Din),
        .y(mux2_o)
    );

    always @(posedge clkin) begin
        if (enable_count)
            Q <= mux2_o;
    end
endmodule
