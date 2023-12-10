module CacheController (

    input clk, rst,
    input iwrite, iread, dwrite, dread,
    input [15:0] iaddress, daddress, data_in,

    output fetch_stall, mem_stall,
    output ihit, dhit,
    output [15:0] instruction_out, data_out

);

    wire [63:0] iblock_sel, dblock_sel;
    wire [7:0] ioffset_sel, doffset_sel;
    wire [7:0] itag0_nxt, itag1_nxt, dtag0_nxt, dtag1_nxt;
    wire [7:0] itag0_curr, itag1_curr, dtag0_curr, dtag1_curr;

    wire write_tag_array;

    // iCache
    dff instr_tag_arr0[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(itag0_nxt), .q(itag0_curr));
    dff instr_tag_arr1[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(itag1_nxt), .q(itag1_curr));

    // dCache
    dff data_tag_arr0[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(dtag0_nxt), .q(dtag0_curr) );
    dff data_tag_arr1[7:0] ( .clk(clk), .rst(rst), .wen(1'b1), .d(dtag1_nxt), .q(dtag1_curr) );

    // Decoders to select correct block
    Decoder6to64 iblock ( .data_in(iaddress[9:4]), .wordline(iblock_sel) );
    Decoder6to64 dblock ( .data_in(daddress[9:4]), .wordline(dblock_sel) );

    // Decoders to select correct word
    Decoder3to8 ioffset ( .data_in(iaddress[3:1]), .wordline(ioffset_sel) );
    Decoder3to8 doffset ( .data_in(daddress[3:1]), .wordline(doffset_sel) );

    // Cache Miss State Machine
    CacheFillFsm cache_fsm ( .clk(clk), .rst(rst), .miss_detected(), .mem_data_vld(), .miss_addr(), .w0(), .w1(), .fsm_busy(), .write_data_array(), 
                             .write_tag_array(), .mem_address(), .sel() );

    MultiCycleMemory multi_mem ( .data_out(), .data_in(), .addr(), .enable(), .wr(), .clk(), .rst(), .data_valid() );

    assign cache_enable = iwrite | iread | dwrite | dread;

    // May be (itag0_nxt[5:0] && itag0_nxt[6]) instead
    assign iwrite0 = ( (iaddress[15:10] == itag0_nxt[5:0]) && itag0_nxt[6] ) && !write_tag_array;
    assign iwrite1 = ( (iaddress[15:10] == itag1_nxt[5:0]) && itag1_nxt[6] ) && !write_tag_array;
    assign iwrite_w0 = ( itag0_curr[6] == 0 ) ? 1'b1 : itag0_curr[7];
    assign iwrite_w1 = ( (itag0_curr[6] == 0) && !iwrite_w0) ? 1'b1 : itag1_curr[7];

    assign dwrite0 = ( (daddress[15:10] == dtag0_nxt[5:0]) && dtag0_nxt[6] ) && !write_tag_array;
    assign dwrite0 = ( (daddress[15:10] == dtag1_nxt[5:0]) && dtag1_nxt[6] ) && !write_tag_array;
    assign dwrite_w0 = ( dtag0_curr[6] == 0 ) ? 1'b1 : dtag0_curr[7];
    assign dwrite_w1 = ( (dtag1_curr[6] == 0) && !dwrite_w0) ? 1'b1 : dtag1_curr[7];

endmodule
