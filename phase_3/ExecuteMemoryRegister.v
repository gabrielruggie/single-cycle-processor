module ExecuteMemoryRegister (

    input clk, rst, enable, hlt_de,
    input mem_read_de, mem_write_de, mem_to_reg_de, reg_write_de, pcs_de, 
	//input load_higher_de, load_lower_de, 
    //input [3:0] write_reg_de 
	input [3:0] dst_reg_x, opcode_de, rt_in, 
    input [15:0] next_pc_de, reg2_de, alu_out1, 

    output [3:0] write_reg_xm, rt_out, opcode_xm,
    output hlt_xm, mem_read_xm, mem_write_xm, mem_to_reg_xm, reg_write_xm, pcs_xm, //load_higher_xm, load_lower_xm,
    output [15:0] next_pc_xm, reg2_xm, alu_out2

);

    // Control Signals
    dff hlt         ( .d(hlt_de), .q(hlt_xm), .wen(enable), .clk(clk), .rst(rst) );
    dff mem_read    ( .d(mem_read_de), .q(mem_read_xm), .wen(enable), .clk(clk), .rst(rst) );
    dff mem_write   ( .d(mem_write_de), .q(mem_write_xm), .wen(enable), .clk(clk), .rst(rst) );
    dff mem_to_reg  ( .d(mem_to_reg_de), .q(mem_to_reg_xm), .wen(enable), .clk(clk), .rst(rst) );
    dff reg_write   ( .d(reg_write_de), .q(reg_write_xm), .wen(enable), .clk(clk), .rst(rst) );
    dff pcs         ( .d(pcs_de), .q(pcs_xm), .wen(enable), .clk(clk), .rst(rst) );
	//dff load_lower  ( .d(load_lower_de), .q(load_lower_xm), .clk, .rst);
	//dff load_higher ( .d(load_higher_de), .q(load_higher_xm), .clk, .rst);

    // Current Signal Opcode
    dff opcode0     ( .d(opcode_de[0]), .q(opcode_xm[0]), .wen(enable), .clk(clk), .rst(rst) );
    dff opcode1     ( .d(opcode_de[1]), .q(opcode_xm[1]), .wen(enable), .clk(clk), .rst(rst) );
    dff opcode2     ( .d(opcode_de[2]), .q(opcode_xm[2]), .wen(enable), .clk(clk), .rst(rst) );
    dff opcode3     ( .d(opcode_de[3]), .q(opcode_xm[3]), .wen(enable), .clk(clk), .rst(rst) );

    // Register 2
    dff reg2_0      ( .d(dst_reg_x[0]), .q(write_reg_xm[0]), .wen(enable), .clk(clk), .rst(rst) );
    dff reg2_1      ( .d(dst_reg_x[1]), .q(write_reg_xm[1]), .wen(enable), .clk(clk), .rst(rst) );
    dff reg2_2      ( .d(dst_reg_x[2]), .q(write_reg_xm[2]), .wen(enable), .clk(clk), .rst(rst) );
    dff reg2_3      ( .d(dst_reg_x[3]), .q(write_reg_xm[3]), .wen(enable), .clk(clk), .rst(rst) );

    // Register Rt
    dff rt0         ( .d(rt_in[0]), .q(rt_out[0]), .wen(enable), .clk(clk), .rst(rst) );
    dff rt1         ( .d(rt_in[1]), .q(rt_out[1]), .wen(enable), .clk(clk), .rst(rst) );
    dff rt2         ( .d(rt_in[2]), .q(rt_out[2]), .wen(enable), .clk(clk), .rst(rst) );
    dff rt3         ( .d(rt_in[3]), .q(rt_out[3]), .wen(enable), .clk(clk), .rst(rst) );

    // Use registers instead of 48 flip flops
    Register next_pc ( .clk(clk), .rst(rst), .D(next_pc_de), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .bitline1(next_pc_xm), .bitline2() );
    Register alu     ( .clk(clk), .rst(rst), .D(alu_out1), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .bitline1(alu_out2), .bitline2() );
    Register reg2    ( .clk(clk), .rst(rst), .D(reg2_de), .write_en(enable), .read_en1(1'b1), .read_en2(1'b0), .bitline1(reg2_xm), .bitline2() );

endmodule