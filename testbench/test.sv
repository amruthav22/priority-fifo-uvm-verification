class fifo_test extends uvm_test;

  `uvm_component_utils(fifo_test)
   
   fifo_env env;
   fifo_sequence seq;

  function new(string name ="fifo_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=fifo_env::type_id::create("env",this);
    
  endfunction
  // run_phase
  
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
   // apply_reset();  // initial reset
    seq=fifo_sequence::type_id::create("seq",this);
    
    seq.start(env.a_agent.seqr);
   
    phase.drop_objection(this);
    
  
  endtask
  
  
  
endclass






class high_burst_test extends uvm_test;

  `uvm_component_utils(high_burst_test)
 
   fifo_env env;
   high_burst_seq seq2;
  function new(string name ="high_burst_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=fifo_env::type_id::create("env",this);
    
  endfunction
  // run_phase
  
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
   
    seq2=high_burst_seq::type_id::create("seq2",this);
    seq2.start(env.a_agent.seqr);
   
    phase.drop_objection(this);
    
  
  endtask
  
  
  
endclass
// starvation 
class  starvation_seq_test extends uvm_test;

  `uvm_component_utils(starvation_seq_test)
 
   fifo_env env;
    starvation_seq seq2;
  function new(string name ="starvation_seq_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=fifo_env::type_id::create("env",this);
    
  endfunction
  // run_phase
  
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
   
    seq2=starvation_seq::type_id::create("seq2",this);
    seq2.start(env.a_agent.seqr);
   
    phase.drop_objection(this);
    
  
  endtask
  
  
  
endclass
///mixed signall
class mixed_seq_test extends uvm_test;

  `uvm_component_utils(mixed_seq_test)
 
   fifo_env env;
   mixed_seq seq2;
  function new(string name ="starvation_seq_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=fifo_env::type_id::create("env",this);
    
  endfunction
  // run_phase
  
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
   
    seq2=mixed_seq::type_id::create("seq2",this);
    seq2.start(env.a_agent.seqr);
   
    phase.drop_objection(this);
    
  
  endtask
  
  
  
endclass


class empty_read_seq_test extends uvm_test;

  `uvm_component_utils(empty_read_seq_test)
 
   fifo_env env;
   empty_read_seq seq2;
  function new(string name ="empty_read_seq_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=fifo_env::type_id::create("env",this);
    
  endfunction
  // run_phase
  
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
   
    seq2=empty_read_seq::type_id::create("seq2",this);
    seq2.start(env.a_agent.seqr);
   
    phase.drop_objection(this);
    
  
  endtask
  
  
  
endclass


class full_fifo_seq_test extends uvm_test;

  `uvm_component_utils(full_fifo_seq_test)
 
   fifo_env env;
   full_fifo_seq seq2;
  function new(string name ="full_fifo_seq_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=fifo_env::type_id::create("env",this);
    
  endfunction
  // run_phase
  
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
   
    seq2=full_fifo_seq::type_id::create("seq2",this);
    seq2.start(env.a_agent.seqr);
   
    phase.drop_objection(this);
    
  
  endtask
  
  
  
endclass





