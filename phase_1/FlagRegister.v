module FlagRegister (

    input clk, rst,
    input [2:0] enable,
    inout [2:0] flag_curr, flag_prev

);


    dff Z ( .q(flag_curr[0]), .d(flag_prev[0]), .wen(enable[0]), .clk(clk), .rst(rst));
    dff V ( .q(flag_curr[1]), .d(flag_prev[1]), .wen(enable[1]), .clk(clk), .rst(rst));
    dff N ( .q(flag_curr[2]), .d(flag_prev[2]), .wen(enable[2]), .clk(clk), .rst(rst));



endmodule