`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp_in  #(fifo_seq_item, fifo_scoreboard) in_ap;
  uvm_analysis_imp_out #(fifo_seq_item, fifo_scoreboard) out_ap;

  bit [31:0] high_q[$];
  bit [31:0] med_q[$];
  bit [31:0] low_q[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_ap  = new("in_ap", this);
    out_ap = new("out_ap", this);
  endfunction

  function void write_in(fifo_seq_item t);
    if (t.wr_en) begin
      case (t.prio)
        2'b10: high_q.push_back(t.wr_data);
        2'b01: med_q.push_back(t.wr_data);
        2'b00: low_q.push_back(t.wr_data);
        default: `uvm_error("SCB", $sformatf("Unknown prio: %0b", t.prio))
      endcase
      `uvm_info("SCB", $sformatf("WRITE: prio=%0b data=%0d | HQ=%0d MQ=%0d LQ=%0d",
                t.prio, t.wr_data, high_q.size(), med_q.size(), low_q.size()), UVM_LOW)
    end
  endfunction

  function void write_out(fifo_seq_item t);
    bit [31:0] expected;
    bit        found = 0;
    if (t.rd_valid) begin
      if (high_q.size() > 0) begin
        expected = high_q.pop_front(); found = 1;
      end else if (med_q.size() > 0) begin
        expected = med_q.pop_front(); found = 1;
      end else if (low_q.size() > 0) begin
        expected = low_q.pop_front(); found = 1;
      end
      if (!found) begin
        `uvm_error("SCB", $sformatf("Unexpected rd_valid! data=%0d but all queues empty", t.rd_data))
      end else if (t.rd_data !== expected) begin
        `uvm_error("SCB", $sformatf("MISMATCH! exp=%0d got=%0d | HQ=%0d MQ=%0d LQ=%0d",
                   expected, t.rd_data, high_q.size(), med_q.size(), low_q.size()))
      end else begin
        `uvm_info("SCB", $sformatf("MATCH: exp=%0d got=%0d | HQ=%0d MQ=%0d LQ=%0d",
                  expected, t.rd_data, high_q.size(), med_q.size(), low_q.size()), UVM_LOW)
      end
    end
  endfunction

  virtual function void check_phase(uvm_phase phase);
    int total_left = high_q.size() + med_q.size() + low_q.size();
    if (total_left > 0) begin
      `uvm_info("SCB", $sformatf(
        "End of test: %0d items remain unread (HQ=%0d MQ=%0d LQ=%0d) - not an error",
        total_left, high_q.size(), med_q.size(), low_q.size()), UVM_LOW)
    end else begin
      `uvm_info("SCB", "=== SCOREBOARD PASSED: All written items were read back ===", UVM_LOW)
    end
  endfunction

endclass