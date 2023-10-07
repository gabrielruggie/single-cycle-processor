module CPU (

    input clk,
    input rst_n,
    output hlt,
    output [15:0] pc

);

    // Module Inputs //
    wire [15:0] alu_in, data_memory_in, imemory_in;

    // Module Outputs //
    wire [15:0] alu_out, data_memory_out, imemory_out;

    // PC Control Unit //

    // CPU Control Unit //

    // Instruction Memory //
    InstructionMemory im ( .data_in(imemory_in), .data_out(imemory_out), .addr(), .enable(), .wr(), .clk(clk), .rst(!rst_n) );

    // Flag Register //

    // Register File //
    RegisterFile rf ( .clk(clk), .rst(!rst_n), .src_reg1(), .src_data2(), .dst_reg(), .write_en(), .dst_data(), .src_data1(), .src_data2() );

    // Data Memory
    DataMemory dm ( .data_in(data_memory_in), .data_out(data_memory_out), .addr(), .enable(), .wr(), .clk(clk), .rst(!rst_n) );

endmodule