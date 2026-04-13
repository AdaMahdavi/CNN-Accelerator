`timescale 1ns / 1ps

module mvm_compute_core #(

    parameter int DATA_W   = 16,
    parameter int VEC_W    =  8

)(

    input  logic     clk,
    input  logic   reset,

    input  logic   i_run,
    

    input  logic [DATA_W - 1 : 0] i_activation [VEC_W - 1 : 0],

    input  logic [DATA_W - 1 : 0] i_weights_m  [VEC_W - 1 : 0][VEC_W - 1 : 0],
    
    /////
    //will add bias vector control signals soon! 
    /////
    
    output logic o_result_ready,
    output logic [2*DATA_W + $clog2(VEC_W) - 1 : 0]  o_result [VEC_W - 1 : 0]

    );


    /*--- we need a small state machine here : 
    IDLE -> read weights and activation from dedicated brams -> feed dot product instances -> DONE

    */

    genvar i;

    logic [VEC_W - 1 : 0] dot_ivalid, dot_ivalid_next;
    

    logic [VEC_W - 1 : 0] dot_ovalid;
    logic dot_ovalid_com;
    
    assign dot_ovalid_com = (dot_ovalid == {(VEC_W){1'b1}}); //we only proceed to DONE once all dot cores have stable outputs
    
    logic [2*DATA_W + $clog2(VEC_W) - 1 : 0] result_r [VEC_W - 1 : 0];


    always_ff @(posedge clk) begin

        if (reset) begin

            for (int j = 0 ; j < VEC_W ; j = j + 1) 
                o_result[j] <=   '0;
            

            //state           <= IDLE;
            dot_ivalid_next <=   '0;
            dot_ivalid      <=   '0;
            o_result_ready  <=   '0;

        end else begin

            //state      <=      next_state;
            dot_ivalid <= dot_ivalid_next;

            if (i_run) dot_ivalid_next <= {(VEC_W){1'b1}};
            else       dot_ivalid_next <= {(VEC_W){1'b0}};

            if (dot_ovalid_com) begin
                for (int j = 0 ; j < VEC_W ; j = j + 1) 
                o_result[j] <= result_r[j];
            end

            o_result_ready <= dot_ovalid_com;

        end
    end


      

    generate


        for (i = 0; i < VEC_W ; i = i + 1) begin : dot_cores


            dot_core #(
                .DATA_W         (DATA_W),
                .VEC_W           (VEC_W)

            ) dot_inst (
                .clk               (clk),
                .reset           (reset),
                .i_valid (dot_ivalid[i]),
                .o_valid (dot_ovalid[i]),
                .i_op_a (i_weights_m[i]),
                .i_op_b   (i_activation),
                .o_result  (result_r[i])

            );

        end
    endgenerate 

endmodule


