//////////////////// UART TOP

module all_mod(
input clk, rst, wr, rd,
input rx,
input [2:0] addr,
input [7:0] din,
output tx,
output [7:0] dout
    );
 
   

   wire baud_pulse, pen, thre, stb; 

   wire tx_fifo_pop;
   wire [7:0] tx_fifo_out;
   wire tx_fifo_push;

   wire r_oe, r_pe, r_fe, r_bi;
   wire rx_fifo_push, rx_fifo_pop;
   wire [7:0] rx_out;
   wire [7:0] rx_fifo_out;
  
   wire rx_fifo_empty,rx_fifo_full,rx_fifo_overrun,rx_fifo_underrun;
   wire [7:0]fcr,lcr,lsr;

   /////////////UART Registers
  regs_uart uart_regs_inst (
      .clk (clk),
      .rst (rst),
      .wr_i (wr),
      .rd_i (rd),

      .rx_fifo_empty_i (rx_fifo_empty),
      .rx_oe (rx_fifo_overrun),
      .rx_pe (r_pe),
      .rx_fe (r_fe),
      .rx_bi (r_bi),

      .addr_i (addr),
      .din_i (din),
      .tx_push_o (tx_fifo_push),
      .rx_pop_o (rx_fifo_pop),
      .baud_out (baud_pulse),
      .tx_rst (tx_rst),
      .rx_rst (rx_rst),
      .rx_fifo_threshold (rx_fifo_threshold),
      .dout_o (dout),
      .fcr (fcr),
      .lcr (lcr),
      .lsr (lsr),
      .rx_fifo_in(rx_fifo_out)
  );

   //////////////TX logic
  uart_tx_top uart_tx_inst (
      .clk (clk),
      .rst (rst),
      .baud_pulse (baud_pulse),
      .pen (lcr[3]),
      .thre (1'b0),
      .stb (lcr[2]),
      .sticky_parity (lcr[5]),
      .eps (lcr[4]),
      .set_break (lcr[6]),
      .din (tx_fifo_out),
      .wls (lcr[1:0]),
      .pop (tx_fifo_pop),
      .sreg_empty (), ///sreg empty ier
      .tx (tx)
  );

  ///////////////// TX FIFO
  fifo_top tx_fifo_inst (
      .rst (rst),
      .clk (clk),
      .en (fcr[0]),
      .push_in (tx_fifo_push),
      .pop_in (tx_fifo_pop),
      .din (din),
      .dout (tx_fifo_out),
      .empty (), /// fifo empty ier
      .full (),
      .overrun (),
      .underrun (),
      .threshold (4'h0),
      .thre_trigger ()
  );

   /////////////RX LOGIC

   uart_rx_top uart_rx_inst (
      .clk (clk),
      .rst (rst),
      .baud_pulse (baud_pulse),
      .rx (rx),
      .sticky_parity (lcr[5]),
      .eps (lcr[4]),
      .pen (lcr[3]),
      .wls (lcr[1:0]),
      .push (rx_fifo_push),
      .pe (r_pe),
      .fe (r_fe),
      .bi (r_bi),
      .dout(rx_out)
  );


  ////////////// RX FIFO

  fifo_top rx_fifo_inst (
      .rst (rst),
      .clk (clk),
      .en (fcr[0]),
      .push_in (rx_fifo_push),
      .pop_in (rx_fifo_pop),
      .din (rx_out),
      .dout (rx_fifo_out),
      .empty (rx_fifo_empty), /// fifo empty ier
      .full (rx_fifo_full),
      .overrun (rx_fifo_overrun),
      .underrun (rx_fifo_underrun),
      .threshold (rx_fifo_threshold),
      .thre_trigger ()
  );



endmodule
