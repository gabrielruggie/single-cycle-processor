module DataHazardUnit (

    input reg_write_xm, reg_write_mw, mem_write,
    input [3:0] dst_reg_xm, dst_reg_mw,
    input [3:0] rs_de, rt_de,
    input [3:0] rt_xm, rd_xm,
    input [3:0] rd_mw,
    output a_x2x, b_x2x, 
    output a_m2x, b_m2x, 
    output b_m2m

);

    assign not_x2x_a = !( reg_write_xm && (rd_xm != 4'h0) && (rd_xm == rs_de) && (rd_mw == rs_de) );
    assign not_x2x_b = !( reg_write_xm && (rd_xm != 4'h0) && (rd_xm == rt_de) && (rd_mw == rt_de) );

    assign a_x2x = ( reg_write_xm && (dst_reg_xm == rs_de) && (dst_reg_xm != 4'h0) );
    assign b_x2x = ( reg_write_xm && (dst_reg_xm == rt_de) && (dst_reg_xm != 4'h0) );

    assign a_m2x = ( reg_write_mw && (rd_mw != 4'h0) && not_x2x_a );
    assign b_m2x = ( reg_write_mw && (rd_mw != 4'h0) && not_x2x_b );
    
    assign b_m2m = ( mem_write && reg_write_mw && (dst_reg_mw != 4'h0) && (dst_reg_mw == rt_xm) );

endmodule