module DecodeStage (
	
	input clk, rst_n, enable;
	input [15:0] curr_pc_fd, next_pc_fd, curr_instr_fd;
	

);

	// local module signals
	wire [15:0] imm;		
	wire [3:0] IFID_RegRs, IFID_RegRt, IFID_RegRd, rs, rt, rd;
	wire dst_reg, alu_src, mem_read, mem_write, mem_to_reg, write_reg, branch_en, branch, pcs, load_higher, load_lower, hlt;
    // 1. Register File
	RegisterFile rf(.clk,.rst(!rst_n),.src_reg1(),.src_reg2(),.dst_reg(),.write_en(),.dst_data(),.src_data1(),.src_data2());
	
    // 2. Control Unit
	ControlUnit cu(.opcode(curr_instr_fd[15:12]),.dst_reg,.alu_src,.mem_read,.mem_write,.mem_to_reg,
				   .write_reg,.branch_en,.branch,.pcs,.load_higher,.load_lower,.hlt);

    // 3. Flag Register
	FlagRegister fr(.clk,.rst(),.flag_prev(),.flag_curr(),.enable());

    // 4. Control Hazard Unit
	

    // 5. Register & Imm. Dataflow
	assign imm = mem_read || mem_write ? { {12{1'b0}}, curr_instr_fd[3:0] } << 1 : 
				  load_lower ? {{8{1'b0}}, curr_instr_fd[7:0]} : 
                  load_higher ? curr_instr_fd[7:0] << 8 : {{12{1'b0}},curr_instr_fd[3:0]};
	
	assign rs = load_higher || load_lower ? rd : curr_instr_fd[7:4];
    assign rt = mem_read || mem_write ? curr_instr_fd[11:8] : curr_instr_fd[3:0];
    assign rd = curr_instr_fd[11:8];

    // 6. Stalls & Flush Logic
    // Hazard Detection Signal (This should be an output of the DecodeStage Module)
	// Should this be current opcode from decode?
    assign stall = (opcode_xm == 4'h8 || opcode_xm[3:2] == 2'b00) && (rs == write_reg_xm) && branch_en_fd;

endmodule
