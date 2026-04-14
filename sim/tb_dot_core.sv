`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2026 03:04:06 PM
// Design Name: 
// Module Name: tb_dot_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_dot_core;

    localparam int DATA_W  = 16;
    localparam int VEC_W   = 8 ;


    localparam CLK_P = 2; //(500mhz)

    logic clk, reset, i_valid, o_valid;

    logic signed [DATA_W - 1 : 0] i_op_a [VEC_W - 1 : 0];
    logic signed [DATA_W - 1 : 0] i_op_b [VEC_W - 1 : 0];

    logic [2*DATA_W + $clog2(VEC_W) - 1 : 0] o_result;

    logic [6:0] counter;


    dot_core DUT (

        .clk           (clk),
        .reset       (reset),
        .i_valid   (i_valid),
        .o_valid   (o_valid),
        .i_op_a     (i_op_a),
        .i_op_b     (i_op_b),
        .o_result (o_result)
    );


      always @(posedge clk)
        if (reset) counter <= '0;
        else       counter <= counter + 1'b1;


    //clk
    always #(CLK_P/2) clk = ~clk;

    


    task apply_vector (

        input logic signed [DATA_W - 1 : 0] a [VEC_W - 1 : 0],
        input logic signed [DATA_W - 1 : 0] b [VEC_W - 1 : 0]
    );
        i_op_a = a;
        i_op_b = b;
    
        i_valid = 1;
        @(posedge clk);
        //@(posedge clk);

    
        // i_valid = 0;
        // @(posedge clk);

    endtask



    //initialization

    initial begin
        clk = 0;
        reset = 1;
        i_valid = 0;

        foreach (i_op_a[i]) i_op_a[i] = '0;
        foreach (i_op_b[i]) i_op_b[i] = '0;


        @(posedge clk);
    
        @(posedge clk);
        reset = 0;


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        ); 
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );
        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd5},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd5}
        );

        reset = 1;
        i_valid = 0;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, 16'sd1, 16'sd2}
        );

        apply_vector (
        '{16'sd8, 16'sd7, 16'sd9, 16'sd2, 16'sd6, 16'sd5, 16'sd3, 16'sd5},
        '{16'sd0, 16'sd1, 16'sd2, 16'sd50, 16'sd4, 16'sd0, 16'sd1, 16'sd5}
        );


        apply_vector (
        '{16'sd8, 16'sd7, 16'sd6, 16'sd5, 16'sd4, 16'sd3, 16'sd2, 16'sd2},
        '{16'sd5, 16'sd3, 16'sd1, 16'sd1, 16'sd1, 16'sd1, 16'sd1, 16'sd2}
        );                                                                                                       
        //repeat (VEC_W) @(posedge clk);
        $finish;
     end

     initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, DUT);
end
     
endmodule
