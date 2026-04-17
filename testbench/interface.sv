interface fifo_interface (input bit clk,input bit rst);
  //write interface
  logic wr_en;
  logic [31:0] wr_data;
  logic [1:0]  priority;
   // Read interface
    logic       rd_en;
    logic [31:0] rd_data;
    logic       rd_valid;
    // Status
    logic full;
    logic empty;
// clocking block of driver
  clocking drv_cb @(posedge clk);
    output wr_data, wr_en,rd_en,priority;
    input rd_data,full,empty,rd_valid;
  endclocking
  
  modport driver_port(clocking drv_cb );// modport of driver
    // clocking block of input monitor
    
    clocking imon_cb @(posedge clk);
      input wr_data,wr_en,rd_en,priority;
    endclocking 
    
    modport imonitor_port( clocking imon_cb);// modport of input monitor
      // clocking block of output monitor
      
      clocking omon_cb @(posedge clk);
        input rd_data,full,empty,rd_valid;
      endclocking
      
      modport omonitor_port(clocking omon_cb);//modport of output monitor
    
endinterface