module Register(

    input clk,
    input rst,
    input[15:0] D,
    input write_en,
    input read_en1,
    input read_en2,
    inout[15:0] bitline1,
    inout[15:0] bitline2

);

    BitCell bc0 ( .clk(clk), .rst(rst), .D(D[0]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[0]), .bitline2(bitline2[0]) );
    BitCell bc1 ( .clk(clk), .rst(rst), .D(D[1]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[1]), .bitline2(bitline2[1]) );
    BitCell bc2 ( .clk(clk), .rst(rst), .D(D[2]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[2]), .bitline2(bitline2[2]) );
    BitCell bc3 ( .clk(clk), .rst(rst), .D(D[3]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[3]), .bitline2(bitline2[3]) );
    BitCell bc4 ( .clk(clk), .rst(rst), .D(D[4]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[4]), .bitline2(bitline2[4]) );
    BitCell bc5 ( .clk(clk), .rst(rst), .D(D[5]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[5]), .bitline2(bitline2[5]) );
    BitCell bc6 ( .clk(clk), .rst(rst), .D(D[6]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[6]), .bitline2(bitline2[6]) );
    BitCell bc7 ( .clk(clk), .rst(rst), .D(D[7]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[7]), .bitline2(bitline2[7]) );
    BitCell bc8 ( .clk(clk), .rst(rst), .D(D[8]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[8]), .bitline2(bitline2[8]) );
    BitCell bc9 ( .clk(clk), .rst(rst), .D(D[9]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[9]), .bitline2(bitline2[9]) );
    BitCell bc10 ( .clk(clk), .rst(rst), .D(D[10]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[10]), .bitline2(bitline2[10]) );
    BitCell bc11 ( .clk(clk), .rst(rst), .D(D[11]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[11]), .bitline2(bitline2[11]) );
    BitCell bc12 ( .clk(clk), .rst(rst), .D(D[12]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[12]), .bitline2(bitline2[12]) );
    BitCell bc13 ( .clk(clk), .rst(rst), .D(D[13]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[13]), .bitline2(bitline2[13]) );
    BitCell bc14 ( .clk(clk), .rst(rst), .D(D[14]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[14]), .bitline2(bitline2[14]) );
    BitCell bc15 ( .clk(clk), .rst(rst), .D(D[15]), .write_en(write_en), .read_en1(read_en1), .read_en2(read_en2), .bitline1(bitline1[15]), .bitline2(bitline2[15]) );

endmodule