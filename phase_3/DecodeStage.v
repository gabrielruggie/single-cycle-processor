module DecodeStage (
	
	input clk, rst, enable,
	input [2:0] flags_alu, flag_en,
	input [15:0] curr_pc_fd, curr_instr_fd,
	input [3:0] opcode_xm, write_reg_xm,	// used for stall checking
	input [15:0] writeback_data,
	
	output stall,	// Flag for sending no-op instructions
	output flush,	// if branch taken, FetchDecode Reg cleared
	output [15:0] instruction_de, 		// opcode to send to de_ex reg, may be no-op for stalls
	output [15:0] rs_data, rt_data, imm_d,	// rs and rt data to send to ALU
	output [15:0] branch_pc, next_pc_d,
	output br_en, mem_read, dst_reg, mem_to_reg, alu_src, mem_write, reg_write, hlt, pcs,
	output load_higher, load_lower,
	//output [3:0] write_reg,
	//output [3:0] rs_d, rt_d, rd_d,		// addr of destination reg
	output [2:0] flags
);

	// local module signals
	wire [15:0] imm, PCS;	
	wire [3:0] IFID_RegRs, IFID_RegRt, IFID_RegRd, rs, rt, rd;
	wire [2:0]  condition_codes; // determine which comparison to do
	wire branch_en, __load_higher, __load_lower;
	wire overflow;
	wire branch, branch_taken;
	wire __write_en;
	
	
    // 1. Control Unit
	ControlUnit cu(.opcode(curr_instr_fd[15:12]),.dst_reg,.alu_src,.mem_read,.mem_write,.mem_to_reg,
				   .write_reg(__write_en),.branch_en,.branch,.pcs, .load_higher(__load_higher), .load_lower(__load_lower), .hlt);

    // 2. Register File
	RegisterFile rf(.clk,.rst, .src_reg1(rs),.src_reg2(rt), .dst_reg(write_reg_xm), .write_en(__write_en), .dst_data(writeback_data), .src_data1(rs_data), .src_data2(rt_data));
				   
	// Branch Calcuation done by PCUnit
	PCUnit PCU(.flags(flags), .condition_codes, .immediate(curr_instr_fd[8:0]), .rs_data, .branch, .PC_in(curr_pc_fd), .PC_out(branch_pc), .PCS, .branch_taken);
	assign next_pc_d = PCS;

    // 3. Flag Register
    FlagRegister fr ( .clk(clk), .rst(rst), .flag_prev(flags_alu), .flag_curr(flags), .enable(flag_en) );

    // 4. Control Hazard Unit
	// Hazard Detection Signal
    assign stall = ((opcode_xm == 4'h8) | (opcode_xm[3:2] == 2'b00)) & (rs == write_reg_xm) & branch_en;
	
	// set opcode to no-op on stall (execute PCS $0)
	assign instruction_de = stall ? 16'hE000 : curr_instr_fd;
	
	// flush logic for branches, if flushing set all control signals to zero
	assign flush = branch_taken ? 1'b1 : 1'b0;
	
	
    // 6. Register & Imm. Dataflow
	assign imm_d = mem_read | mem_write ? { {12{1'b0}}, curr_instr_fd[3:0] } << 1 : 
				  __load_lower ? {{8{1'b0}}, curr_instr_fd[7:0]} : 
                  __load_higher ? curr_instr_fd[7:0] << 8 : {{12{1'b0}},curr_instr_fd[3:0]};
	
	assign rs = __load_higher | __load_lower ? rd : curr_instr_fd[7:4];
    assign rt = mem_read | mem_write ? curr_instr_fd[11:8] : curr_instr_fd[3:0];
    assign rd = curr_instr_fd[11:8];

	assign load_higher = __load_higher;
	assign load_lower = __load_lower;

	// assign write_reg = (dst_reg) ? rd : rt;

	assign br_en = branch_en;
	
	assign reg_write = __write_en;
	
endmodule