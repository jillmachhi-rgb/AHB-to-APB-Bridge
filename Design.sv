timescale 1ns/1ps

interface ahb_apb_if(input logic HCLK);
  logic HRESETn;
  logic [31:0] HADDR;
  logic [31:0] HWDATA;
  logic [31:0] HRDATA;
  logic        HWRITE;
  logic [1:0]  HTRANS;
  logic        HREADY;
  logic        HREADYOUT;
  logic        HRESP;

  logic [31:0] PADDR;
  logic [31:0] PWDATA;
  logic [31:0] PRDATA;
  logic        PWRITE;
  logic        PSEL;
  logic        PENABLE;
  logic        PREADY;
  logic        PSLVERR;
endinterface


module ahb_apb_bridge(ahb_apb_if bus);
  typedef enum logic [1:0] {IDLE, SETUP, ACCESS} state_t;
  state_t state;

  logic [31:0] addr_q, wdata_q;
  logic        write_q;

  always_ff @(posedge bus.HCLK or negedge bus.HRESETn) begin
    if (!bus.HRESETn) begin
      state   <= IDLE;
      addr_q  <= '0;
      wdata_q <= '0;
      write_q <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          if (bus.HTRANS[1] && bus.HREADY) begin
            addr_q  <= bus.HADDR;
            write_q <= bus.HWRITE;
            state   <= SETUP;
          end
        end
        SETUP: begin
          // In this teaching model, write data is available during SETUP.
          wdata_q <= bus.HWDATA;
          state   <= ACCESS;
        end
        ACCESS: begin
          if (bus.PREADY)
            state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end

  always_comb begin
    bus.PADDR    = addr_q;
    bus.PWDATA   = wdata_q;
    bus.PWRITE   = write_q;
    bus.PSEL     = (state == SETUP) || (state == ACCESS);
    bus.PENABLE  = (state == ACCESS);
    bus.HREADYOUT = (state == IDLE) || ((state == ACCESS) && bus.PREADY);
    bus.HRESP    = 1'b0;
    bus.HRDATA   = bus.PRDATA;
  end
endmodule


module apb_memory_slave(ahb_apb_if bus);
  logic [31:0] mem [0:15];
  integer i;

  assign bus.PREADY  = 1'b1;
  assign bus.PSLVERR = 1'b0;
  assign bus.PRDATA  = mem[bus.PADDR[5:2]];

  always_ff @(posedge bus.HCLK or negedge bus.HRESETn) begin
    if (!bus.HRESETn) begin
      for (i = 0; i < 16; i = i + 1)
        mem[i] <= '0;
    end else if (bus.PSEL && bus.PENABLE && bus.PREADY && bus.PWRITE) begin
      mem[bus.PADDR[5:2]] <= bus.PWDATA;
    end
  end
endmodule
