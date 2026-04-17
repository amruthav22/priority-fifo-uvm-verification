class fifo_seq_item extends uvm_sequence_item;
  //registration
  `uvm_object_utils(fifo_seq_item)
  function new(string name ="fifo_seq_item");
    super.new(name);
    endfunction
  //inputs to dut
  rand logic [31:0] wr_data;
  rand bit wr_en,rd_en;
  rand bit [1:0] prio;
  //output of dut
  logic [31:0] rd_data;
  logic rd_valid;
  logic full, empty;
  
  
 // constraint addr{wr_data inside {[0:4]};}
//  constraint rd_wr_mix {
  //  wr_en dist {1 := 3, 0 := 7};
//}
  constraint prio_dist {
    prio dist {
      2'b10 := 5,   // HIGH
      2'b01 := 3,   // MED
      2'b00 := 2    // LOW
    };
  }
    
endclass