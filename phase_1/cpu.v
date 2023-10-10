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

    // Module Outputs //
    wire [15:0] alu_out, data_memory_out, imemory_out;

    // PC Unit //

    // Control Unit //

    // Instruction Memory //
    InstructionMemory im ( .data_in(imemory_in), .data_out(imemory_out), .addr(pc), .enable(!halt), .wr(im_wr), .clk(clk), .rst(!rst_n) );

    // Flag Register /
    FlagRegister fr ( .clk(clk), .rst(!rst_n), .enable(flag_en), .flag_prev(flag_prev), .flag_curr(flag_curr) );

    // Register File //
    RegisterFile rf ( .clk(clk), .rst(!rst_n), .src_reg1(), .src_data2(), .dst_reg(), .write_en(), .dst_data(), .src_data1(), .src_data2() );

    // Data Memory
    DataMemory dm ( .data_in(data_memory_in), .data_out(data_memory_out), .addr(alu_out), .enable(dm_en), .wr(dm_wr), .clk(clk), .rst(!rst_n) );

endmodule