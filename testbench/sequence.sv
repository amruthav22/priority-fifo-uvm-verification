class fifo_sequence extends uvm_sequence #(fifo_seq_item);
  //registration
  fifo_seq_item req;
  `uvm_object_utils(fifo_sequence)
  function new(string name ="fifo_sequence");
    super.new(name);
    endfunction
  
 virtual task body();
    repeat(20)
      begin
    `uvm_do(req);
      end
    `uvm_info(get_type_name(),$sformatf("randomized inputs for fifo done in sequnce"),UVM_MEDIUM)
  endtask
  
endclass


class high_burst_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(high_burst_seq)
  function new(string name = "high_burst_seq");
    super.new(name);
  endfunction
  virtual task body();
    fifo_seq_item req;
    
    // Phase 1: Write HIGH priority items only
    repeat (10) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 1;
        rd_en == 0;      // no reads during fill
        prio  == 2'b10;
      });
      finish_item(req);
    end
    
    // Phase 2: Drain and verify ordering
    repeat (10) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 0;
        rd_en == 1;      // reads only — scoreboard verifies order
      });
      finish_item(req);
    end
  endtask
endclass



class starvation_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(starvation_seq)
  function new(string name = "starvation_seq");
    super.new(name);
  endfunction
  virtual task body();
    fifo_seq_item req;
    
    // Step 1: Write some MED priority items first
    repeat (5) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 1;
        rd_en == 0;
        prio  == 2'b01; // MED
      });
      finish_item(req);
    end
    
    // Step 2: Flood with HIGH writes + reads
    // HIGH items should come out, MED should be stuck waiting
    repeat (20) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 1;
        rd_en == 1;
        prio  == 2'b10; // HIGH - scoreboard verifies HIGH comes out not MED
      });
      finish_item(req);
    end
    
    
    // NOW MED items should finally come out
    // If DUT dropped them -> scoreboard fires "Unexpected rd_valid, queues empty"
    // or MISMATCH if wrong data
    repeat (10) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 0;
        rd_en == 1;
      });
      finish_item(req);
    end
  endtask
endclass



//  three priority levels get exercised

class mixed_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(mixed_seq)
  function new(string name = "mixed_seq");
    super.new(name);
  endfunction
  virtual task body();
    fifo_seq_item req;
    repeat (100) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en dist {1:=6, 0:=4};
        rd_en dist {1:=5, 0:=5};
        // Making  sure all priority levels get hit
        prio  dist {2'b10:=5, 2'b01:=3, 2'b00:=2};
      });
      finish_item(req);
    end
  endtask
endclass


class empty_read_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(empty_read_seq)
  function new(string name = "empty_read_seq");
    super.new(name);
  endfunction
  virtual task body();
    fifo_seq_item req;
    // Read from completely empty FIFO
    // Scoreboard should NOT see any rd_valid
    // If DUT asserts rd_valid here -> bug caught immediately
    repeat (5) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 0;
        rd_en == 1;
      });
      finish_item(req);
    end
  endtask
endclass
class full_fifo_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(full_fifo_seq)
  function new(string name = "full_fifo_seq");
    super.new(name);
  endfunction
  virtual task body();
    fifo_seq_item req;
    // Step 1: Fill to full
    repeat (20) begin  // adjust repeat count to match your FIFO depth
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 1;
        rd_en == 0;
        prio  == 2'b10;
      });
      finish_item(req);
    end
    // Step 2: Write while full — DUT should drop or ignore
    repeat (5) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 1;
        rd_en == 0;
      });
      finish_item(req);
    end
    // Step 3: Drain — existing data must be uncorrupted
    repeat (20) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        wr_en == 0;
        rd_en == 1;
      });
      finish_item(req);
    end
  endtask
endclass