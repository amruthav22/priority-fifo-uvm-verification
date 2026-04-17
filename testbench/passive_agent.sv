class fifo_passive_agent extends uvm_agent ;

  `uvm_component_utils(fifo_passive_agent)
  virtual fifo_interface vif;
  
  
  fifo_omonitor omon;
  
  
  function new(string name ="fifo_passive_agent", uvm_component parent);
    super.new(name,parent);
   endfunction
 //build_phase
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#( virtual fifo_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(),"can not get interface")
   
     omon= fifo_omonitor::type_id::create("omon",this);
     endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
     
      omon.vif=vif;
    endfunction
  
 

endclass