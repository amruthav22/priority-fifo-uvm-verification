interface fifo_interface (input bit clk,input bit rst);
  //write interface
  logic wr_en;
  logic [31:0] wr_data;
  logic [1:0]  prio;
   // Read interface
    logic       rd_en;
    logic [31:0] rd_data;
    logic       rd_valid;
    // Status
    logic full;
    logic empty;
// clocking block of driver
  clocking drv_cb @(posedge clk);
    output wr_data, wr_en,rd_en,prio;
    input rd_data,full,empty,rd_valid;
  endclocking
  
  modport driver_port(clocking drv_cb );// modport of driver
    // clocking block of input monitor
    
    clocking imon_cb @(posedge clk);
      input wr_data,wr_en,rd_en,prio;
    endclocking 
    
    modport imonitor_port( clocking imon_cb);// modport of input monitor
      // clocking block of output monitor
      
      clocking omon_cb @(posedge clk);
        input rd_data,full,empty,rd_valid;
      endclocking
      
      modport omonitor_port(clocking omon_cb);//modport of output monitor
    
endinterface

















import uvm_pkg::*;
`include "uvm_macros.svh"

`include "test_pkg.sv"
import fifo_test_pkg::*;





module top;

  bit clk;
  bit rst;

 
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Reset generation
  initial begin
    rst = 1;
    #25;
    rst = 0;
  end

  // Interface instance
  fifo_interface vif (clk, rst);

  // DUT instance
 priority_fifo dut (
    .clk     (clk),
    .rst     (rst),
   .wr_data (vif.wr_data),
    .wr_en   (vif.wr_en),
    .rd_en   (vif.rd_en),
   .rd_data (vif.rd_data),
    .full    (vif.full),
   .empty   (vif.empty),
   .prio(vif.prio),
   .rd_valid(vif.rd_valid)
  );

  // Pass interface to UVM via config DB
  initial begin
    uvm_config_db#(virtual fifo_interface)::set(
      null, "*", "vif", vif
    );

    // Start UVM test
   // run_test("fifo_test");
   // rst=1;
   // #30;
   //rst=0;
    //run_test("high_burst_test");
   // run_test("starvation_seq_test");
    //run_test("mixed_seq_test");
    //run_test("empty_read_seq_test");
    run_test("full_fifo_seq_test");
  end
  
  
  initial begin
    $dumpfile("dump.vcd");           // Name of the output file (can be anything.vcd)
    $dumpvars(0, top);              
   // $finish;
    // $dumpvars;                    // Dump absolutely everything (can be very large/slow)
  end

endmodule
