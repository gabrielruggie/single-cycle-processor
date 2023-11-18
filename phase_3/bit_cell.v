module BitCell (

	input clk,
	input rst,
	input D,
	input write_en,
	input read_en1,
	input read_en2,
	inout bitline1,
	inout bitline2

);
	
	wire out;

	dff ff ( .q(out), .d(D), .wen(write_en), .clk(clk), .rst(rst) );

	assign bitline1 = read_en1 ? out : 1'bz;
	assign bitline2 = read_en2 ? out : 1'bz;

endmodule
