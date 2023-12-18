module CacheController (

    input clk, rst,
    input iwrite, iread, dwrite, dread,
    input [15:0] iaddress, daddress, data_in,

    output fetch_stall, mem_stall,
    output icache_hit, dcache_hit,
    output [15:0] instruction_out, data_out

);

    wire [63:0] iblock_sel, dblock_sel;
    wire [7:0] iword_sel, dword_sel, word_sel;
    wire [7:0] itag0_nxt, itag1_nxt, dtag0_nxt, dtag1_nxt;
    wire [7:0] itag0_curr, itag1_curr, dtag0_curr, dtag1_curr;

    wire write_tag_array;
    wire stall;
    wire w0, w1;

    wire icache_miss, dcache_miss;
    wire iwrite0, iwrite1, dwrite0, dwrite1;
    wire iwrite_w0, iwrite_w1, dwrite_w0, dwrite_w1;

    wire [15:0] mem_data, mem_address;
    wire [15:0] miss_addr;
    wire [15:0] icache_data_in, dcache_data_in;

    // Come out of caches
    wire [15:0] icache_out0, icache_out1, dcache_out0, dcache_out1;

    wire [7:0] icache_word_sel, dcache_word_sel;

    wire miss_detected, mem_data_vld;
    wire multi_mem_enable, cache_enable;

    // iCache
    dff instr_tag_arr0[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(itag0_nxt), .q(itag0_curr));
    dff instr_tag_arr1[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(itag1_nxt), .q(itag1_curr));
	
	I_Cache i_cache(.clk, .rst, .write_en_0(iwrite0 | write_tag_array), .write_en_1(iwrite1 | write_tag_array), .data_in(icache_data_in), .tag_in_0(itag0_curr), .tag_in_1(itag1_curr), 
					.word(iword_sel), .block_en(iblock_sel), .data_out_0(icache_out0), .data_out_1(icache_out1), .tag_out_0(itag0_nxt), .tag_out_1(itag1_nxt));

    // dCache
    dff data_tag_arr0[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(dtag0_nxt), .q(dtag0_curr) );
    dff data_tag_arr1[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(dtag1_nxt), .q(dtag1_curr) );
	
	D_Cache d_cache(.clk, .rst, .write_en_0(iwrite0 | write_data_array), .write_en_1(iwrite1 | write_data_array), .data_in(dcache_data_in), .tag_in_0(dtag0_curr), .tag_in_1(dtag1_curr), 
					.word(dword_sel), .block_en(dblock_sel), .data_out_0(dcache_out0), .data_out_1(dcache_out1), .tag_out_0(dtag0_nxt), .tag_out_1(dtag1_nxt));

    // Decoders to select correct block
    Decoder6to64 iblock ( .data_in(iaddress[9:4]), .wordline(iblock_sel) );
    Decoder6to64 dblock ( .data_in(daddress[9:4]), .wordline(dblock_sel) );

    // Decoders to select correct word
    Decoder3to8 iword ( .data_in(iaddress[3:1]), .wordline(iword_sel) );
    Decoder3to8 dword ( .data_in(daddress[3:1]), .wordline(dword_sel) );

    // Cache Miss State Machine
    CacheFillFsm cache_fsm ( .clk(clk), .rst(rst), .miss_detected(miss_detected), .mem_data_vld(mem_data_vld), .miss_addr(miss_addr), .w0(w0), .w1(w1), .fsm_busy(stall), .write_data_array(write_data_array), 
                             .write_tag_array(write_tag_array), .mem_address(mem_address), .sel(word_sel) );
        assign miss_detected = cache_enable && ( icache_miss || dcache_miss );

    MultiCycleMemory multi_mem ( .data_out(mem_data), .data_in(data_in), .addr(mem_address), .enable(multi_mem_enable), .wr(multi_mem_write), .clk(clk), .rst(rst), .data_valid(mem_data_vld) );
        assign multi_mem_enable = icache_miss || dcache_miss;
        assign multi_mem_write = dwrite && !stall;

    assign cache_enable = iwrite | iread | dwrite | dread;

    // May be (itag0_nxt[5:0] && itag0_nxt[6]) instead
    assign iwrite0 = ( (iaddress[15:10] == itag0_nxt[5:0]) && itag0_nxt[6] ) && !write_tag_array;
    assign iwrite1 = ( (iaddress[15:10] == itag1_nxt[5:0]) && itag1_nxt[6] ) && !write_tag_array;
    assign iwrite_w0 = ( itag0_curr[6] == 0 ) ? 1'b1 : itag0_curr[7];
    assign iwrite_w1 = ( (itag0_curr[6] == 0) && !iwrite_w0) ? 1'b1 : itag1_curr[7];

    assign dwrite0 = ( (daddress[15:10] == dtag0_nxt[5:0]) && dtag0_nxt[6] ) && !write_tag_array;
    assign dwrite1 = ( (daddress[15:10] == dtag1_nxt[5:0]) && dtag1_nxt[6] ) && !write_tag_array;
    assign dwrite_w0 = ( dtag0_curr[6] == 0 ) ? 1'b1 : dtag0_curr[7];
    assign dwrite_w1 = ( (dtag1_curr[6] == 0) && !dwrite_w0) ? 1'b1 : dtag1_curr[7];

    assign icache_miss = ( !iwrite0 && !iwrite1 ) && (iwrite || iread);
    assign dcache_miss = ( !dwrite0 && !dwrite1 ) && (dwrite || dread);


    assign miss_addr = icache_miss ? iaddress : daddress;

    assign dcache_data_in = dcache_miss ? mem_data : data_in;
    assign icache_data_in = mem_data;

    assign icache_word_sel = !icache_miss ? iword_sel : word_sel;
    // May be iword_sel
    assign dcache_word_sel = !dcache_miss ? dword_sel : word_sel;

    // Output Signals //

    assign fetch_stall = ( iread || iwrite ) && stall;
    assign mem_stall = ( dread || dwrite ) && stall;

    assign icache_hit = !icache_miss && ( iwrite || iread );
    assign dcache_hit = !dcache_miss && ( dwrite || dread );

    assign instruction_out = stall ? 0 : iwrite0 ? icache_out0 : icache_out1;
    assign data_out = stall ? 0 : dwrite0 ? dcache_out0 : dcache_out1;

    // Output Signals //

endmodule