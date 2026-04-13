`timescale 1ns / 1ps
`default_nettype none

/* DESIGN NOTE: just as ACT BRAM, WEIGHT BRAM uses RAMB36E2 in Simple Dual-Port mode
   Port A = write (load phase, driven by testbench/PS later)
   Port B = read  (control FSM reads one row per cycle into shift register)

   Data layout: 64-bit wide, 512 deep
   Per row: addr N*2+0 = elements [3:0], addr N*2+1 = elements [7:4]
   8 rows x 2 addresses = 16 addresses total, well within 512 depth.

   Sliding window: write 2 new addresses per row update, then fire compute.

   Read latency: 2 cycles (1 BRAM cycle + 1 DOB_REG cycle)
   Issue read address 2 cycles before data is needed in FSM.
*/

module weight_bram #(
    parameter int    DATA_W   =  16,
    parameter int    VEC_W    =   8
)(
    input  wire                 clk,
    input  wire               reset,

    // Write port (load phase)
    input  wire             i_wr_en,
    input  wire [8:0]     i_wr_addr,     // 9 bits effective at 72-bit width
    input  wire [63:0]    i_wr_data,     // 4 elements x 16b per write

    // Read port (control FSM)
    input  wire             i_rd_en,
    input  wire  [8:0]    i_rd_addr,
    output wire  [63:0]   o_rd_data      // 4 elements x 16b per read
);

    wire      [63:0]    rd_data_raw;
    assign  o_rd_data = rd_data_raw;

    RAMB36E2 #(

        .CLOCK_DOMAINS        ("COMMON"),
        .READ_WIDTH_B               (72),       // 64 data + 8 parity = SDP max
        .WRITE_WIDTH_A              (72),
        .DOA_REG                     (0),       // write port, no output reg needed
        .DOB_REG                     (1),       // STRONGLY recommended by UG573 for timing
        .WRITE_MODE_A      ("NO_CHANGE"),       // most power efficient per UG573
        .WRITE_MODE_B      ("NO_CHANGE"),
        .SIM_COLLISION_CHECK     ("ALL")
    ) wei_bram_inst (

        // --- Write port (A)
        .CLKARDCLK                 (clk),
        .ENARDEN               (i_wr_en),
        .ADDRARDADDR ({i_wr_addr, 6'b0}),       // 15-bit addr, upper 9 bits used at 72b width
        .DINADIN       (i_wr_data[31:0]),       // lower 32 bits
        .DINBDIN      (i_wr_data[63:32]),       // upper 32 bits (SDP uses both A+B data in)
        .DINPADINP                (4'b0),       // parity not used
        .DINPBDINP                (4'b0),
        .WEA                      (4'b0),       // not used in SDP write mode
        .WEBWE                   (8'hFF),       // all 8 byte enables active
        .RSTRAMARSTRAM           (reset),
        .RSTREGARSTREG            (1'b0),       // write port has no output reg (DOA_REG=0)
        .REGCEAREGCE              (1'b0),
        .ADDRENA                  (1'b0),       // address enable disabled (ENADDRENA=FALSE default)

        // --- Read port (B)
        .CLKBWRCLK                 (clk),
        .ENBWREN               (i_rd_en),
        .ADDRBWRADDR ({i_rd_addr, 6'b0}),       // same 15-bit format
        .DOUTBDOUT   (rd_data_raw[31:0]),       // lower 32 bits out
        .DOUTADOUT  (rd_data_raw[63:32]),       // upper 32 bits out (SDP uses both A+B data out)
        .DOUTPADOUTP                  (),       // parity out, unused
        .DOUTPBDOUTP                  (),
        .REGCEB                   (1'b1),       // MUST be high when DOB_REG=1 or data won't clock through
        .RSTRAMB                 (reset),
        .RSTREGB                 (reset),
        .ADDRENB                  (1'b0),

        // --- unused (sleep mode)
        .SLEEP                    (1'b0),

        // --- Cascade ports (not used)
        .CASDIMUXA                (1'b0),
        .CASDIMUXB                (1'b0),
        .CASDINA                 (32'b0),
        .CASDINB                 (32'b0),
        .CASDINPA                 (4'b0),
        .CASDINPB                 (4'b0),
        .CASDOMUXA                (1'b0),
        .CASDOMUXB                (1'b0),
        .CASDOMUXEN_A             (1'b0),
        .CASDOMUXEN_B             (1'b0),
        .CASOREGIMUXA             (1'b0),
        .CASOREGIMUXB             (1'b0),
        .CASOREGIMUXEN_A          (1'b0),
        .CASOREGIMUXEN_B          (1'b0),
        .CASDOUTA                     (),
        .CASDOUTB                     (),
        .CASDOUTPA                    (),
        .CASDOUTPB                    (),

        // --- ECC ports (not used)
        //.EN_ECC_PIPE                  (),
        .ECCPIPECE                (1'b0),
        .INJECTDBITERR            (1'b0),
        .INJECTSBITERR            (1'b0),
        .DBITERR                      (),
        .SBITERR                      (),
        .ECCPARITY                    (),
        .RDADDRECC                    (),
        .CASOUTDBITERR                (),
        .CASOUTSBITERR                (),
        .CASINDBITERR             (1'b0),
        .CASINSBITERR             (1'b0)
    );

endmodule