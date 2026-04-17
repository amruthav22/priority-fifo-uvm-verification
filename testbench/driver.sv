class fifo_driver extends uvm_driver#(fifo_seq_item);

  `uvm_component_utils(fifo_driver)

  virtual fifo_interface vif;
  function new(string name ="fifo_driver", uvm_component parent);
    super.new(name,parent);
  endfunction
  // build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(), "virtual interface not received")
  endfunction
  //run phase
  task run_phase(uvm_phase phase);
     
    forever begin
      fifo_seq_item req;
      seq_item_port.get_next_item(req);
      vif.wr_data<=req.wr_data;
      vif.wr_en<=req.wr_en;
      vif.rd_en<=req.rd_en;
      vif.prio<=req.prio;
      @(posedge vif.clk);
      seq_item_port.item_done();
      `uvm_info(get_type_name(),$sformatf("DRV-> data_in : %0d,wr_en : %0b,rd_en :  %0b, priotrity:  %0b",req.wr_data,req.wr_en,req.rd_en,req.prio),UVM_MEDIUM);
    
    end  
  endtask
    
  

endclass