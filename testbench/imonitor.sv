class fifo_imonitor extends uvm_monitor;
  `uvm_component_utils(fifo_imonitor)
  virtual fifo_interface vif;
  
  
  uvm_analysis_port #(fifo_seq_item) imon_ap;
  function new(string name ="fifo_imonitor", uvm_component parent);
    super.new(name,parent);
    imon_ap=new("imon_ap",this);
  endfunction
  
  
  // build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(), "virtual interface not received")
  endfunction
      
      task run_phase(uvm_phase phase);
    fifo_seq_item req;
    forever begin
      @(vif.imon_cb);
      if (vif.rst)continue;
      req= fifo_seq_item::type_id:: create("req",this);
      req.wr_data = vif.imon_cb.wr_data;
      req.wr_en = vif.imon_cb.wr_en;
      req.prio=vif.imon_cb.prio;
      req.rd_en = vif.imon_cb.rd_en;
      imon_ap.write(req);
      `uvm_info(get_type_name(),$sformatf("IMON-> wr_data : %0d , wr_en : %0b ,priority:%0b",req.wr_data,req.wr_en,req.prio),UVM_MEDIUM);
    end
    endtask
      endclass
    
    
   