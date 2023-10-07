module RegisterFile (

    input clk,
    input rst,
    input[3:0] src_reg1,
    input[3:0] src_reg2,
    input[3:0] dst_reg,
    input write_en,
    input[15:0] dst_data,
    inout[15:0] src_data1,
    inout[15:0] src_data2

);

    wire[15:0] r_decoder1, r_decoder2, w_decoder;
    wire[15:0] reg_data1, reg_data2;

    ReadDecoder_4_16 rd0 ( .regid(src_reg1), .wordline(r_decoder1) );
    ReadDecoder_4_16 rd1 ( .regid(src_reg2), .wordline(r_decoder2) );
    WriteDecoder_4_16 w0 ( .regid(dst_reg), .write_en(write_en), .wordline(w_decoder) );

    Register register0 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[0]), .read_en1(r_decoder1[0]), .read_en2(r_decoder2[0]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register1 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[1]), .read_en1(r_decoder1[1]), .read_en2(r_decoder2[1]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register2 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[2]), .read_en1(r_decoder1[2]), .read_en2(r_decoder2[2]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register3 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[3]), .read_en1(r_decoder1[3]), .read_en2(r_decoder2[3]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register4 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[4]), .read_en1(r_decoder1[4]), .read_en2(r_decoder2[4]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register5 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[5]), .read_en1(r_decoder1[5]), .read_en2(r_decoder2[5]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register6 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[6]), .read_en1(r_decoder1[6]), .read_en2(r_decoder2[6]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register7 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[7]), .read_en1(r_decoder1[7]), .read_en2(r_decoder2[7]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register8 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[8]), .read_en1(r_decoder1[8]), .read_en2(r_decoder2[8]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register9 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[9]), .read_en1(r_decoder1[9]), .read_en2(r_decoder2[9]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register10 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[10]), .read_en1(r_decoder1[10]), .read_en2(r_decoder2[10]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register11 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[11]), .read_en1(r_decoder1[11]), .read_en2(r_decoder2[11]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register12 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[12]), .read_en1(r_decoder1[12]), .read_en2(r_decoder2[12]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register13 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[13]), .read_en1(r_decoder1[13]), .read_en2(r_decoder2[13]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register14 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[14]), .read_en1(r_decoder1[14]), .read_en2(r_decoder2[14]), .bitline1(reg_data1), .bitline2(reg_data2) );
    Register register15 ( .clk(clk), .rst(rst), .D(dst_data), .write_en(w_decoder[15]), .read_en1(r_decoder1[15]), .read_en2(r_decoder2[15]), .bitline1(reg_data1), .bitline2(reg_data2) );

    assign src_data1 = ( src_reg1 == dst_reg && write_en ) ? dst_data : reg_data1;
    assign src_data2 = ( src_reg2 == dst_data && write_en ) ? dst_data : reg_data2;

endmodule