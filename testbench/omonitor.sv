class fifo_omonitor extends uvm_monitor;
  `uvm_component_utils(fifo_omonitor)
  virtual fifo_interface vif;
  uvm_analysis_port #(fifo_seq_item) omon_ap;
  
  
  function new(string name ="fifo_omonitor", uvm_component parent);
    super.new(name,parent);
    omon_ap=new("omon_ap",this);
  endfunction
  
  
  
  // build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(), "virtual interface not received")
  endfunction
      
      task run_phase(uvm_phase phase);
    fifo_seq_item tr;
    forever begin
      @(vif.omon_cb)
      tr= fifo_seq_item::type_id:: create("tr",this);
      tr.rd_data = vif.rd_data;
      tr.rd_valid=vif.rd_data;
      tr.full = vif.full;
      tr.empty = vif.empty;
      omon_ap.write(tr);
      `uvm_info(get_type_name(),$sformatf("OMON-> data_op : %0d , full : %0b,empty :  %0b",tr.rd_data,tr.full,tr.empty),UVM_MEDIUM);
    end
    endtask
      endclass