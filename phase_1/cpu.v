module CPU (

    input clk,
    input rst_n,
    output hlt,
    output [15:0] pc

);

    // Module Inputs //
    wire im_wr, dm_wr, dm_en;
    wire [15:0] alu_in, data_memory_in, imemory_in;
    wire [2:0] flag_prev, flag_curr, flag_en;
    wire dst_reg, alu_src, mem_read, mem_write, mem_to_reg, write_reg, load_higher, load_lower, branch, branch_en, pcs, halt;

    // Module Outputs //
    wire [15:0] alu_out, data_memory_out, imemory_out, pc_reg_out, pc_unit_out, rf_out1, rf_out2;

    // Logic Outputs //
    wire [15:0] next_addr;

    // PC Unit //
    PCUnit pcunit ( .flags(imemory_out[11:9]), .condition_codes(flag_curr), .immediate(imemory_out[8:0], .branch_en(branch_en), .PC_in(pc_reg_out), .PC_out(pc_unit_out)) );

    // PC Register //
    PCRegister pcreg ( .clk(clk), .rst(!rst_n), .D(next_addr), .write_en(!hlt), .Q(pc_reg_out) );

    // Control Unit //
    ControlUnit cu ( .dst_reg(dst_reg), .alu_src(alu_src), .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg), 
                        .write_reg(write_reg), .branch_en(branch_en), .branch(branch), .load_higher(load_higher), .load_lower(load_lower), 
                        .hlt(halt) );


    // Instruction Memory //
    InstructionMemory im ( .data_in(imemory_in), .data_out(imemory_out), .addr(pc), .enable(!halt), .wr(im_wr), .clk(clk), .rst(!rst_n) );

    // Flag Register /
    FlagRegister fr ( .clk(clk), .rst(!rst_n), .enable(flag_en), .flag_prev(flag_prev), .flag_curr(flag_curr) );

    // Register File //
    RegisterFile rf ( .clk(clk), .rst(!rst_n), .src_reg1(), .src_data2(), .dst_reg(), .write_en(), .dst_data(), .src_data1(rf_out1), .src_data2(rf_out2) );

    // Data Memory
    DataMemory dm ( .data_in(data_memory_in), .data_out(data_memory_out), .addr(alu_out), .enable(dm_en), .wr(dm_wr), .clk(clk), .rst(!rst_n) );

    assign pc = pc_reg_out;
    assign hlt = halt;

    assign next_addr = branch ? rf_out1 : pc_unit_out;


endmodule