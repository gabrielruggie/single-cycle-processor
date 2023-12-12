module CPU (

    input clk,
    input rst_n,
    output hlt,
    output [15:0] pc

);

    // --------------------------------------------------------------------------------------------------------- // 

    // Fetch Stage
    wire [15:0] curr_pc_f, curr_instr_f;
    wire [15:0] curr_pc_fd, curr_instr_fd;

    // Decode Stage
    wire [2:0] flags_decode, flag_en;
    // wire [3:0] write_reg_de, write_reg
	wire [3:0] opcode_de;
	wire [15:0] instruction_de, PCS;
    wire [15:0] reg1_data, reg2_data, imm_d; // Register file outputs
	wire stall;
	wire flush;
	wire [15:0] branch_pc;
	
    wire mem_read_de, mem_to_reg_de, mem_write_de, alu_src_de, reg_write_de, reg_write;
	wire [3:0] rs_de, rt_de, rd_de;
    wire [15:0] reg1_de, reg2_de, imm_de;
    wire [15:0] next_pc_de;
    wire pcs, load_higher, load_lower;
    wire __hlt, hlt_de, pcs_de, load_higher_de, load_lower_de;
    wire dst_reg, alu_src, mem_read, mem_write, mem_to_reg, branch_en;

    // Execute Stage
    wire [3:0] opcode_xm, write_reg_xm; // destination register
    wire [3:0] rt_xm, dst_reg_x;
    wire [2:0] flags_alu;
    wire [15:0] alu_out_xm, mem_data_xm, next_pc_xm, alu_out;
    wire [15:0] reg2_xm;
    wire pcs_xm, reg_write_xm, mem_to_reg_xm, hlt_xm, mem_write_xm, mem_read_xm;
	// wire load_lower_xm, load_higher_xm;

    // Memory Stage
    wire b_m2m;
    wire [3:0] write_reg_mw;
    wire [15:0] mem_data_mw, alu_out_mw, next_pc_mw, mem_data;
    wire mem_to_reg_mw, reg_write_mw, pcs_mw, hlt_mw;

    // WriteBack Stage
    wire [15:0] writeback_data;

    // --------------------------------------------------------------------------------------------------------- // 

    // Fetch Stage
        // Fetch Stage Module
        FetchStage fetch ( .clk(clk), .rst(!rst_n), .branch_en(branch_en), .branch_pc(branch_pc),
                           .stall_de(stall), .curr_instr(curr_instr_f) , .curr_pc_f);

        // Pipe Line Register ( Enable comes from decode stage (stall) )
        FetchDecodeRegister if_id ( .clk(clk), .rst(!rst_n), .enable(!stall), .flush, .curr_pc(curr_pc_f), .curr_instr(curr_instr_f), 
                                    .curr_pc_fd(curr_pc_fd), .curr_instr_fd(curr_instr_fd) );
   
    // Decode Stage
        // Decode Stage Module
        DecodeStage decode (.clk, .rst(!rst_n), .enable(1'b1), .flags_alu(flags_alu), .flag_en, .curr_pc_fd, .curr_instr_fd, .stall,
							.flush, .instruction_de, .rs_data(reg1_data), .rt_data(reg2_data), .dst_reg, .br_en(branch_en), .mem_read, .mem_to_reg, .alu_src,
							.mem_write, .reg_write(reg_write), .imm_d, .opcode_xm, .write_reg_xm, .branch_pc, .hlt(__hlt), .pcs(pcs), .next_pc_d(PCS), 
                            .load_higher(load_higher), .load_lower(load_lower), .writeback_data(writeback_data), .flags(flags_decode));
        // Pipe Line Register
        DecodeExecuteRegister id_ex (.clk, .rst(!rst_n), .enable(1'b1), .instruction_de(instruction_de), .decode_imm(imm_d), .rs_data_d(reg1_data), .rt_data_d(reg2_data), 
									 .rs_de(rs_de), .rt_de(rt_de), .rd_de(rd_de), .mem_read, .mem_to_reg, .alu_src, .opcode_de(opcode_de), .mem_write, 
									 .mem_read_de, .mem_write_de, .alu_src_de, .reg_write_de, .rs_data(reg1_de), .rt_data(reg2_de), .imm_de(imm_de),
                                     .hlt(__hlt), .pcs(pcs), .next_pc_d(PCS), .load_higher(load_higher), .load_lower(load_lower), .hlt_de(hlt_de), .pcs_de(pcs_de), .load_higher_de(load_higher_de),
                                     .load_lower_de(load_lower_de), .next_pc_de(next_pc_de), .mem_to_reg_de, .reg_write);

    // Execute Stage
        // Execute Stage Module
        ExecuteStage execute ( .writeback_data(writeback_data), .reg1_de(reg1_de), .reg2_de(reg2_de), .reg_write_xm(reg_write_xm), .reg_write_mw(reg_write_mw), 
                               .mem_write_xm(mem_write_xm), .dst_reg_xm(write_reg_xm), .dst_reg_mw(write_reg_mw), .rs_de(rs_de), .rt_de(rt_de), .rd_de, .rt_xm(rt_xm), .dst_reg_x, .reg_write_de,
                               .rd_mw(write_reg_mw), .rd_xm(write_reg_xm), .alu_out_xm(alu_out_xm), .mem_read_de(mem_read_de), .mem_write_de(mem_write_de), .load_lower_de(load_lower_de), //.write_reg_xm(write_reg_xm), 
                               .load_higher_de(load_higher_de), .alu_src_de(alu_src_de), .immediate(imm_de), .opcode(opcode_de), .flags(flags_alu), .enable(flag_en), .alu_out(alu_out), .b_m2m(b_m2m));
        // Pipe Line Register
        ExecuteMemoryRegister ex_mem ( .clk(clk), .rst(!rst_n), .enable(1'b1), .hlt_de(hlt_de), .mem_read_de(mem_read_de), .mem_write_de(mem_write_de), 
                                       .mem_to_reg_de(mem_to_reg_de), .reg_write_de(reg_write_de), .pcs_de(pcs_de), .dst_reg_x, .opcode_de(opcode_de), .rt_in(rt_de), 
                                       .next_pc_de(next_pc_de), .reg2_de(reg2_de), .alu_out1(alu_out), .write_reg_xm(write_reg_xm), .rt_out(rt_xm), .opcode_xm(opcode_xm), .hlt_xm(hlt_xm), 
                                       .mem_read_xm(mem_read_xm), .mem_write_xm(mem_write_xm), .mem_to_reg_xm(mem_to_reg_xm), .reg_write_xm(reg_write_xm), .pcs_xm(pcs_xm), 
                                       .next_pc_xm(next_pc_xm), .reg2_xm(reg2_xm), .alu_out2(alu_out_xm)); //.load_lower_de, .load_higher_de);// .load_lower_xm, .load_higher_xm);
    
    // Memory Stage	
        // Memory Stage Module
        MemoryStage memory ( .clk(clk), .rst(!rst_n), .b_m2m(b_m2m), .mem_read_xm(mem_read_xm), .mem_write_xm(mem_write_xm), .writeback_data(writeback_data), 
                             .reg2_xm(reg2_xm), .alu_out_xm(alu_out_xm), .data_out(mem_data) );

        // Pipe Line Register
        MemoryWriteBackRegister mem_wb ( .clk(clk), .rst(!rst_n), .enable(1'b1), .hlt_xm(hlt_xm), .mem_to_reg_xm(mem_to_reg_xm), .reg_write_xm(reg_write_xm), .write_reg_xm(write_reg_xm),
                                         .pcs_xm(pcs_xm), .next_pc_xm(next_pc_xm), .mem_data_xm(mem_data), .alu_out_xm(alu_out_xm), .hlt_mw(hlt_mw), .write_reg_mw(write_reg_mw), 
                                         .mem_to_reg_mw(mem_to_reg_mw), .reg_write_mw(reg_write_mw), .pcs_mw(pcs_mw), .next_pc_mw(next_pc_mw), .mem_data_mw(mem_data_mw), .alu_out_mw(alu_out_mw));

    // WriteBack Stage
        // WriteBack Stage Module
        assign writeback_data = mem_to_reg_mw ? mem_data_mw : 
								pcs_mw ? next_pc_mw : 
								alu_out_mw;
        // Output Halt Signal
        assign hlt = hlt_mw;

    // --------------------------------------------------------------------------------------------------------- // 

        CacheController controller ( .clk(), .rst(), .iwrite(), .iread(), .dwrite(), .dread(), .iaddress(), .daddress(), .data_in(), 
                                     .fetch_stall(), .mem_stall(), .icache_hit(), .dcache_hit(), .instruction_out(), .data_out() );

    // --------------------------------------------------------------------------------------------------------- // 

	// make pc available to test bench
	assign pc = curr_pc_fd;

endmodule