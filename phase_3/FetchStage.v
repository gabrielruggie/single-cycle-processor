module FetchStage (

    input clk, rst, branch_en,
    input [15:0] branch_pc,			
    input cache_stall,			// comes from cache
    input [15:0] curr_instr,	// comes from I_Cache

    output [15:0] curr_pc_f
);

    wire [15:0] next_addr, curr_pc, next_pc;
    wire branch_taken, halt, overflow;

    // calculate next_pc = curr_pc + 2
    cla_16bit CLA0 ( .A(curr_pc), .B(16'h0002), .Sum(next_pc), .Ovfl(overflow), .sub(1'b0) );

    // branch comes from control unit
    assign next_addr = branch_en ? branch_pc : next_pc;
    assign halt = ( (curr_instr[15:12] == 4'hF) & (!branch_en) ) ? 1'b1 : 1'b0;
    assign pc_reg_en = ( halt | cache_stall ) ? 1'b0 : 1'b1;
    
    assign curr_pc_f = curr_pc;

    // PC Register
    PCRegister pcreg ( .clk(clk), .rst(rst), .D(next_addr), .write_en(pc_reg_en), .Q(curr_pc) );

endmodule