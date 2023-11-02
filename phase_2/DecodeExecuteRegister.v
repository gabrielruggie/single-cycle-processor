module DecodeExecuteRegister (

    input clk, rst, enable;
	input [15:0] rs, rt;


	// Would these be IDEX_rs... cause its the decode_execute stage?
	input [3:0] IFID_RegRs, IFID_RegRt, IFID_RegRd;
	
	input dst_reg, branch, mem_read, mem_to_reg, alu_src, alu_op, mem_write,
	      write_reg;
		  
	output RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite
	output [15:0] rs_data, rt_data;
);

	// WriteBack control signals
	dff regwrite_ff(.q(RegWrite),.d(write_reg),.wen(enable),.clk,.rst);
	dff memtoreg_ff(.q(MemtoReg),.d(mem_to_reg),.wen(enable),.clk,.rst);
	
	// Memory control signals
	dff branch_ff(.q(Branch),.d(branch),.wen(enable),.clk,.rst);
	dff memread_ff(.q(MemRead),.d(mem_read),.wen(enable).clk,.rst);
	dff memwrite_ff(.q(MemWrite),.d(mem_write),.wen(enable),.clk,.rst);
	
	// Execute control signals
	dff regdst_ff(.q(RegDst),.d(dst_reg),.wen(enable),.clk,.rst);
	dff aluop_ff(.q(ALUOp),.d(alu_op),.wen(enable),.clk,.rst);
	dff alusrc_ff(.q(ALUSrc),.d(alu_src),.wen(enable),.clk,.rst);
	
	// Register Data
	Register RS(.clk,.rst,.D(rs),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rs_data),.bitline2(16'hZZZZ));
	Register RT(.clk,.rst,.D(rs),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rt_data),.bitline2(16'hZZZZ));

	// Register addresses
	

endmodule
