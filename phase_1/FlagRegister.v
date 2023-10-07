module FlagRegister (

    input clk, rst, enable,
    input [2:0] flag_prev,
    output [2:0] flag_curr,

);


    dff Z ( .q(flag_curr[0]), .d(flag_prev[0]), .wen(enable), .clk(clk), .rst(!rst_n));
    dff V ( .q(flag_curr[1]), .d(flag_prev[1]), .wen(enable), .clk(clk), .rst(!rst_n));
    dff N ( .q(flag_curr[2]), .d(flag_prev[2]), .wen(enable), .clk(clk), .rst(!rst_n));



endmodule