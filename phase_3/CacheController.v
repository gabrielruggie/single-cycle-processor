module CacheController (

    input clk, rst,
    input iwrite, iread, dwrite, dread,
    input [15:0] iaddress, daddress, data_in,

    output fetch_stall, mem_stall,
    output ihit, dhit,
    output [15:0] instruction_out, data_out

);


endmodule
