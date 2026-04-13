`timescale 1ns / 1ps
`default_nettype none

/* Note:
   PS interface is not yet implemented, so act/wei BRAM write ports and result BRAM
   read port have no external drivers. Without intervention, Vivado traces these
   as unobservable and prunes the entire compute chain during optimization.

   dont_touch on all instances forces the full hierarchy to survive synthesis
   and implementation, allowing timing closure verification of the compute engine
   (DSP cascade, control FSM, memory hierarchy) independent of PS integration.

   This is intentionally narrow scope; sufficient to prove 400MHz timing closure
   and validate the architecture before adding AXI control interfaces and DMA.
*/

module mvm_pl_top #( 
    parameter    int    VEC_W  =  16,
    parameter    int   DATA_W  =  16,
    parameter    int   ADDR_W  =   9,
    parameter    int   RAM_BW  =  64
)(

    //todo: other control ios to be implemented after processing system datapath exists
    input  wire   clk
    //input  wire  reset
);
    //hard wiring since without processing-system-reset this is inaccurate
    wire reset = 1'b0;

//--- Activation BRAM control signals (write) -> disabled until ps interface is added
    wire  act_wr_en = 1'b0;
    wire [ADDR_W - 1 : 0] act_wr_addr = '0;
    wire [RAM_BW - 1 : 0] act_wr_data = '0;

//--- Activation BRAM control signals (read)
    wire  act_rd_en;
    wire [ADDR_W - 1 : 0] act_rd_addr;
    wire [RAM_BW - 1 : 0] act_rd_data;

//--- Weights BRAM control signals (read)
    wire  wei_rd_en;
    wire [ADDR_W - 1 : 0] wei_rd_addr;
    wire [RAM_BW - 1 : 0] wei_rd_data;

 
//--- Weights BRAM control signals (write) -> disabled until ps interface is added
    wire  wei_wr_en = 1'b0;
    wire [ADDR_W - 1 : 0] wei_wr_addr = '0;
    wire [RAM_BW - 1 : 0] wei_wr_data = '0;

//--- Results BRAM control signals (read)
    wire  res_wr_en;
    wire [ADDR_W - 1 : 0] res_wr_addr;
    wire [RAM_BW - 1 : 0] res_wr_data;

//--- Results BRAM control signals (write) -> disabled until ps interface is added
    wire  res_rd_en = 1'b0;
    wire [ADDR_W - 1 : 0] res_rd_addr = '0;
    wire [RAM_BW - 1 : 0] res_rd_data;



//--- Activation bram

    (* dont_touch = "true" *)
    act_bram #(
        .DATA_W          (DATA_W),
        .VEC_W            (VEC_W)
    ) act_bram (
        .clk                (clk),
        .reset            (reset),
        .i_wr_en      (act_wr_en),
        .i_wr_addr  (act_wr_addr),
        .i_wr_data  (act_wr_data),
        .i_rd_en      (act_rd_en),
        .i_rd_addr  (act_rd_addr),
        .o_rd_data  (act_rd_data)
    );


//--- Weight BRAM

    (* dont_touch = "true" *)
    weight_bram #(
        .DATA_W          (DATA_W),
        .VEC_W            (VEC_W)
    ) weight_bram (
        .clk                (clk),
        .reset            (reset),
        .i_wr_en      (wei_wr_en),
        .i_wr_addr  (wei_wr_addr),
        .i_wr_data  (wei_wr_data),
        .i_rd_en      (wei_rd_en),
        .i_rd_addr  (wei_rd_addr),
        .o_rd_data  (wei_rd_data)
    );


//--- MVM Control (instantiates mvm_compute_core internally)

    (* dont_touch = "true" *) (* keep_hierarchy = "yes" *)
    mvm_control #(
        .VEC_W            (VEC_W),
        .DATA_W          (DATA_W),
        .ADDR_W          (ADDR_W),
        .RAM_BW          (RAM_BW),
        .URAM_BW         (RAM_BW)
    ) mvm_control (
        .clk                (clk),
        .reset            (reset),
        .o_rd_act     (act_rd_en),
        .o_act_addr (act_rd_addr),
        .i_act_data (act_rd_data),
        .o_rd_wei     (wei_rd_en),
        .o_wei_addr (wei_rd_addr),
        .i_wei_data (wei_rd_data),
        .o_wr_res     (res_wr_en),
        .o_res_addr (res_wr_addr),
        .o_res_data (res_wr_data)
    );


// Result BRAM

    (* dont_touch = "true" *)
    res_bram #(
        .VEC_W            (VEC_W),
        .DATA_W          (DATA_W),
        .ADDR_W          (ADDR_W)
    ) results_bram (
        .clk_pl             (clk),
        .reset_pl         (reset),
        .i_wr_en      (res_wr_en),
        .i_wr_addr  (res_wr_addr),
        .i_wr_data  (res_wr_data),
        .clk_ps             (clk),
        .reset_ps         (reset),
        .i_rd_en      (res_rd_en),
        .i_rd_addr  (res_rd_addr),
        .o_rd_data  (res_rd_data)
    );

endmodule