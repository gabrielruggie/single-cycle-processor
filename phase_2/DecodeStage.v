module DecodeStage (
	
	input clk, rst_n, enable;
	input [2:0] flags_prev, flags_curr, flag_en;
	input [15:0] curr_pc_fd, next_pc_fd, curr_instr_fd;
	output stall;	// Flag for sending no-op instructions
	output flush;	// if branch taken, FetchDecode Reg cleared
	output [3:0] alu_opcode;
	output [15:0] rs_data, rt_data;	// rs and rt data to send to ALU
	output dst_reg_out, branch_out, mem_read_out, mem_to_reg_out, alu_src_out, mem_write_out, write_reg;
);

	// define branch conditions
	parameter NEQ	  = 3'b000;
	parameter EQ	  = 3'b001;
	parameter GT 	  = 3'b010;
	parameter LT 	  = 3'b011;
	parameter GTE     = 3'b100;
	parameter LTE     = 3'b101;
	parameter OVFL 	  = 3'b100;
	parameter UNCOND  = 3'b111;

	// local module signals
	wire [15:0] imm, branch_imm;		
	wire [3:0] IFID_RegRs, IFID_RegRt, IFID_RegRd, rs, rt, rd;
	wire [15:0] branch_target;	// target PC from branch
	wire dst_reg, alu_src, mem_read, mem_write, mem_to_reg, write_reg, branch_en, branch, pcs, load_higher, load_lower, hlt;
	wire [15:0] branch_register, branch_target, branch_reg_p_2, sign_ext_imm;
	wire overflow;
	
    // 1. Register File
	RegisterFile rf(.clk,.rst(!rst_n),.src_reg1(rs),.src_reg2(rt),.dst_reg(rd),.write_en(write_reg),.dst_data(rd),.src_data1(rs_data),.src_data2(rt_data));
	
    // 2. Control Unit
	ControlUnit cu(.opcode(curr_instr_fd[15:12]),.dst_reg,.alu_src,.mem_read,.mem_write,.mem_to_reg,
				   .write_reg,.branch_en,.branch,.pcs,.load_higher,.load_lower,.hlt);

    // 3. Flag Register
    FlagRegister fr ( .clk(clk), .rst(!rst_n), .flag_prev(flag_prev), .flag_curr(flag_curr), .enable({3{flag_en}}) );

    // 4. Control Hazard Unit
	// Hazard Detection Signal (This should be an output of the DecodeStage Module)
    assign stall = ((opcode_xm == 4'h8) | (opcode_xm[3:2] == 2'b00)) & (rs == write_reg_xm) & branch_en_fd;
	
	// flush logic for branches
	assign flush = branch_taken ? 1'b1 : 1'b0;
	assign opcode = branch_taken ? 4'b0000 : curr_instr_fd [15:12];
	
	// 5. Branch Calcuation
	// get branch pc from register
	assign branch_register = rs_data;
	
	// calculate branch target pc value
	assign sign_ext_imm = { {7{curr_instr_fd[8]}} , curr_instr_fd[8:0] } << 1;
    cla_16bit CLA0 ( .A(curr_pc_fd), .B(16'h0002), .Sum(branch_reg_p_2), .Ovfl(overflow), .sub(1'b0) );
    cla_16bit CLA1 ( .A(branch_reg_p_2), .B(sign_ext_imm), .Sum(branch_target), .Ovfl(overflow), .sub(1'b0) ); 
	
	// set condition code
    always @(*) begin
        case (condition_codes) 
            NEQ  	: target_addr = flags[1] ? not_taken : taken;                           // Case when: Z=0
            EQ	 	: target_addr = flags[1] ? taken : not_taken; 							// Case when: Z=1
            GT	 	: target_addr = flags[1] & flags[2] ? not_taken : taken;                // Case when: N=0 and Z=0
            LT	 	: target_addr = flags[2] ? taken : not_taken;                           // Case when: N=1
            GTE	 	: target_addr = flags[1] | (~flags[1] & ~flags[2]) ? taken : not_taken; // Case when: Z=1 or N=0 and Z=0
            LTE	 	: target_addr = flags[1] & flags[2] ? taken : not_taken;                // Case when: N=1 or Z=1
            OVFL 	: target_addr = flags[0] ? taken : not_taken;                           // Case when: V=1
            default	: target_addr = UNCOND;                                          		// Unconditional Branch
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
