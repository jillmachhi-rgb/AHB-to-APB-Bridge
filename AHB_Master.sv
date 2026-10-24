
module ahb_master (
    input  logic        HCLK,
    input  logic        HRESETn,

    output logic [31:0] HADDR,
    output logic [31:0] HWDATA,
    output logic        HWRITE,
    output logic [1:0]  HTRANS,
    output logic        HREADY,
    input  logic        HREADYOUT,
    input  logic [31:0] HRDATA,
    input  logic        HRESP
);

    localparam logic [1:0] IDLE   = 2'b00;
    localparam logic [1:0] NONSEQ = 2'b10;

    typedef enum logic [2:0] {
        START,
        WRITE_ADDR,
        WRITE_DATA,
        READ_ADDR,
        READ_DATA,
        DONE
    } state_t;

    state_t state;

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state  <= START;
            HADDR  <= '0;
            HWDATA <= '0;
            HWRITE <= 1'b0;
            HTRANS <= IDLE;
            HREADY <= 1'b1;
        end else begin
            case (state)

                START: begin
                    HADDR <= 32'h00000010;
                    HWRITE <= 1'b1;
                    HTRANS <= NONSEQ;
                    state <= WRITE_ADDR;
                end

                WRITE_ADDR: begin
                    if (HREADYOUT) begin
                        HWDATA <= 32'h12345678;
                        HTRANS <= IDLE;
                        state <= WRITE_DATA;
                    end
                end

                WRITE_DATA: begin
                    HADDR <= 32'h00000010;
                    HWRITE <= 1'b0;
                    HTRANS <= NONSEQ;
                    state <= READ_ADDR;
                end

                READ_ADDR: begin
                    if (HREADYOUT) begin
                        HTRANS <= IDLE;
                        state <= READ_DATA;
                    end
                end

                READ_DATA: begin
                    if (HREADYOUT) begin
                        $display("AHB READ DATA = %h", HRDATA);
                        if (HRESP)
                            $display("AHB ERROR RESPONSE");
                        state <= DONE;
                    end
                end

                DONE: begin
                    HTRANS <= IDLE;
                end

                default: state <= START;
            endcase
        end
    end

endmodule
