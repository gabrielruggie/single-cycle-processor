module DecodeStage (
	
	input clk, rst_n, enable,
	input [2:0] flags_prev, flags_curr, flag_en,
	input [15:0] curr_pc_fd, curr_instr_fd,
	input [3:0] opcode_xm, write_reg_xm,	// used for stall checking
	output stall,	// Flag for sending no-op instructions
	output flush,	// if branch taken, FetchDecode Reg cleared
	output [15:0] instruction_de, 		// opcode to send to de_ex reg, may be no-op for stalls
	output [15:0] rs_data, rt_data, imm_out,	// rs and rt data to send to ALU
	output reg [15:0] branch_pc,
	output branch, br_en, mem_read, dst_reg, mem_to_reg, alu_src, mem_write, write_reg, hlt, pcs,
	output load_higher, load_lower,
	output [3:0] write_reg_de,
	output [2:0] flags
);

	// local module signals
	wire [15:0] imm;	
	wire [3:0] IFID_RegRs, IFID_RegRt, IFID_RegRd, rs, rt, rd;
	wire [2:0]  condition_codes; // determine which comparison to do
	wire branch_en, __load_higher, __load_lower;
	wire overflow;
	wire branch_taken;
	
    // 1. Register File
	RegisterFile rf(.clk,.rst(!rst_n),.src_reg1(rs),.src_reg2(rt),.dst_reg(rd),.write_en(write_reg),.dst_data(rd),.src_data1(rs_data),.src_data2(rt_data));
	
    // 2. Control Unit
	ControlUnit cu(.opcode(curr_instr_fd[15:12]),.dst_reg,.alu_src,.mem_read,.mem_write,.mem_to_reg,
				   .write_reg,.branch_en,.branch,.pcs,.__load_higher,.__load_lower,.hlt);
				   
	// Branch Calcuation done by PCUnit
	PCUnit PCU(.flags(flags_curr), .condition_codes, .immediate(curr_instr_fd[8:0]), .rs_data, .branch, .PC_in(curr_pc_fd), .PC_out(branch_pc), .branch_taken);

    // 3. Flag Register
    FlagRegister fr ( .clk(clk), .rst(!rst_n), .flag_prev(flag_prev), .flags_curr(flags_curr), .enable(flag_en) );

    // 4. Control Hazard Unit
	// Hazard Detection Signal
    assign stall = ((opcode_xm == 4'h8) | (opcode_xm[3:2] == 2'b00)) & (rs == write_reg_xm) & branch_en;
	
	// set opcode to no-op (PCS $0)
	assign instruction_de = stall ? 16'hE000 : curr_instr_fd;
	
	// flush logic for branches, if flushing set all control signals to zero
	assign flush = branch_taken ? 1'b1 : 1'b0;
	
	
    // 6. Register & Imm. Dataflow
	assign imm = mem_read | mem_write ? { {12{1'b0}}, curr_instr_fd[3:0] } << 1 : 
				  __load_lower ? {{8{1'b0}}, curr_instr_fd[7:0]} : 
                  __load_higher ? curr_instr_fd[7:0] << 8 : {{12{1'b0}},curr_instr_fd[3:0]};
	
	assign rs = __load_higher | __load_lower ? rd : curr_instr_fd[7:4];
    assign rt = mem_read | mem_write ? curr_instr_fd[11:8] : curr_instr_fd[3:0];
    assign rd = curr_instr_fd[11:8];

	assign load_higher = __load_higher;
	assign load_lower = __load_lower;

	assign write_reg_de = (dst_reg) ? rd : rt;

	assign flags = flags_curr;

	assign br_en = branch_en;
	
endmodule
