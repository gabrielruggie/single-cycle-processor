module CPU (

    input clk,
    input rst_n,
    output hlt,
    output [15:0] pc

);

    // Fetch Stage
    wire [15:0] curr_pc, next_pc, curr_instr;
    wire [15:0] curr_pc_fd, next_pc_fd, curr_intr_fd;
    wire branch_en_fd, flush;

    // Decode Stage
    wire [2:0] flags_prev, flags_curr, flag_en;
    wire [3:0] rs, rt, rd, dest_reg, write_reg_de;
    wire [15:0] reg1_fd, reg2_fd; // Register file outputs

    // Execute Stage
    wire [3:0] opcode_xm, write_reg_xm; // destination register

    // Memory Stage
    wire b_m2m;
    wire [3:0] write_reg_mw;

    // WriteBack Stage

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
        DecodeStage decode ();
        // Pipe Line Register
        DecodeExecuteRegister id_ex ();

        // ------------ PUT THIS IN DECODE STAGE ---------------- //
        // Hazard Detection Signal (This should be an output of the DecodeStage Module)
        assign stall = (opcode_xm == 4'h8 || opcode_xm[3:2] == 2'b00) && (rs == write_reg_xm) && branch_en_fd;

    // Execute Stage
        // Execute Stage Module
        ExecuteStage execute ( .writeback_data(), .reg1_de(), .reg2_de(), .reg_write_xm(), .reg_write_mw(), 
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
        MemoryStage memory ( .clk(clk), .rst(!rst_n), .b_m2m(b_m2m), .mem_read_xm(), .mem_write_xm(), .writeback_data(), 
                             .reg2_xm(), .alu_out_xm(), .data_out() );

        // Pipe Line Register
        MemoryWriteBackRegister mem_wb ( .clk(clk), .rst(!rst_n), .enable(1'b1), .hlt_xm(), .mem_to_reg_xm(), .reg_write_xm(), 
                                         .pcs_xm(), .next_pc_xm(), .mem_data_xm(), .alu_out_xm(), .hlt_mw(), .write_reg_mw(), 
                                         .mem_to_reg_mw(), .reg_write_mw(), .pcs_mw(), .next_pc_mw(), .mem_data_mw(), .alu_out_mw() );

    // WriteBack Stage
        // WriteBack Stage Module
        WriteBackStage writeback ();

    // PC Unit //
    // PCUnit pcunit ( .flags(imemory_out[11:9]), .condition_codes(flag_curr), .immediate(imemory_out[8:0]), .branch_en(branch_en), .PC_in(pc_reg_out), .PC_out(pc_unit_out));
    //     assign next_addr = branch ? rf_out1 : pc_unit_out;

    // // PC Register //
    // PCRegister pcreg ( .clk(clk), .rst(!rst_n), .D(next_addr), .write_en(!halt), .Q(pc_reg_out) );
    //     assign pc = pc_reg_out;

    // Control Unit //
    ControlUnit cu ( .opcode(imemory_out[15:12]), .dst_reg(dst_reg), .alu_src(alu_src), .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg), 
                        .write_reg(write_reg), .pcs(pcs), .branch_en(branch_en), .branch(branch), .load_higher(load_higher), .load_lower(load_lower), 
                        .hlt(halt) );

    // Instruction Memory //
    // InstructionMemory im ( .data_out(imemory_out), .addr(pc_reg_out), .clk(clk), .rst(!rst_n), .data_in(16'h0000), .enable(1'b1), .wr(1'b0) );

    // Flag Register /
    FlagRegister fr ( .clk(clk), .rst(!rst_n), .flag_prev(flag_prev), .flag_curr(flag_curr), .enable(flag_en) );

    // Register File //
    RegisterFile rf ( .clk(clk), .rst(!rst_n), .src_reg1(rs), .src_reg2(rt), .dst_reg(dest_reg), .write_en(write_reg), .dst_data(dst_data), .src_data1(rf_out1), .src_data2(rf_out2) );
        assign dest_reg = dst_reg ? rd : rt;
        assign dst_data = mem_to_reg ? data_memory_out : pcs ? pc_unit_out : alu_out;
        
        assign rs = load_higher || load_lower ? rd : imemory_out[7:4];
        assign rt = mem_read || mem_write ? imemory_out[11:8] : imemory_out[3:0];
        assign rd = imemory_out[11:8];

    // ALU //
    // ALU alu ( .Opcode(imemory_out[15:12]), .ALU_In1(alu_in1), .ALU_In2(alu_in2), .flags(flag_curr), .enable(flag_en), .ALU_out(alu_out));
    //     assign alu_in1 =    load_higher ? 16'h00FF & rf_out1 :
    //                         load_lower ? 16'hFF00 & rf_out1 :
    //                         mem_read || mem_write  ? rf_out1 & 16'hFFFE : rf_out1;
    
    //     assign alu_in2 = alu_src ? imm : rf_out2;

    // Data Memory
    // DataMemory dm ( .data_in(data_memory_in), .data_out(data_memory_out), .addr(alu_out), .enable(dm_en), .wr(dm_wr), .clk(clk), .rst(!rst_n) );
    
    assign imm = mem_read || mem_write ? { {12{1'b0}}, imemory_out[3:0] } << 1 : 
				  load_lower ? {{8{1'b0}}, imemory_out[7:0]} : 
                  load_higher ? imemory_out[7:0] << 8 : {{12{1'b0}},imemory_out[3:0]};

endmodule
