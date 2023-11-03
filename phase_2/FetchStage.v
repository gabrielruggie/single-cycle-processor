module FetchStage (

    input clk, rst, branch_en,
    input [2:0] flags_curr,
    input branch_fd,
    input [15:0] reg1_fd, curr_pc_fd, curr_instr_fd,

    output [15:0] curr_pc, next_pc, curr_instr,
    output flush_fd

);

    wire [15:0] next_addr, pc_in;
    wire branch_taken, halt;

    // branch_fd comes from control unit
    assign next_addr = branch_fd ? reg1_fd : next_pc;
    assign pc_in = branch_en ? curr_pc_fd : curr_pc;
    assign halt = (curr_instr[15:12] == 4'hF && !branch_taken);


    // PC Register
    PCRegister pcreg ( .clk(clk), .rst(!rst_n), .D(next_addr), .write_en(!halt), .Q(curr_pc) );

    // PC Control Unit
    PCUnit pcunit ( .flags(curr_instr_fd[11:9]), .condition_codes(flags_curr), .immediate(curr_instr_fd[8:0]), 
                    .branch_en(branch_en), .PC_in(pc_in), .PC_out(next_pc), .branch_taken());

    // Instruction Memory
    InstructionMemory im ( .data_out(curr_instr), .addr(curr_pc), .clk(clk), .rst(!rst_n), .data_in(16'h0000), 
                            .enable(1'b1), .wr(1'b0) );

    assign flush_fd = branch_taken;

endmodule