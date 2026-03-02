// TimeCounter: 8-bit loadable down counter built from two counter4L modules
module timeCounter(
    input            clk,
    input            DW,
    input            LD,
    input      [7:0] Din,
    output           DTC,
    output     [7:0] Q
);
    wire DTC_1, DTC_2;

    counter4L time1 (
        .clkin(clk),
        .UP(1'b0),
        .DW(DW),
        .LD(LD),
        .Din(Din[3:0]),
        .Q(Q[3:0]),
        .DTC(DTC_1)
    );

    counter4L time2 (
        .clkin(clk),
        .UP(1'b0),
        .DW(DW & DTC_1),
        .LD(LD),
        .Din(Din[7:4]),
        .Q(Q[7:4]),
        .DTC(DTC_2)
    );

    assign DTC = DTC_1 & DTC_2;
endmodule
