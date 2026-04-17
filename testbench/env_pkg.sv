//`include "seq_pkg.sv"
package fifo_env_pkg;
  import uvm_pkg::*;
  import fifo_seq_pkg::*;
  `include "uvm_macros.svh"

  `include "driver.sv"
  `include "imonitor.sv"
  `include "omonitor.sv"
  `include "passive_agent.sv"
  `include "active_agent.sv"
  `include "scoreboard.sv"
  `include "environment.sv"
  
endpackage
