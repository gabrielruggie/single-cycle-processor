module ReadDecoder_4_16 (

	input[3:0] regid,
	output[15:0] wordline

);

	assign wordline[0] = (regid == 4'h0) ? 1 : 0;
	assign wordline[1] = (regid == 4'h1) ? 1 : 0;
	assign wordline[2] = (regid == 4'h2) ? 1 : 0;
	assign wordline[3] = (regid == 4'h3) ? 1 : 0;
	assign wordline[4] = (regid == 4'h4) ? 1 : 0;
	assign wordline[5] = (regid == 4'h5) ? 1 : 0;
	assign wordline[6] = (regid == 4'h6) ? 1 : 0;
	assign wordline[7] = (regid == 4'h7) ? 1 : 0;
	assign wordline[8] = (regid == 4'h8) ? 1 : 0;
	assign wordline[9] = (regid == 4'h9) ? 1 : 0;
	assign wordline[10] = (regid == 4'hA) ? 1 : 0;
	assign wordline[11] = (regid == 4'hB) ? 1 : 0;
	assign wordline[12] = (regid == 4'hC) ? 1 : 0;
	assign wordline[13] = (regid == 4'hD) ? 1 : 0;
	assign wordline[14] = (regid == 4'hE) ? 1 : 0;
	assign wordline[15] = (regid == 4'hF) ? 1 : 0;

endmodule
