module CPU (

    input clk,
    input rst_n,
    output hlt,
    output [15:0] pc

);

    // --------------------------------------------------------------------------------------------------------- // 

    // Fetch Stage
    wire [15:0] curr_pc, next_pc, curr_instr;
    wire [15:0] curr_pc_fd, next_pc_fd, curr_intr_fd;
    wire branch_en_fd, flush;

    // Decode Stage
    wire [2:0] flags_prev, flags_curr, flag_en;
    wire [3:0] rs, rt, rd, dest_reg, write_reg_de;
	wire [15:0] opcode_out;
    wire [15:0] reg1_data, reg2_data, imm_out; // Register file outputs
	wire stall;
	wire [15:0] branch_pc;
	// wire RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire reg_dst_de, branch_de, mem_read_de, mem_to_reg_de, mem_write_de, alu_src_de, reg_write_de;
	wire [15:0] rs_de, rt_de, imm_de;

    // Execute Stage
    wire [3:0] opcode_xm, write_reg_xm; // destination register
    wire [15:0] alu_out_xm, mem_data_xm, next_pc_xm;
    wire pcs_xm, reg_write_xm, mem_to_reg_xm, hlt_xm, mem_write_xm, mem_read_xm;

    // Memory Stage
    wire b_m2m;
    wire [3:0] write_reg_mw;
    wire [15:0] mem_data_mw, alu_out_mw, next_pc_mw, mem_data, reg2_xm;
    wire mem_to_reg_mw, reg_write_mw, pcs_mw, hlt_mw;

    // WriteBack Stage
    wire [15:0] writeback_data;

    // --------------------------------------------------------------------------------------------------------- // 

    // Module Inputs //
    wire im_wr, dm_wr, dm_en;
    wire [15:0] alu_in1, alu_in2, data_memory_in, imemory_in;

    // Module Outputs //
    wire [15:0] alu_out, data_memory_out, imemory_out, pc_reg_out, pc_unit_out, rf_out1, rf_out2, dst_data;
    wire dst_reg, alu_src, mem_read, mem_write, mem_to_reg, write_reg, load_higher, load_lower, branch, branch_en, pcs, halt;

    // Logic Outputs //
    wire [15:0] next_addr, imm;

    assign hlt = halt;

    // Fetch Stage
        // Fetch Stage Module
        FetchStage fetch ( .clk(clk), .rst(!rst_n), .branch_en(branch_en_fd), .flags_curr(flags_curr), .curr_pc_fd(curr_pc_fd), .reg1_fd(reg1_fd),
                           .curr_instr_fd(curr_instr_fd), .curr_pc(curr_pc), .next_pc(next_pc), .curr_instr(curr_instr), .flush_fd(flush));

        // Pipe Line Register ( Enable comes from decode stage (stall) )
        FetchDecodeRegister if_id ( .clk(clk), .rst(flush), .enable(), .curr_pc(curr_pc), .next_pc(next_pc), .curr_instr(curr_instr), 
                                    .curr_pc_fd(curr_pc_fd), .next_pc_fd(next_pc_fd), .curr_intr_fd(curr_instr_fd) );
   
    // Decode Stage
        // Decode Stage Module
        DecodeStage decode (.clk,.rst(!rst_n),.enable(),.flags_prev,.flags_curr,.flag_en,.curr_pc_fd,.next_pc_fd,.curr_instr_fd,.stall,
							.flush,.opcode_out,.rs_data(reg1_data),.rt_data(reg2_data),.dst_reg,.branch,.mem_read,.mem_to_reg,.alu_src,
							.mem_write,.write_reg,.imm_out, .opcode_xm,.write_reg_xm,.branch_pc);
        // Pipe Line Register
        DecodeExecuteRegister id_ex (.clk, .rst(!rst_n), .enable(1'b1), .opcode(opcode_out), .decode_imm(imm_out), .IFID_RegRs(rs), .IFID_RegRt(rt), .IFID_RegRd(rd), .dst_reg,
									 .branch, .mem_read,.mem_to_reg,.alu_src,.alu_op_de(de_ex_opcode),.mem_write,.write_reg,.RegDst,.Branch,.MemRead,
									 .MemWrite(mem_write_de), .ALUSrc(alu_src_de), .RegWrite(reg_write_de), .rs_data(rs_de),.rt_data(rt_de),.imm(imm_de));

    // Execute Stage
        // Execute Stage Module
        ExecuteStage execute ( .writeback_data(writeback_data), .reg1_de(rs_de), .reg2_de(rt_de), .reg_write_xm(), .reg_write_mw(), 
                               .mem_write_xm(), .dst_reg_xm(), .dst_reg_mw(), .rs_de(), .rt_de(), .rt_xm(), 
                               .rd_mw(), .rd_xm(), .alu_out_xm(), .mem_read_de(), .mem_write_de(), .load_lower_de(), 
                               .load_higher_de(), .alu_src_de(), .immediate(), .opcode(), .flags(), .enable(), .alu_out() );
        // Pipe Line Register
        ExecuteMemoryRegister ex_mem ( .clk(clk), .rst(!rst_n), .enable(1'b1), .hlt_de(), .mem_read_de(), .mem_write_de(), 
                                       .mem_to_reg_de(), .reg_write_de(), .pcs_de(), .write_reg_de(), .opcode_de(), .rt_in(), 
                                       .next_pc_de(), .reg2_de(), .alu_out1(), .write_reg_xm(), .rt_out(), .opcode_xm(opcode_xm), .hlt_xm(), 
                                       .mem_read_xm(), .mem_write_xm(), .mem_to_reg_xm(), .reg_write_xm(), .pcs_xm(), 
                                       .next_pc_xm(), .reg2_xm(), .alu_out2(), .b_m2m(b_m2m) );
    
    // Memory Stage
        // Memory Stage Module
        MemoryStage memory ( .clk(clk), .rst(!rst_n), .b_m2m(b_m2m), .mem_read_xm(mem_read_xm), .mem_write_xm(mem_write_xm), .writeback_data(writeback_data), 
                             .reg2_xm(reg2_xm), .alu_out_xm(alu_out_xm), .data_out(mem_data) );

        // Pipe Line Register
        MemoryWriteBackRegister mem_wb ( .clk(clk), .rst(!rst_n), .enable(1'b1), .hlt_xm(hlt_xm), .mem_to_reg_xm(mem_to_reg_xm), .reg_write_xm(reg_write_xm), 
                                         .pcs_xm(pcs_xm), .next_pc_xm(next_pc_xm), .mem_data(mem_data), .alu_out_xm(alu_out_xm), .hlt_mw(hlt_mw), .write_reg_mw(write_reg_mw), 
                                         .mem_to_reg_mw(mem_to_reg_mw), .reg_write_mw(reg_write_mw), .pcs_mw(pcs_mw), .next_pc_mw(next_pc_mw), .mem_data_mw(mem_data_mw), .alu_out_mw(alu_out_mw) );

    // WriteBack Stage
        // WriteBack Stage Module
        assign writeback_data = mem_to_reg_mw ? mem_data_mw : pcs_mw ? next_pc_mw : alu_out_mw;
        // Output Halt Signal
        assign hlt = hlt_mw;

    // --------------------------------------------------------------------------------------------------------- // 


endmodule
