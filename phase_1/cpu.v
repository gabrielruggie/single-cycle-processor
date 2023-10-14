module CPU (

    input clk,
    input rst_n,
    output hlt,
    output [15:0] pc

);

    // Module Inputs //
    wire im_wr, dm_wr, dm_en;
    wire [15:0] alu_in1, alu_in2, data_memory_in, imemory_in;
    wire [2:0] flag_prev, flag_curr, flag_en;
    wire [3:0] rs, rt, rd, dest_reg;

    // Module Outputs //
    wire [15:0] alu_out, data_memory_out, imemory_out, pc_reg_out, pc_unit_out, rf_out1, rf_out2, dst_data;
    wire dst_reg, alu_src, mem_read, mem_write, mem_to_reg, write_reg, load_higher, load_lower, branch, branch_en, pcs, halt;

    // Logic Outputs //
    wire [15:0] next_addr, imm;

    // PC Unit //
    PCUnit pcunit ( .flags(imemory_out[11:9]), .condition_codes(flag_curr), .immediate(imemory_out[8:0]), .branch_en(branch_en), .PC_in(pc_reg_out), .PC_out(pc_unit_out));

    // PC Register //
    PCRegister pcreg ( .clk(clk), .rst(!rst_n), .D(next_addr), .write_en(!hlt), .Q(pc_reg_out) );

    // Control Unit //
    ControlUnit cu ( .dst_reg(dst_reg), .alu_src(alu_src), .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg), 
                        .write_reg(write_reg), .branch_en(branch_en), .branch(branch), .load_higher(load_higher), .load_lower(load_lower), 
                        .hlt(halt) );


    // Instruction Memory //
    InstructionMemory im ( .data_in(imemory_in), .data_out(imemory_out), .addr(pc), .enable(!halt), .wr(im_wr), .clk(clk), .rst(!rst_n) );

    // Flag Register /
    FlagRegister fr ( .clk(clk), .rst(!rst_n), .flag_prev(flag_prev), .flag_curr(flag_curr), .enable(flag_en) );

    // Register File //
    RegisterFile rf ( .clk(clk), .rst(!rst_n), .src_reg1(rs), .src_reg2(rt), .dst_reg(dest_reg), .write_en(write_reg), .dst_data(dst_data), .src_data1(rf_out1), .src_data2(rf_out2) );

    // ALU //
    ALU alu ( .Opcode(imemory_out[15:12]), .ALU_In1(alu_in1), .ALU_In2(alu_in2), .flags(flags), .enable(flag_en));
    // Data Memory
    DataMemory dm ( .data_in(data_memory_in), .data_out(data_memory_out), .addr(alu_out), .enable(dm_en), .wr(dm_wr), .clk(clk), .rst(!rst_n) );

    assign pc = pc_reg_out;
    assign hlt = halt;

    assign next_addr = branch ? rf_out1 : pc_unit_out;

    assign dest_reg = dst_reg ? rd : rt;

    assign rs = load_higher || load_lower ? rd : imemory_out[7:4];
    assign rt = mem_read || mem_write ? imemory_out[11:8] : imemory_out[3:0];

    assign rd = imemory_out[11:8];

    assign imm = mem_read || mem_write ? { {12{1'b0}}, imemory_out[3:0] } << 1 : load_lower ? {{8{1'b0}}, imemory_out[7:0]} : imemory_out[7:0] << 8;

    assign dst_data = mem_to_reg ? data_memory_out : pcs ? pc_unit_out : alu_out;

    assign alu_in1 =    ( mem_read || mem_write) ? rf_out1 & 16'hFFFE :  
                        load_higher ? 16'hFF00 & rf_out1 :
                        load_higher ? 16'h00FF & rf_out1 : rf_out1;
    
    assign alu_in2 = alu_src ? imm : rf_out2;


endmodule