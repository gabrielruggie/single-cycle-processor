module DecodeExecuteRegister (

    input clk, rst, enable,
	input [15:0] rs, rt,	// rs and rt data from register file
	input [15:0] instruction_de,	// current instruction 
	input [15:0] decode_imm,
	input [3:0] write_reg_de,
	
	input branch, mem_read, mem_to_reg, alu_src, alu_op, mem_write,
	      write_reg,
		  
	input [3:0] rs_de, rt_de, rd_de, // Reg addr to send to forwarding unit
	output reg_dst_de, branch_de, mem_read_de, mem_to_reg_de, mem_write_de, alu_src_de, reg_write_de, reg_write,
	output [3:0] opcode_de,
	output [15:0] rs_data, rt_data,	// rs and rt data to send to ALU
	output [15:0] imm, next_pc_de,
	output [3:0] write_reg_dx
);

	// WriteBack control signals
	dff regwrite_ff(.q(RegWrite),.d(write_reg),.wen(enable),.clk,.rst);
	dff memtoreg_ff(.q(MemtoReg),.d(mem_to_reg),.wen(enable),.clk,.rst);
	
	// Memory control signals
	dff branch_ff(.q(Branch),.d(branch),.wen(enable),.clk,.rst);
	dff memread_ff(.q(MemRead),.d(mem_read),.wen(enable),.clk,.rst);
	dff memwrite_ff(.q(MemWrite),.d(mem_write),.wen(enable),.clk,.rst);
	
	// Destination Register
	dff write_reg0 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg_de[0]), .q(write_reg_dx[0]) );
	dff write_reg1 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg_de[1]), .q(write_reg_dx[1]) );
	dff write_reg2 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg_de[2]), .q(write_reg_dx[2]) );
	dff write_reg3 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg_de[3]), .q(write_reg_dx[3]) );

	// Execute control signals
	dff aluop_ff_0(.q(ALUOp),.d(instruction_de[15]),.wen(enable),.clk,.rst);
	dff aluop_ff_1(.q(ALUOp),.d(instruction_de[14]),.wen(enable),.clk,.rst);	
	dff aluop_ff_2(.q(ALUOp),.d(instruction_de[13]),.wen(enable),.clk,.rst);
	dff aluop_ff_3(.q(ALUOp),.d(instruction_de[12]),.wen(enable),.clk,.rst);
	dff alusrc_ff(.q(ALUSrc),.d(alu_src),.wen(enable),.clk,.rst);
	
	// Register Data
	Register RS(.clk,.rst,.D(rs),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rs_data),.bitline2(16'hZZZZ));
	Register RT(.clk,.rst,.D(rt),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rt_data),.bitline2(16'hZZZZ));
	
	// immeditate data
	Register im(.clk,.rst,.D(decode_imm),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(imm),.bitline2(16'hZZZZ));

	// Next PC
	Register next_pc (.clk,.rst,.D(next_pc_fd),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(next_pc_de),.bitline2(16'hZZZZ));

	// opcode & Register addresses
	assign opcode_de = instruction_de[15:12];
	assign rd_de = instruction_de [11:8];
	assign rs_de = instruction_de [7:4];
	assign rt_de = instruction_de [3:0];

endmodule
