module FetchDecodeRegister (

    input clk, rst, enable,
    input [15:0] curr_pc, curr_instr,
    output [15:0] curr_pc_fd, curr_instr_fd

);

    Register CURR_PC ( .clk(clk), .rst(rst), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .bitline1(curr_pc_fd), .bitline2(), .D(curr_pc) );
    
    Register CURR_INSTR( .clk(clk), .rst(rst), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .bitline1(curr_instr_fd), .bitline2(), .D(curr_instr) );

endmodule