
`default_nettype none

/* DESIGN NOTE: Result BRAM - RAMB36E2 in Simple Dual-Port mode (SDP)
   Port A = write (control FSM writes results as they arrive) -> PL clock
   Port B = read  (PS reads results later)                   -> PS clock

   CLOCK_DOMAINS("INDEPENDENT") handles CDC natively - no async FIFO needed.

   Data layout: 64-bit wide, 512 deep
   Address N = result[N], zero-padded to 64 bits
   At VEC_W=4: results are 35b wide (2*16 + clog2(4)), fits in 64b with room to spare.

   Read latency: 2 cycles on port B (1 BRAM + 1 DOB_REG)
   Write latency: 1 cycle on port A

   NOTE: Port A write clock = PL clock
         Port B read clock  = PS clock (wire in when PS integration arrives)
*/

module res_bram #(
    
    parameter int VEC_W   =  4,
    parameter int DATA_W  = 16,
    parameter int ADDR_W  =  9
)(
    // --- PL side (write)
    input  wire                     clk_pl,
    input  wire                   reset_pl,
    input  wire                    i_wr_en,
    input  wire [ADDR_W - 1 : 0] i_wr_addr,
    input  wire       [63:0]     i_wr_data,

    // --- PS side (independent read clock)
    input  wire                     clk_ps,
    input  wire                   reset_ps,
    input  wire                    i_rd_en,
    input  wire [ADDR_W - 1 : 0] i_rd_addr,
    output wire       [63:0]     o_rd_data
);

    wire     [63:0]    rd_data_raw;
    assign o_rd_data = rd_data_raw;

    RAMB36E2 #(

        .CLOCK_DOMAINS   ("INDEPENDENT"),       // PL write clock, PS read clock
        .READ_WIDTH_B               (72),            // 64 data + 8 parity = SDP max
        .WRITE_WIDTH_A              (72),
        .DOA_REG                     (0),            // write port, no output reg needed
        .DOB_REG                     (1),            // recommended by UG573 for timing
        .WRITE_MODE_A      ("NO_CHANGE"),           // most power efficient per UG573
        .WRITE_MODE_B      ("NO_CHANGE"),
        .SIM_COLLISION_CHECK     ("ALL")
    ) res_bram_inst (

        // --- Write port (A) - PL clock
        .CLKARDCLK              (clk_pl),
        .ENARDEN               (i_wr_en),
        .ADDRARDADDR ({i_wr_addr, 6'b0}),     // 15-bit addr, upper 9 bits used at 72b width
        .DINADIN       (i_wr_data[31:0]),      // lower 32 bits
        .DINBDIN      (i_wr_data[63:32]),      // upper 32 bits (SDP uses both A+B data in)
        .DINPADINP                (4'b0),       // parity not used
        .DINPBDINP                (4'b0),
        .WEA                      (4'b0),       // not used in SDP write mode
        .WEBWE                   (8'hFF),       // all 8 byte enables active
        .RSTRAMARSTRAM        (reset_pl),
        .RSTREGARSTREG            (1'b0),       // write port has no output reg (DOA_REG=0)
        .REGCEAREGCE              (1'b0),
        .ADDRENA                  (1'b0),

        // --- Read port (B) - PS clock
        .CLKBWRCLK              (clk_ps),
        .ENBWREN               (i_rd_en),
        .ADDRBWRADDR ({i_rd_addr, 6'b0}),
        .DOUTBDOUT   (rd_data_raw[31:0]),      // lower 32 bits out
        .DOUTADOUT  (rd_data_raw[63:32]),      // upper 32 bits out
        .DOUTPADOUTP                  (),
        .DOUTPBDOUTP                  (),
        .REGCEB                   (1'b1),       // MUST be high when DOB_REG=1
        .RSTRAMB              (reset_ps),
        .RSTREGB              (reset_ps),
        .ADDRENB                  (1'b0),

        // --- unused
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
        //.EN_ECC_PIPE                   (),
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
