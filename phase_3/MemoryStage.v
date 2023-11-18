module MemoryStage (

    input clk, rst,
    input b_m2m, mem_read_xm, mem_write_xm,
    input [15:0] writeback_data, reg2_xm, alu_out_xm,

    output [15:0] data_out

);

    wire [15:0] data_in;

    assign data_in = b_m2m ? writeback_data : reg2_xm;
    assign enable = mem_read_xm || mem_write_xm;

    DataMemory dm ( .data_in(data_in), .data_out(data_out), .addr(alu_out_xm), .enable(enable), .wr(mem_write_xm), .clk(clk), .rst(rst) );

endmodule