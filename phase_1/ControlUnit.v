module ControlUnit(

    input [3:0] opcode,
    output dst_reg, alu_src, mem_read, mem_write, mem_to_reg, write_reg, branch_en, branch, pcs, load_higher, load_lower, hlt

);

    // High for instructions: LHB, LLB, ADD, SUB, XOR, RED, PADDSB, SLL, SRA, ROR
    assign dst_reg = (opcode[3] == 1'b0 || opcode[3:1] == 3'b101) ? 1 : 0;

    // High for instructions: SLL, SRA, RORO, LW, SW, LLB, LHB
    assign alu_src = (opcode[3:2] != 2'b00 && opcode[3:2] != 2'b11 && opcode != 4'b0111) ? 1 : 0;

    // High for instructions: LW
    assign mem_read = (opcode == 4'b1000) ? 1 : 0;

    // High for instructions: SW
    assign mem_write = (opcode == 4'b1001) ? 1 : 0;

    // High for instructions: LW
    assign mem_to_reg = (opcode == 4'b1000) ? 1 : 0;

    // High for instructions: ADD, SUB, XOR, RED, SLL, SRA, ROR, PADDSB, LW, SW, LLB, LHB, B, BR, PCS, HLT
    assign write_reg = (opcode[3:1] != 3'b110 || opcode != 4'b1001) ? 1 : 0;

    // High for instructions: B, BR
    assign branch_en = (opcode[3:1] == 3'b110) ? 1 : 0;

    // High for instructions: BR
    assign branch = (opcode == 4'b1101) ? 1 : 0;

    // High for instructions: PCS
    assign pcs = (opcode == 4'b1110) ? 1 : 0;

    // High for instructions: HLT
    assign hlt = (opcode == 4'b1111) ? 1 : 0;

    // High for instructions: LHB
    assign load_higher = (opcode == 4'b1011) ? 1 : 0;

    // High for instructions: LLB
    assign load_lower = (opcode == 4'b1010) ? 1 : 0;

endmodule