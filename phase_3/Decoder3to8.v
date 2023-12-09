module Decoder3to8 (

    input [2:0] data_in,
    output [7:0] wordline

);

    assign wordline[0] = (data_in == 3'h0) ? 1 : 0;
    assign wordline[1] = (data_in == 3'h1) ? 1 : 0;
    assign wordline[2] = (data_in == 3'h2) ? 1 : 0;
    assign wordline[3] = (data_in == 3'h3) ? 1 : 0;
    assign wordline[4] = (data_in == 3'h4) ? 1 : 0;
    assign wordline[5] = (data_in == 3'h5) ? 1 : 0;
    assign wordline[6] = (data_in == 3'h6) ? 1 : 0;
    assign wordline[7] = (data_in == 3'h7) ? 1 : 0;

endmodule