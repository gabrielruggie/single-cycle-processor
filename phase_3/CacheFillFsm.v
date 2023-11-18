module CacheFillFsm (

    input clk, rst, miss_detected, mem_data_vld,
    input [15:0] miss_addr,

    output w0, w1,
    output fsm_busy, write_data_array, write_tag_array,
    output [15:0] mem_address,
    output [7:0] sel

);

    wire [15:0] fill_addr;
    wire [3:0] addr_in, addr_out;
    wire [3:0] count_in, count_out;
    wire [3:0] sum;
    wire curr_st, nxt_st, full;
    wire fsm_busy_curr, fsm_busy_nxt;
    wire rst_cntr0, rst_cntr1;

    wire [7:0] sel0, sel1, sel2;

    assign sel0 = 8'h01;
    assign sel1 = fill_addr[1] ? sel0 << 1 : sel0;
    assign sel2 = fill_addr[2] ? sel1 << 2 : sel1;
    
    dff state ( .clk(clk), .rst(rst), .q(curr_st), .d(nxt_st), .wen(1'b1) );
        assign nxt_st = fsm_busy_curr;
    dff busy ( .clk(clk), .rst(rst), .q(fsm_busy_curr), .d(fsm_busy_nxt), .wen(1'b1) );
        assign fsm_busy_curr = curr_st ? full : miss_detected; 
    
    assign full = curr_st && !(count_out == 4'b1011);
    
    cla_4bit inc_count ( .A(count_out), .B(4'b0001), .Sum(sum), .Cin(1'b0), .P(), .G() );
    cla_4bit inc_addr ( .A(addr_out), .B(4'b0001), .Sum(addr_in), .Cin(1'b0), .P(), .G() );

    dff count [3:0] ( .clk(clk), .rst(rst_cntr0), .q(count_out), .d(count_in), .wen(nxt_st) );
        assign rst_cntr0 = rst || count_out == 4'b1011;
        assign count_in = !curr_st ?  1'b1 : miss_detected ? sum : count_out;

    dff addr [3:0] ( .clk(clk), .rst(rst_cntr1), .q(addr_out), .d(addr_in), .wen(mem_data_vld) );
        assign rst_cntr1 = rst || !curr_st;

    assign fill_addr = rst ? 0 : { miss_addr[15:4], addr_out << 1 };

    // Output Signals //

    assign mem_address = rst ? 0 : { miss_addr[15:4], count_out << 1 };
    assign fsm_busy = fsm_busy_nxt || nxt_st;

    assign w0 = count_out[0] == 0;
    assign w1 = count_out[1] == 1;

    assign write_data_array = curr_st && mem_data_vld;
    assign write_tag_array = curr_st && count_out == 4'b1011;

    assign sel = fill_addr[3] ? sel2 << 4 : sel2;

    // Output Signals //  


endmodule