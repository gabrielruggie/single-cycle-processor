module FetchStage (

    input clk, rst, enable, halt, branch_en,
    input [2:0] flags_curr,

    output [15:0] curr_pc_fd, next_pc_fd, curr_instr_fd

);

    wire branch_taken;
    wire [15:0] curr_pc, next_pc, curr_instr;
    wire [15:0] __curr_pc_fd, __next_pc_fd, __curr_instr_fd;

    assign next_addr = branch ? rf_out1 : pc_unit_out;
    assign pc_in = branch_en ? curr_pc_fd : curr_pc;
    assign halt = (curr_instr[15:12] == 4'hF && !branch_taken);

    // Pipeline Register
    FetchDecodeRegister if_id ( .clk(clk), .rst(rst), .enable(enable), .curr_pc(curr_pc), .next_pc(next_pc), .curr_instr(curr_instr), 
                                .curr_pc_fd(__curr_pc_fd), next_pc_fd(__next_pc_fd), .curr_instr_fd(__curr_instr_fd) 
                                );

    // PC Control Unit
    // Add branch policy to this
    PCUnit pcunit ( .flags(__curr_instr_fd[11:9]), .condition_codes(flags_curr), .immediate(__curr_instr_fd[8:0]), .branch_en(branch_en), .PC_in(pc_in), .PC_out(next_pc));

    // PC Register
    PCRegister pcreg ( .clk(clk), .rst(!rst_n), .D(next_addr), .write_en(!halt), .Q(curr_pc) );

    // Instruction Memory
    InstructionMemory im ( .data_out(curr_instr), .addr(curr_pc), .clk(clk), .rst(!rst_n), .data_in(16'h0000), .enable(1'b1), .wr(1'b0) );

    assign curr_pc_fd = __curr_pc_fd;
    assign next_pc_fd = __next_pc_fd;
    assign curr_instr_fd = __curr_instr_fd;

endmodule