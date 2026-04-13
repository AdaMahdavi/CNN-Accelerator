
`timescale 1ns / 1ps
`default_nettype none

/* DESIGN NOTE: MVM Control Unit
   No PS interface yet; starts automatically on reset deassertion.
   Runs continuously:
     - Weight BRAM: new row read every clock cycle (sliding window)
     - Activation BRAM: new vector read every VEC_W cycles (one per full matrix)

   mvm_compute_core instantiated internally.
   Results written to URAM as they arrive.

   Key localparams:
   - LOAD_CYCLES    : BRAM reads to assemble one full vector (1 at VEC_W=4, 2 at VEC_W=8)
   - PIPELINE_DEPTH : cycles from i_run to first valid result (VEC_W + DSP_STAGES - 2)

   FSM:
   INIT      — fill pipeline: load first activation + VEC_W weight rows, wait for pipeline
   STREAM    — steady state: new weight row every cycle, new activation every VEC_W cycles
   WRITE_RES — write VEC_W results to URAM when result_ready fires
*/

module mvm_control #(

    parameter int VEC_W   =  4,
    parameter int DATA_W  = 16,
    parameter int ADDR_W  =  9,
    parameter int RAM_BW  = 64,
    parameter int URAM_BW = 64
)(
    input  wire         clk,
    input  wire         reset,

    // --- activation BRAM read port
    output reg                    o_rd_act,
    output reg  [ADDR_W - 1 : 0] o_act_addr,
    input  wire [RAM_BW - 1 : 0] i_act_data,

    // --- weight BRAM read port
    output reg                    o_rd_wei,
    output reg  [ADDR_W - 1 : 0] o_wei_addr,
    input  wire [RAM_BW - 1 : 0] i_wei_data,

    // --- URAM write port
    output reg                    o_wr_res,
    output reg  [ADDR_W - 1 : 0] o_res_addr,
    output reg  [URAM_BW - 1: 0] o_res_data
);

    
    // Derived parameters
    
    localparam int LOAD_CYCLES    = (VEC_W * DATA_W) / RAM_BW;
    localparam int DSP_STAGES     = 4;
    localparam int PIPELINE_DEPTH = VEC_W + DSP_STAGES - 2;
    localparam int RES_W          = 2 * DATA_W + $clog2(VEC_W);

    
    // Internal wires to compute core

    reg                    core_run;
    reg  [DATA_W - 1 : 0]  core_activation [VEC_W - 1 : 0];
    reg  [DATA_W - 1 : 0]  core_weights_m  [VEC_W - 1 : 0][VEC_W - 1 : 0];
    wire                   core_result_ready;
    wire [RES_W  - 1 : 0]  core_result     [VEC_W - 1 : 0];

    // Compute core instance

    mvm_compute_core #(
        .DATA_W (DATA_W),
        .VEC_W  (VEC_W)
    ) mvm_core (
        .clk            (clk),
        .reset          (reset),
        .i_run          (core_run),
        .i_activation   (core_activation),
        .i_weights_m    (core_weights_m),
        .o_result_ready (core_result_ready),
        .o_result       (core_result)
    );

    // FSM

    typedef enum logic [1:0] {
        INIT      = 2'd0,    // fill pipeline; load first act + VEC_W weight rows
        STREAM    = 2'd1,    // steady state
        WRITE_RES = 2'd2     // write results to URAM
    } state_t;

    state_t state, next_state;

    // Counters

    reg [$clog2(PIPELINE_DEPTH+1) - 1 : 0] init_cnt;   // counts cycles during INIT
    reg [$clog2(VEC_W+1)          - 1 : 0] act_cnt;    // counts cycles between activation reads
    reg [$clog2(VEC_W+1)          - 1 : 0] wei_row;    // current weight row address
    reg [$clog2(VEC_W+1)          - 1 : 0] res_cnt;    // counts results written to URAM

    always_comb begin
        next_state = state;
        case (state)
            INIT:      next_state = (init_cnt == PIPELINE_DEPTH - 1) ? STREAM    : INIT;
            STREAM:    next_state = core_result_ready                 ? WRITE_RES : STREAM;
            WRITE_RES: next_state = (res_cnt == VEC_W - 1)           ? STREAM    : WRITE_RES;
            default:   next_state = INIT;
        endcase
    end

    always_ff @(posedge clk) begin

        if (reset) state <=       INIT;
        else       state <= next_state;
    end




    always_ff @(posedge clk) begin
        if (reset) begin

            init_cnt   <= '0;
            act_cnt    <= '0;
            wei_row    <= '0;
            res_cnt    <= '0;

            core_run   <= '0;
            o_rd_act   <= '0;
            o_rd_wei   <= '0;
            o_act_addr <= '0;
            o_wei_addr <= '0;
            o_wr_res   <= '0;
            o_res_addr <= '0;
            o_res_data <= '0;

            for (int j = 0; j < VEC_W; j++) begin
                core_activation[j] <= '0;
                for (int k = 0; k < VEC_W; k++)
                    core_weights_m[j][k] <= '0;
            end

        end else begin

            // defaults
            o_rd_act <= '0;
            o_rd_wei <= '0;
            o_wr_res <= '0;

            case (state)

                INIT: begin
                    // Read first activation and first VEC_W weight rows
                    // let pipeline fill before entering STREAM
                    core_run   <= 1'b1;
                    o_rd_act   <= 1'b1;
                    o_rd_wei   <= 1'b1;
                    o_act_addr <= '0;                   // first activation vector
                    o_wei_addr <= init_cnt; // walk weight rows during init
                    init_cnt   <= init_cnt + 1;

                    // TODO: pack i_act_data and i_wei_data into core_activation
                    // and core_weights_m accounting for 2-cycle BRAM latency
                end

                STREAM: begin
                    // New weight row every cycle
                    o_rd_wei   <= 1'b1;
                    o_wei_addr <= wei_row;
                    wei_row    <= wei_row + 1;

                    // New activation every VEC_W cycles
                    act_cnt    <= act_cnt + 1;
                    if (act_cnt == VEC_W - 1) begin
                        o_rd_act   <= 1'b1;
                        o_act_addr <= o_act_addr + 1;
                        act_cnt    <= '0;
                    end

                    // TODO: pack incoming BRAM data into core_weights_m and core_activation
                    // accounting for 2-cycle BRAM read latency
                end

                WRITE_RES: begin
                    // Write one result per cycle to URAM
                    o_wr_res   <= 1'b1;
                    o_res_addr <= res_cnt;
                    o_res_data <= URAM_BW'(core_result[res_cnt]);
                    res_cnt    <= res_cnt + 1;

                    // keep streaming weights while writing results
                    o_rd_wei   <= 1'b1;
                    o_wei_addr <= wei_row;
                    wei_row    <= wei_row + 1;
                end

            endcase
        end
    end

endmodule