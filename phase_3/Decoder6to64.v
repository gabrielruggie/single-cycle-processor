module Decoder6to64 (

    input [5:0] data_in,
    output [63:0] wordline

);

    wire [2:0] match;
    wire [7:0] dec_out;
    reg [63:0] wordline_reg;

    // May need to change ints to hex nums
    assign match = (data_in < 8) ? 3'h0 : 
                    (data_in < 16) ? 3'h1 :
                    (data_in < 24) ? 3'h2 :
                    (data_in < 32) ? 3'h3 :
                    (data_in < 40) ? 3'h4 :
                    (data_in < 48) ? 3'h5 :
                    (data_in < 56) ? 3'h6 : 3'h7;

    Decoder3to8 dec38 ( .data_in(match), .wordline(dec_out) );

    // May not need wordline_reg
    // dec_out may need to be a reg
    always @(*) begin
        
        case (match)

            3'h0: assign wordline_reg[7:0] = dec_out;

            3'h1: assign wordline_reg[15:8] = dec_out;

            3'h2: assign wordline_reg[23:16] = dec_out;

            3'h3: assign wordline_reg[31:24] = dec_out;

            3'h4: assign wordline_reg[39:32] = dec_out;

            3'h5: assign wordline_reg[47:40] = dec_out;

            3'h6: assign wordline_reg[55:48] = dec_out;

            3'h7: assign wordline_reg[63:56] = dec_out;

        endcase

    end

    assign wordline = wordline_reg;

endmodule