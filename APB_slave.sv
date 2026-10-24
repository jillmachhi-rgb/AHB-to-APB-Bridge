
module apb_slave (
    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PSEL,
    input  logic        PENABLE,

    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    logic [31:0] mem [0:15];
    integer i;

    // This simple slave completes each transfer without wait states.
    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;

    // Read data is selected using the word address.
    assign PRDATA = mem[PADDR[5:2]];

    // Write occurs only during a valid APB ACCESS phase.
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (i = 0; i < 16; i = i + 1)
                mem[i] <= 32'b0;
        end
        else if (PSEL && PENABLE && PREADY && PWRITE) begin
            mem[PADDR[5:2]] <= PWDATA;
        end
    end

endmodule
