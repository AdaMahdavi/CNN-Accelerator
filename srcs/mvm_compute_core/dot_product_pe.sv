`default_nettype none

/*--- we read 8 wide 16 bit vector operands from BRAM_0 and BRAM_1. 
   each pair of 16-bits is fed onto a dsp slice.
   for optimal routing, we use pcin/pcout ports to achieve cascaded dsp datapath.
   each stage (i : 0 to 7) -> pcout/p == pcin (sum from lower dsp) + A[i]*B[i]
   dsp arithmetic is signed 2's compliment,

*/

/* design note #2: only after wiring everything together I realized data dependancies, 
the queue system used addresses thesse by adding extra latency to handle data dependency hazards. 
*/

module dot_core #(

    parameter int DATA_W  = 16,
    parameter int VEC_W   = 8 ,
    parameter int CARRY_W = 48
)(
    input  wire     clk,
    input  wire   reset,
    
    input  wire i_valid,
    output reg  o_valid,

    input  wire [DATA_W - 1 : 0] i_op_a [VEC_W - 1 : 0],
    input  wire [DATA_W - 1 : 0] i_op_b [VEC_W - 1 : 0],

    //--- might add a bias input later; should fit within C ports in dsp slices with ease.

    output reg  [2*DATA_W + $clog2(VEC_W) - 1 : 0] o_result//--- per [15:0][7:0] operands : we need to add up 8 32 bit mult
                                                    //--- -> 8 x 32 bit = we need 3 extra bits ($clog2(8));

);

    localparam int DSP_STAGES = 4;
    logic [VEC_W + DSP_STAGES - 2 : 0] valid_pipe ;

    logic [CARRY_W - 1 : 0] result;

    assign o_result = result[2*DATA_W + $clog2(VEC_W) - 1 : 0];
    

    logic [CARRY_W - 1 : 0] dsp_carry [VEC_W - 1 : 0];

    assign dsp_carry[0] = '0; //--- first dsp instance doesn't have a pcin
    
    
    
    
    // a bit redundant since i_a[i] would logically require i+1 DATA_W wide registers, so at large VEC_W, we're burning a lot of resources
    // at the scale of this project, that's negligible for the sake of a cleaner loop, but it's absolutely optimizable
    
    /* these work as queues to feed operands into dsp chain in appropriate order. (data dependacy hazard control)
     * ith dsp instance along cascaded chain, needs its respective input fed with i added in cycle latency.
     * so a[0] is fed in immediately, a[1] after 1 clk cycle,... a[7] after 7 cycles (thus why we need VEC_W x VEC_W dim arrays)
     * 
     * in a optimal implementation, we'd want VEC_W arrays intantiated as: logic [DATA_W - 1 : 0] op_a_r_i [i - 1 : 0], 
     * which can be executed with a generate loop, with clocked updates. 
     * but current approach seemed easier and more readable
     
     
     */
    logic [DATA_W - 1 : 0] op_a_r [VEC_W - 1 : 0][VEC_W - 1 : 0] ;
    logic [DATA_W - 1 : 0] op_b_r [VEC_W - 1 : 0][VEC_W - 1 : 0] ;   
    
    
    genvar i;
    
    generate 
        for (i = 0 ; i < VEC_W ; i = i + 1 ) begin 
            
            if (i == VEC_W - 1 )
                dsp48e2_instance dsp (
                
                .i_clk              (clk), 
                .i_rst            (reset), 
                .i_a       (op_a_r[i][i]), 
                .i_b       (op_b_r[i][i]), 
                .i_pcin    (dsp_carry[i]), 
                .o_pcout               (), 
                .o_p             (result)
                );
                
            else 
                dsp48e2_instance dsp (
                    
                .i_clk              (clk), 
                .i_rst            (reset), 
                .i_a       (op_a_r[i][i]), 
                .i_b       (op_b_r[i][i]), 
                .i_pcin    (dsp_carry[i]), 
                .o_pcout (dsp_carry[i+1]), 
                .o_p                   ()       
                );

        end
                
    endgenerate
            
            
    always_ff @(posedge clk) begin
        if (reset) begin

            valid_pipe[0] <= '0;
                    
                    
        //you don't actually need to reset the whole thing since valid pipe is also down. 
        //so I'd just insert in a 0 so we don't accidently register a/b;
                    
            for (int l = 0; l < VEC_W ; l = l + 1) begin
                        
                op_a_r[l][0] <= '0;
                op_b_r[l][0] <= '0;
            end           
                        
        end else begin
                        
                        
            for (int l = 0; l < VEC_W ; l = l + 1) begin
                            
                op_a_r[l][0] <= i_op_a[l];
                op_b_r[l][0] <= i_op_b[l];
                            
                for (int k = 1 ; k < VEC_W ; k = k + 1 ) begin
                                
                    op_a_r[l][k] <= op_a_r[l][k-1];
                    op_b_r[l][k] <= op_b_r[l][k-1];
                                
                end
            end
                        
                        
            valid_pipe <= {valid_pipe[VEC_W + DSP_STAGES - 3 : 0], i_valid};
                        
        end
    end
                
    

    assign o_valid = valid_pipe[VEC_W + DSP_STAGES - 2];

    //--- we can easily use generate for dsps 1-6, dsp 0 and 7 have different pcin/pcout connections
    //--- we can generate use a generate loop for internal pcin/pcout wires; and assign first pcin to 0. 
    //--- at last, we connect last dps's p port to o_result,

endmodule