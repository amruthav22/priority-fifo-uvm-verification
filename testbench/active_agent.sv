class fifo_active_agent extends uvm_agent ;

  `uvm_component_utils(fifo_active_agent)
  virtual fifo_interface vif;
  
  
  fifo_sequencer seqr;
  fifo_driver drv;
  fifo_imonitor imon;
  
  
  function new(string name ="fifo_active_agent", uvm_component parent);
    super.new(name,parent);
   endfunction
 //build_phase
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#( virtual fifo_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(),"can not get interface")
      
    seqr= fifo_sequencer::type_id::create("seqr",this);
    drv= fifo_driver::type_id::create("drv",this);
    imon= fifo_imonitor::type_id::create("imon",this);
     endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(seqr.seq_item_export);
      drv.vif=vif;
      imon.vif=vif;
    endfunction
  
 

endclass