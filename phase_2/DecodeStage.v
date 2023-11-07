module DecodeStage (
	
	input clk, rst_n, enable,
	input [2:0] flags_prev, flags_curr, flag_en,
	input [15:0] curr_pc_fd, next_pc_fd, curr_instr_fd,
	input [3:0] opcode_xm, write_reg_xm,	// used for stall checking
	output stall,	// Flag for sending no-op instructions
	output flush,	// if branch taken, FetchDecode Reg cleared
	output [15:0] opcode_out, 		// opcode to send to de_ex reg, may be no-op for stalls
	output [15:0] rs_data, rt_data, imm_out,	// rs and rt data to send to ALU
	output reg [15:0] branch_pc,
	output dst_reg, branch, mem_read, mem_to_reg, alu_src, mem_write, write_reg
);

	// local module signals
	wire [15:0] imm, branch_inst;		
	wire [3:0] IFID_RegRs, IFID_RegRt, IFID_RegRd, rs, rt, rd;
	wire [15:0] branch_target;	// target PC from branch
	wire [2:0]  condition_codes; // determine which comparison to do
	wire branch_en, pcs, load_higher, load_lower, hlt;
	wire [15:0] branch_register, branch_reg_p_2, sign_ext_imm;
	wire overflow;
	reg branch_taken;
	
    // 1. Register File
	RegisterFile rf(.clk,.rst(!rst_n),.src_reg1(rs),.src_reg2(rt),.dst_reg(rd),.write_en(write_reg),.dst_data(rd),.src_data1(rs_data),.src_data2(rt_data));
	
    // 2. Control Unit
	ControlUnit cu(.opcode(curr_instr_fd[15:12]),.dst_reg,.alu_src,.mem_read,.mem_write,.mem_to_reg,
				   .write_reg,.branch_en,.branch,.pcs,.load_higher,.load_lower,.hlt);

    // 3. Flag Register
    FlagRegister fr ( .clk(clk), .rst(!rst_n), .flag_prev(flag_prev), .flags_curr(flags_curr), .enable(flag_en) );

    // 4. Control Hazard Unit
	// Hazard Detection Signal
    assign stall = ((opcode_xm == 4'h8) | (opcode_xm[3:2] == 2'b00)) & (rs == write_reg_xm) & branch_en;
	
	// set opcode to no-op (PCS $0)
	assign opcode_out = stall ? 16'hE000 : curr_instr_fd;
	
	// flush logic for branches, if flushing set all control signals to zero
	assign flush = branch_taken ? 1'b1 : 1'b0;
	
	// Branch Calcuation
	// get branch pc from register
	// read flags to determine branch
	
	assign branch_register = rs_data;
	assign condition_codes = curr_instr_fd[11:9];
	
	// calculate branch target pc value
	assign sign_ext_imm = { {7{curr_instr_fd[8]} } , curr_instr_fd[8:0] } << 1;
    cla_16bit CLA0 ( .A(curr_pc_fd), .B(16'h0002), .Sum(branch_reg_p_2), .Ovfl(overflow), .sub(1'b0) );
    cla_16bit CLA1 ( .A(branch_reg_p_2), .B(sign_ext_imm), .Sum(branch_target), .Ovfl(overflow), .sub(1'b0) ); 
	
	// comparison from flag registers to determine if branch register or if branch is taken
    always @(*) begin
        case (condition_codes) 
            3'b000: branch_pc = flags_curr[1] ? (branch_en ? branch_register : branch_target) : next_pc_fd;                                 // Case when: Z=0
            3'b001: branch_pc = flags_curr[1] ? (branch_en ? branch_register : branch_target) : next_pc_fd;                                 // Case when: Z=1
            3'b010: branch_pc = flags_curr[1] & flags_curr[2] ? (branch_en ? branch_register : branch_target) : next_pc_fd;                     // Case when: N=0 and Z=0
            3'b011: branch_pc = flags_curr[2] ? (branch_en ? branch_register : branch_target) : next_pc_fd;                                 // Case when: N=1
            3'b100: branch_pc = flags_curr[1] | (~flags_curr[1] & ~flags_curr[2]) ? (branch_en ? branch_register : branch_target) : next_pc_fd;     // Case when: Z=1 or N=0 and Z=0
            3'b101: branch_pc = flags_curr[1] & flags_curr[2] ? (branch_en ? branch_register : branch_target) : next_pc_fd;                     // Case when: N=1 or Z=1
            3'b110: branch_pc = flags_curr[0] ? (branch_en ? branch_register : branch_target) : next_pc_fd;                                 // Case when: V=1
            default: branch_pc = branch_en ? branch_register : branch_target;                                                       // Unconditional Branch
        endcase
    end
	
    always @(*) begin
        case (condition_codes)  
            3'b000 : branch_taken = flags_curr[1] ? 1'b0 : 1'b1;
            3'b001 : branch_taken = flags_curr[1] ? 1'b1 : 1'b0;
            3'b010 : branch_taken = (flags_curr[2] & flags_curr[1]) ? 1'b0 : 1'b1;
            3'b011 : branch_taken = flags_curr[2] ? 1'b1 : 1'b0;
            3'b100 : branch_taken = (flags_curr[1] | (~flags_curr[1] & ~flags_curr[2])) ? 1'b1 : 1'b0;
            3'b101 : branch_taken = (flags_curr[1] | flags_curr[2]) ? 1'b1 : 1'b0;
            3'b110 : branch_taken = flags_curr[0] ? 1'b1 : 1'b0;
           default : branch_taken = 1'b1;
        endcase
    end
	
    // 6. Register & Imm. Dataflow
	assign imm = mem_read | mem_write ? { {12{1'b0}}, curr_instr_fd[3:0] } << 1 : 
				  load_lower ? {{8{1'b0}}, curr_instr_fd[7:0]} : 
                  load_higher ? curr_instr_fd[7:0] << 8 : {{12{1'b0}},curr_instr_fd[3:0]};
	
	assign rs = load_higher | load_lower ? rd : curr_instr_fd[7:4];
    assign rt = mem_read | mem_write ? curr_instr_fd[11:8] : curr_instr_fd[3:0];
    assign rd = curr_instr_fd[11:8];
	
endmodule
