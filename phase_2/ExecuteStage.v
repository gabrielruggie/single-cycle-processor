module ExecuteStage (

    input [15:0] writeback_data, reg1_de, reg2_de,
    input reg_write_xm, reg_write_mw, mem_write_xm, 
    input [3:0] dst_reg_xm, dst_reg_mw, rs_de, rt_de, rt_xm, rd_mw, rd_xm, 
    input [15:0] alu_out_xm,
    input mem_read_de, mem_write_de, 
    input load_lower_de, load_higher_de, 
    input alu_src_de,
    input [15:0] immediate,
    input [3:0] opcode,

    output [2:0] enable,
    output [2:0] flags,
    output [15:0] alu_out,
    output b_m2m

);

    wire [15:0] A, B;
    wire a_x2x, a_m2x, b_x2x, b_m2x;

    // Forwarding Logic
    assign A_fwd = a_x2x ? alu_out_xm : a_m2x ? writeback_data : reg1_de;
    assign B_fwd = b_x2x ? alu_out_xm : b_m2x ? writeback_data : reg2_de;

    // ALU Input Logic
    assign A = (mem_read_de || mem_write_de) ? A_fwd & 16'hFFFE : 
                load_lower_de ? A_fwd & 16'hFF00 : 
                load_higher_de ? A_fwd & 16'h00FF : 
                A_fwd;

    assign B = alu_src_de ? immediate : reg2_de;

    ALU alu ( .Opcode(opcode), .ALU_In1(A), .ALU_In2(B), .flags(flags), .enable(enable), .ALU_out(alu_out) );

    DataHazardUnit dhz ( .reg_write_xm(reg_write_xm), .reg_write_mw(reg_write_mw), .mem_write(mem_write_xm), .dst_reg_xm(dst_reg_xm), 
                         .dst_reg_mw(dst_reg_mw), .rs_de(rs_de), .rt_de(rt_de), .rt_xm(rt_xm), .rd_xm(rd_xm), .rd_mw(rd_mw), .a_x2x(a_x2x), 
                         .b_x2x(b_x2x), .a_m2x(a_m2x), .b_m2x(b_m2x), .b_m2m(b_m2m) );
    

endmodule