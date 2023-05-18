module muxer (
    input [10:0] x [0:39],
    input [10:0] y [0:39],

    output logic [10:0] which_mem [0:39],
)