////////////////// UART REG

module regs_uart(
input clk, rst,
input wr_i,rd_i,
input rx_fifo_empty_i,
input rx_oe, rx_pe, rx_fe, rx_bi, 
input [2:0] addr_i,
input [7:0] din_i,

output tx_push_o, ///add new data to TX FIFO
output rx_pop_o, ///read data from RX FIFO

output baud_out, /// baud pulse for both tx and rx

output tx_rst, rx_rst,
output [3:0] rx_fifo_threshold,

output reg [7:0] dout_o,

output reg [7:0] fcr, 
output reg [7:0] lcr,
output reg [7:0] lsr,

input [7:0] rx_fifo_in
);

  reg [7:0] registers[0:7];
  // register[0] -> RHR/THR (dlab=0) or DLB(LSB)(dlab=1).
  // register[1] -> Interupt enable(dlab=0) or DLB(MSB)(dlab =1).
  // register[2] -> Interupt status register(R) or FCR(W).{fifo_trigger,rsvd,enable_dma,dma_mode,tx_fifo_rst,rx_fifo_rst,fifo_enable}
  // register[3] -> LCR(r/w).{dlab,break_control,sticky_parity,eps,parity_en,stop_bit,word_length}
  // register[4] -> modem control register(r/w).
  // register[5] -> LSR.
  // register[6] -> modem status register.
  // register[7] -> scratch pad register.

  //csr_t csr; ///temporary csr
  
  assign tx_fifo_wr = wr_i & (addr_i == 3'b000) & (registers[3][7] == 1'b0);
  assign tx_push_o = tx_fifo_wr;  /// go to tx fifo


  wire rx_fifo_rd;

  assign rx_fifo_rd = rd_i & (addr_i == 3'b000) & (registers[3][7] == 1'b0);
  assign rx_pop_o = rx_fifo_rd; ///read data from rx fifo --> go to rx fifo

  reg [7:0] rx_data;

  always@(posedge clk)
  begin
   if(rx_pop_o)
     begin
     rx_data <= rx_fifo_in;
     end
  end
  
  //----------------------------------------------------------------------
  ///////// Baud Generation Logic

 // div_t dl;
 
 ///////// update dlsb if wr = 1 dlab = 1 and addr = 0
   always @(posedge clk)
     begin
     if ( wr_i && addr_i == 3'b000 && registers[3][7] == 1'b1)
        begin
        registers[0] <= din_i;
        end    
     end
     
  ///////// update dmsb if wr = 1 dlab = 1 and addr = 1
   always @(posedge clk)
     begin
     if ( wr_i && addr_i == 3'b001 && registers[3][7] == 1'b1)
        begin
        registers[1] <= din_i;
        end    
     end 
 
 
   reg update_baud;
   reg [15:0] baud_cnt = 0;
   reg baud_pulse = 0;
  
  ///////sense update in baud values
    always @(posedge clk)
    begin
       update_baud <=  wr_i & (registers[3][7] == 1'b1) & ((addr_i == 3'b000) | (addr_i == 3'b001));
    end  
 
 /////////////// baud counter
 
   always @(posedge clk, posedge rst)
   begin
    if (rst)
      baud_cnt  <= 16'h0;
    else if (update_baud || baud_cnt == 16'h0000)
      baud_cnt <= {registers[1],registers[0]};
    else
      baud_cnt <= baud_cnt -1;
   end

  //generate baud pulse when baud count reaches zero
   always @(posedge  clk)
    begin
      baud_pulse <= |{registers[1],registers[0]} & ~|baud_cnt; 
    end


assign baud_out = baud_pulse; /// baud pulse for both tx and rx 

//-----------------------------------------------------------------------
//-------FCR FIFO CONTROL REGISTER ------------------------------------

   always @(posedge clk, posedge rst)
   begin
     if(rst)
       begin
       registers[2] <= 8'h00;
       end 
      else if (wr_i == 1'b1 && addr_i == 3'h2)
       begin
       registers[2][7:6]  <= din_i[7:6];
       registers[2][3]    <= din_i[3];
       registers[2][2]    <= din_i[2];
       registers[2][1]    <= din_i[1];
       registers[2][0]    <= din_i[0];
       end
       else
       begin
       registers[2][2]    <= 1'b0;
       registers[2][1]    <= 1'b0;
       end
   end


assign tx_rst = registers[2][2];  ////reset tx and rx fifo --> go to tx and rx fifo
assign rx_rst = registers[2][1];

//////// based on value of rx_trigger, generate threshold count for rx fifo

  reg [3:0] rx_fifo_th_count;

  always@(*)
  begin
  if(registers[2][0] == 1'b0) // fcr.fifo_enable
   begin
    rx_fifo_th_count = 4'd0;
   end
  else
   case(registers[2][7:6]) //csr.fcr.rx_trigger
    2'b00: rx_fifo_th_count = 4'd1;
    2'b01: rx_fifo_th_count = 4'd4;
    2'b10: rx_fifo_th_count = 4'd8;
    2'b11: rx_fifo_th_count = 4'd14;
   endcase
  end


assign rx_fifo_threshold = rx_fifo_th_count;   /// -- > go to rx fifo

//-------------------------------------------------------------------------------
////////////////// Line Control Register --> defines format of transmitted data

 // lcr_t lcr;
 reg [7:0] lcr_temp;
 
 //////////// write new data to lcr
 always @(posedge clk, posedge rst)
   begin
     if(rst)
       begin
       registers[3] <= 8'h00;
       end 
     else if (wr_i == 1'b1 && addr_i == 3'h3)
       begin
       registers[3] <= din_i;
       end
   end
 
 //////// read lsr 
 wire read_lcr;

 assign read_lcr = ((rd_i == 1) && (addr_i == 3'h3));
 
always@(posedge clk)
 begin
  if(read_lcr)
   begin
   lcr_temp <= registers[3];
   end
end
 
 //////////////////////////////////////////////////////////
////// ----- LSR  ---> Read only register
 reg [7:0] LSR_temp; 
  
//////////////// update content of LSR register
  always@(posedge clk, posedge rst)
  begin
  if(rst)
  begin
    registers[5] <= 8'h60; //// both fifo and shift register are empty thre = 1 , tempt = 1  // 0110 0000
  end
  else
  begin
    registers[5][0] <=  ~rx_fifo_empty_i; //data_ready
    registers[5][1] <=   rx_oe; // overrun
    registers[5][2] <=   rx_pe; // parity_error
    registers[5][3] <=   rx_fe; // frame_error
    registers[5][4] <=   rx_bi; // break_interrupt
  end
  end


 

/////////////////read register contents

 reg [7:0] lsr_temp; 
 wire read_lsr;
 assign read_lsr = (rd_i == 1) & (addr_i == 3'h5); 
 
 
  always@(posedge clk)
  begin
   if(read_lsr)
   begin
   lsr_temp <= registers[5]; 
   end
  end

///////////////////////////////////////////////////////////
//////////////////Scratch pad register

 always @(posedge clk, posedge rst)
   begin
     if(rst)
       begin
       registers[7] <= 8'h00;
       end 
     else if (wr_i == 1'b1 && addr_i == 3'h7)
       begin
       registers[7] <= din_i;
       end
   end



 reg [7:0] scr_temp; 
 wire read_scr;
 assign read_scr = (rd_i == 1) & (addr_i == 3'h7); 
 
 
 
  always@(posedge clk)
  begin
   if(read_scr)
   begin
     scr_temp <= registers[7]; 
   end
  end

  ////////////////////////////////////////////

  always@(posedge clk)
  begin
  case(addr_i)
    0: dout_o <= registers[3][7] ? registers[0] : rx_data; // if dlab=1, sending divisor lsb.
    1: dout_o <= registers[3][7] ? registers[1] : 8'h00; 
    2: dout_o <= 8'h00; /// iir
    3: dout_o <= lcr_temp; /// lcr
    4: dout_o <= 8'h00; //mcr;
    5: dout_o <= lsr_temp; ///lsr
    6: dout_o <= 8'h00; // msr
    7: dout_o <= scr_temp; // scr
  default: ;
  endcase
  end


  assign fcr = registers[2];
  assign lcr = registers[3];
  assign lsr = registers[5];

endmodule
