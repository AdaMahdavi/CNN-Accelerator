
`default_nettype none


module piped_wire #(

    parameter int STAGES = 6
    
)(
    input    wire      i_clk,
    input    wire     i_wire,
    output   wire   o_p_wire

);

    logic   [STAGES - 1 : 0]    pipe;
    assign o_p_wire = pipe[STAGES-1];


    always_ff @(posedge i_clk) begin

        pipe[0] <= i_wire;
        for (int i = 1; i < STAGES ; i = i + 1) 
            pipe[i] <= pipe[i-1];

    end
    
endmodule