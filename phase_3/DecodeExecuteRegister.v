module DecodeExecuteRegister (

    input clk, rst, enable,
	input [15:0] instruction_de, next_pc_d,	// current instruction 
	input [15:0] decode_imm, rs_data_d, rt_data_d,
	// input [3:0] write_reg,
	input mem_read, mem_to_reg, alu_src, mem_write,
	      reg_write, hlt, pcs, load_lower, load_higher,
	// input [3:0] rs_d, rt_d, rd_d, // Reg addr to send to forwarding unit
	
	output mem_read_de, mem_to_reg_de, mem_write_de, alu_src_de, reg_write_de,
	output [3:0] opcode_de, rs_de, rt_de, rd_de,
	output [15:0] rs_data, rt_data,	// rs and rt data to send to ALU
	output [15:0] imm_de,
	output [15:0] next_pc_de,
	// output [3:0] write_reg_de,
	output hlt_de, pcs_de, load_lower_de, load_higher_de
);

	// local module Signals
	wire [15:0] instruction;

	// Load Signals
	dff load_lower_ff (.q(load_lower_de),.d(load_lower),.wen(enable),.clk,.rst);
	dff load_higher_ff (.q(load_higher_de),.d(load_higher),.wen(enable),.clk,.rst);

	// Propagating halt signal
	dff hlt_ff(.q(hlt_de),.d(hlt),.wen(enable),.clk,.rst);
	
	// PCS
	dff pcs_ff(.q(pcs_de),.d(pcs),.wen(enable),.clk,.rst);

	// WriteBack control signals
	dff regwrite_ff(.q(reg_write_de),.d(reg_write),.wen(enable),.clk,.rst);
	dff memtoreg_ff(.q(mem_to_reg_de),.d(mem_to_reg),.wen(enable),.clk,.rst);
	
	// Memory control signals
	dff memread_ff(.q(mem_read_de),.d(mem_read),.wen(enable),.clk,.rst);
	dff memwrite_ff(.q(mem_write_de),.d(mem_write),.wen(enable),.clk,.rst);
	
	// Destination Register
	// dff write_reg0 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg[0]), .q(write_reg_de[0]) );
	// dff write_reg1 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg[1]), .q(write_reg_de[1]) );
	// dff write_reg2 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg[2]), .q(write_reg_de[2]) );
	// dff write_reg3 ( .clk(clk), .rst(rst), .wen(enable), .d(write_reg[3]), .q(write_reg_de[3]) );

	// Execute control signals (opcode and alu source)
	dff aluop_ff_0(.q(opcode_de[0]), .d(instruction_de[12]), .wen(enable), .clk, .rst);
	dff aluop_ff_1(.q(opcode_de[1]), .d(instruction_de[13]), .wen(enable), .clk, .rst);	
	dff aluop_ff_2(.q(opcode_de[2]), .d(instruction_de[14]), .wen(enable), .clk, .rst);
	dff aluop_ff_3(.q(opcode_de[3]), .d(instruction_de[15]), .wen(enable), .clk, .rst);
	dff alusrc_ff(.q(alu_src_de), .d(alu_src),.wen(enable), .clk,.rst);
	
	// Register addresses
	dff RD_DE_0(.q(rd_de[0]), .d(instruction_de[8]),  .wen(enable), .clk, .rst);
	dff RD_DE_1(.q(rd_de[1]), .d(instruction_de[9]),  .wen(enable), .clk, .rst);
	dff RD_DE_2(.q(rd_de[2]), .d(instruction_de[10]), .wen(enable), .clk, .rst);
	dff RD_DE_3(.q(rd_de[3]), .d(instruction_de[11]), .wen(enable), .clk, .rst);
	
	dff RS_DE_0(.q(rs_de[0]), .d(instruction_de[4]),  .wen(enable), .clk, .rst);
	dff RS_DE_1(.q(rs_de[1]), .d(instruction_de[5]),  .wen(enable), .clk, .rst);
	dff RS_DE_2(.q(rs_de[2]), .d(instruction_de[6]),  .wen(enable), .clk, .rst);
	dff RS_DE_3(.q(rs_de[3]), .d(instruction_de[7]),  .wen(enable), .clk, .rst);
	
	dff RT_DE_0(.q(rt_de[0]), .d(instruction_de[0]),  .wen(enable), .clk, .rst);
	dff RT_DE_1(.q(rt_de[1]), .d(instruction_de[1]),  .wen(enable), .clk, .rst);
	dff RT_DE_2(.q(rt_de[2]), .d(instruction_de[2]),  .wen(enable), .clk, .rst);
	dff RT_DE_3(.q(rt_de[3]), .d(instruction_de[3]),  .wen(enable), .clk, .rst);
	
	// Register Data
	Register RS(.clk,.rst,.D(rs_data_d),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rs_data),.bitline2());
	Register RT(.clk,.rst,.D(rt_data_d),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(rt_data),.bitline2());
	
	// immeditate data
	Register im(.clk,.rst,.D(decode_imm),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(imm_de),.bitline2());

	// Next PC
	Register next_pc (.clk,.rst,.D(next_pc_d),.write_en(enable),.read_en1(1'b1),.read_en2(1'b0),.bitline1(next_pc_de),.bitline2());

endmodule