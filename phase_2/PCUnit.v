module PCUnit (

    input [2:0] flags, condition_codes,
    input [8:0] immediate,
    input branch_en,
    input [15:0] PC_in,
    output [15:0] PC_out,
    output branch_taken

);

    wire [15:0] taken, not_taken, sign_ext_imm, shift_left;
    reg [15:0] target_addr;
    wire overflow;
    reg branch;

    assign sign_ext_imm = { {7{immediate[8]}}, immediate[8:0] };
    assign shift_left = sign_ext_imm << 1;

    cla_16bit CLA0 ( .A(PC_in), .B(16'h0002), .Sum(not_taken), .Ovfl(overflow), .sub(1'b0) );   // Calculates not_taken address
    cla_16bit CLA1 ( .A(not_taken), .B(shift_left), .Sum(taken), .Ovfl(overflow), .sub(1'b0) ); // Calculates taken address

    always @(*) begin

        case (condition_codes) 

            3'b000: target_addr = flags[1] ? not_taken : taken;                                 // Case when: Z=0
            3'b001: target_addr = flags[1] ? taken : not_taken;                                 // Case when: Z=1
            3'b010: target_addr = flags[1] & flags[2] ? not_taken : taken;                     // Case when: N=0 and Z=0
            3'b011: target_addr = flags[2] ? taken : not_taken;                                 // Case when: N=1
            3'b100: target_addr = flags[1] | (~flags[1] & ~flags[2]) ? taken : not_taken;     // Case when: Z=1 or N=0 and Z=0
            3'b101: target_addr = flags[1] & flags[2] ? taken : not_taken;                     // Case when: N=1 or Z=1
            3'b110: target_addr = flags[0] ? taken : not_taken;                                 // Case when: V=1
            default: target_addr = taken;                                                       // Unconditional Branch


        endcase

    end

    always @(*) begin
    
        case (condition_codes) 
        
            3'b000: branch = flags[1] ? 1'b0 : 1'b1;
            3'b001: branch = flags[1] ? 1'b1 : 1'b0;
            3'b010: branch = (flags[2] && flags[1]) ? 1'b0 : 1'b1;
            3'b011: branch = flags[2] ? 1'b1 : 1'b0;
            3'b100: branch = (flags[1] || (!flags[1] && !flags[2])) ? 1'b1 : 1'b0;
            3'b101: branch = (flags[1] || flags[2]) ? 1'b1 : 1'b0;
            3'b110: branch = flags[0] ? 1'b1 : 1'b0;
            default: branch = 1'b1;

        endcase

    end

    assign PC_out = branch_en ? target_addr : not_taken;
    assign branch_taken = branch_en ? branch : 1'b0;

endmodule

