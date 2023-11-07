module DecodeExecuteRegister (

    input clk, rst, enable,
	input [15:0] rs, rt,	// rs and rt data from register file
	input [15:0] opcode,	// current opcode 
	input [15:0] decode_imm,
	input [3:0] IFID_RegRs, IFID_RegRd, // Reg addr to send to forwarding unit
	
	input dst_reg, branch, mem_read, mem_to_reg, alu_src, alu_op, mem_write,
	      write_reg,
		  
	output RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
	output [3:0] alu_op_de,
	output [15:0] rs_data, rt_data,	// rs and rt data to send to ALU
	output [15:0] imm
);

	// WriteBack control signals
	dff regwrite_ff(.q(RegWrite),.d(write_reg),.wen(enable),.clk,.rst);
	dff memtoreg_ff(.q(MemtoReg),.d(mem_to_reg),.wen(enable),.clk,.rst);
	
	// Memory control signals
	dff branch_ff(.q(Branch),.d(branch),.wen(enable),.clk,.rst);
	dff memread_ff(.q(MemRead),.d(mem_read),.wen(enable),.clk,.rst);
	dff memwrite_ff(.q(MemWrite),.d(mem_write),.wen(enable),.clk,.rst);
	
	// Execute control signals
	dff regdst_ff(.q(RegDst),.d(dst_reg),.wen(enable),.clk,.rst);
	dff aluop_ff_0(.q(ALUOp),.d(opcode[15]),.wen(enable),.clk,.rst);
	dff aluop_ff_1(.q(ALUOp),.d(opcode[14]),.wen(enable),.clk,.rst);	
	dff aluop_ff_2(.q(ALUOp),.d(opcode[13]),.wen(enable),.clk,.rst);
	dff aluop_ff_3(.q(ALUOp),.d(opcode[12]),.wen(enable),.clk,.rst);
	dff alusrc_ff(.q(ALUSrc),.d(alu_src),.wen(enable),.clk,.rst);
	
	// Register Data
	Register RS(.clk,.rst,.D(rs),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rs_data),.bitline2(16'hZZZZ));
	Register RT(.clk,.rst,.D(rt),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rt_data),.bitline2(16'hZZZZ));
	
	// immeditate data
	Register im(.clk,.rst,.D(decode_imm),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(imm),.bitline2(16'hZZZZ));

	// opcode & Register addresses
	assign alu_op_de = opcode[15:12];
	assign IFID_RegRd = opcode [11:8];
	assign IFID_RegRs = opcode [7:4];
	assign IFID_RegRt = opcode [3:0];

endmodule
