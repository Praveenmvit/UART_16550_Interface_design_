module tb;

  reg clk, rst, wr, rd;
  reg rx;
  reg [2:0] addr;
  reg [7:0] din;
  reg [4:0] rx_reg = 5'h05; // rx data need to be send.
  wire tx;
  wire [7:0] dout;

  all_mod dut (clk, rst, wr, rd,rx,addr, din, tx, dout);


  initial begin
    rst = 0;
    clk = 0;
    wr = 0;
    rd = 0;
    addr = 0;
    din = 0;
    rx = 1;
  end

    always #5 clk = ~clk;

  initial begin
    rst = 1'b1;
    repeat(5)@(posedge clk);
    rst = 0;
    /////////////////////////// tx tb /////////////////////////**
    
    ////// dlab = 1;
    @(negedge clk);
    wr   = 1;
    addr = 3'h3;
    din  = 8'b1000_0000;

    ///// lsb latch = 08
    @(negedge clk);
    addr = 3'h0;
    din  = 8'b0000_1000;

    ////// msb latch = 00
    @(negedge clk);
    addr = 3'h1;
    din  = 8'b0000_0000;

    ///// dlab = 0, wls = 00(5-bits), stb = 1 (single bit dur), pen = 1, eps =0(odd), sp = 0
    @(negedge clk);
    addr = 3'h3;
    din  = 8'b0000_1100;
    //// push f0 in fifo (thr, dlab = 0)
    @(negedge clk);
    addr = 3'h0;
    din  = 8'b1111_0000;///10000 -> parity = 0, 
    //remove wr
    @(negedge clk);
    wr = 0;
    
    @(posedge dut.uart_tx_inst.sreg_empty);
    repeat(48) @(posedge dut.uart_tx_inst.baud_pulse);
    
    //////////////////////////// rx tb ///////////////////////**

    ////// dlab = 1;
    @(negedge clk);
    wr   = 1;
    addr = 3'h3;
    din  = 8'b1000_0000;

    ///// lsb latch = 08
    @(negedge clk);
    addr = 3'h0;
    din  = 8'b0000_1000;

    ////// msb latch = 00
    @(negedge clk);
    addr = 3'h1;
    din  = 8'b0000_0000;

    ///// dlab = 0, wls = 00(5-bits), stb = 1 (single bit dur), pen = 1, eps =0(odd), sp = 0
    @(negedge clk);
    addr = 3'h3;
    din  = 8'b0001_1100;
    
    @(negedge clk);
    wr = 0; // stop writing on register.
    
    // data sending logic 
    rx = 1'b0; // sending start.
    repeat(16) @(posedge dut.uart_tx_inst.baud_pulse);
   
    /////// after 16 baud pulse sending 5bit data
    for(int i = 0; i < 5; i++)
    begin
      rx = rx_reg[i];
      repeat(16) @(posedge dut.uart_tx_inst.baud_pulse);
    end
    /////generate parity
    rx = ~^rx_reg;
	repeat(16) @(posedge dut.uart_tx_inst.baud_pulse);
    
    ///// generate stop
    rx = 1;
    repeat(16) @(posedge dut.uart_tx_inst.baud_pulse);

    
    // reading the data from rx fifo.
    @(negedge clk);
    rd = 1;
    addr = 3'h0;
    
    @(negedge clk);
    rd = 0;
    
    
    repeat(8) @(posedge dut.uart_tx_inst.baud_pulse);
    $stop;
  end
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end

endmodule
