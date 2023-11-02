module ExecuteStage (

);

    // Forwarding Logic
    assign A_fwd = 
    assign B_fwd = 

    // ALU Input Logic
    assign A = 
    assign B = 

    // 3. ALU
    ALU alu ( .Opcode(), .ALU_In1(A), .ALU_In2(B), .flags(), .enable(), .ALU_out() );

    // 4. Data Hazard Unit
    DataHazardUnit dhz (  );

endmodule