module PCRegister (

    input clk, rst, write_en,
    input [15:0] D,
    output [15:0] Q

);

    dff ff0 ( .q(Q[0]), .d(D[0]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff1 ( .q(Q[1]), .d(D[1]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff2 ( .q(Q[2]), .d(D[2]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff3 ( .q(Q[3]), .d(D[3]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff4 ( .q(Q[4]), .d(D[4]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff5 ( .q(Q[5]), .d(D[5]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff6 ( .q(Q[6]), .d(D[6]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff7 ( .q(Q[7]), .d(D[7]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff8 ( .q(Q[8]), .d(D[8]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff9 ( .q(Q[9]), .d(D[9]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff10 ( .q(Q[10]), .d(D[10]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff11 ( .q(Q[11]), .d(D[11]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff12 ( .q(Q[12]), .d(D[12]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff13 ( .q(Q[13]), .d(D[13]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff14 ( .q(Q[14]), .d(D[14]), .wen(write_en), .clk(clk), .rst(rst) );
    dff ff15 ( .q(Q[15]), .d(D[15]), .wen(write_en), .clk(clk), .rst(rst) );

endmodule