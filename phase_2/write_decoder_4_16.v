module WriteDecoder_4_16 (

	input[3:0] regid,
	input write_en,
	output[15:0] wordline

);

	assign wordline[0] = (regid == 4'h0 & write_en) ? 1 : 0;
	assign wordline[1] = (regid == 4'h1 & write_en) ? 1 : 0;
	assign wordline[2] = (regid == 4'h2 & write_en) ? 1 : 0;
	assign wordline[3] = (regid == 4'h3 & write_en) ? 1 : 0;
	assign wordline[4] = (regid == 4'h4 & write_en) ? 1 : 0;
	assign wordline[5] = (regid == 4'h5 & write_en) ? 1 : 0;
	assign wordline[6] = (regid == 4'h6 & write_en) ? 1 : 0;
	assign wordline[7] = (regid == 4'h7 & write_en) ? 1 : 0;
	assign wordline[8] = (regid == 4'h8 & write_en) ? 1 : 0;
	assign wordline[9] = (regid == 4'h9 & write_en) ? 1 : 0;
	assign wordline[10] = (regid == 4'hA & write_en) ? 1 : 0;
	assign wordline[11] = (regid == 4'hB & write_en) ? 1 : 0;
	assign wordline[12] = (regid == 4'hC & write_en) ? 1 : 0;
	assign wordline[13] = (regid == 4'hD & write_en) ? 1 : 0;
	assign wordline[14] = (regid == 4'hE & write_en) ? 1 : 0;
	assign wordline[15] = (regid == 4'hF & write_en) ? 1 : 0;

endmodule
