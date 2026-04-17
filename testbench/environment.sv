class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)
  
  fifo_active_agent a_agent;
  fifo_passive_agent p_agent;
  fifo_scoreboard scbr;
 
  function new(string name ="fifo_env",uvm_component parent);
    super.new(name,parent);
  endfunction
 // build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a_agent =   fifo_active_agent::type_id::create("a_agent",this);
    p_agent =   fifo_passive_agent::type_id::create("p_agent",this);
    scbr =   fifo_scoreboard::type_id::create("scbr",this);
    endfunction
  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a_agent.imon.imon_ap.connect(scbr.in_ap);
    p_agent.omon.omon_ap.connect(scbr.out_ap);
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
  endfunction
endclass