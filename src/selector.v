module Selector(
    input  [15:0] n,
    input  [3:0]  sel,
    output [3:0]  h
);
    assign h = ({4{sel[3]}} & n[15:12]) |
               ({4{sel[2]}} & n[11:8])  |
               ({4{sel[1]}} & n[7:4])   |
               ({4{sel[0]}} & n[3:0]);
endmodule
