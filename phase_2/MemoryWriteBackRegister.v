module MemoryWriteBackRegister (

    input clk, rst, enable, hlt_xm,
    input mem_to_reg_xm, reg_write_xm, pcs_xm,
    input [15:0] next_pc_xm, mem_data_xm, alu_out_xm,
    input [3:0] write_reg_xm,

    output hlt_mw,
    output mem_to_reg_mw, reg_write_mw, pcs_mw, //load_lower_mw, load_higher_mw,
    output [3:0] write_reg_mw,
    output [15:0] next_pc_mw, mem_data_mw, alu_out_mw

);

    dff hlt             ( .clk(clk), .rst(rst), .d(hlt_xm), .q(hlt_mw), .wen(enable) );
    dff mem_to_reg      ( .clk(clk), .rst(rst), .d(mem_to_reg_xm), .q(mem_to_reg_mw), .wen(enable) );
    dff reg_write       ( .clk(clk), .rst(rst), .d(reg_write_xm), .q(reg_write_mw), .wen(enable) );
    dff pcs             ( .clk(clk), .rst(rst), .d(pcs_xm), .q(pcs_mw), .wen(enable) );

    dff write_reg0      ( .clk(clk), .rst(rst), .d(write_reg_xm[0]), .q(write_reg_mw[0]), .wen(enable) );
    dff write_reg1      ( .clk(clk), .rst(rst), .d(write_reg_xm[1]), .q(write_reg_mw[1]), .wen(enable) );
    dff write_reg2      ( .clk(clk), .rst(rst), .d(write_reg_xm[2]), .q(write_reg_mw[2]), .wen(enable) );
    dff write_reg3      ( .clk(clk), .rst(rst), .d(write_reg_xm[3]), .q(write_reg_mw[3]), .wen(enable) );

    Register next_pc    ( .clk(clk), .rst(rst), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .D(next_pc_xm), .bitline1(next_pc_mw), .bitline2() );
    Register mem_data   ( .clk(clk), .rst(rst), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .D(mem_data_xm), .bitline1(mem_data_mw), .bitline2() );
    Register alu_reg    ( .clk(clk), .rst(rst), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .D(alu_out_xm), .bitline1(alu_out_mw), .bitline2() );

endmodule