module fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 32
)(
    input  logic                  clk,
    input  logic                  rst,      // active-high reset
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_op,  // renamed from data_op for clarity (rd_data)
    output logic                  full,
    output logic                  empty
);

    // ────────────────────────────────────────────────
    // Parameters
    // ────────────────────────────────────────────────
    localparam PTR_WIDTH = $clog2(DEPTH);           // 5 for DEPTH=32
    localparam PTR_MSB   = PTR_WIDTH;               // extra bit → total PTR_WIDTH+1 bits

    // ────────────────────────────────────────────────
    // Storage & pointers
    // ────────────────────────────────────────────────
    logic [DATA_WIDTH-1:0] ram [0:DEPTH-1];
    logic [PTR_MSB:0]      wr_ptr;
    logic [PTR_MSB:0]      rd_ptr;

    // ────────────────────────────────────────────────
    // Full & Empty flags (standard gray-code style with extra MSB)
    // ────────────────────────────────────────────────
    wire ptr_lower_equal = (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]);
    wire msb_diff        = (wr_ptr[PTR_MSB] != rd_ptr[PTR_MSB]);

    assign full  = ptr_lower_equal &&  msb_diff;
    assign empty = ptr_lower_equal && !msb_diff;

    // ────────────────────────────────────────────────
    // Write + Read Logic (synchronous)
    // ────────────────────────────────────────────────
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            data_op <= '0;
        end
        else begin
            // Write operation
            if (wr_en && !full) begin
                ram[wr_ptr[PTR_WIDTH-1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read operation
            if (rd_en && !empty) begin
                data_op <= ram[rd_ptr[PTR_WIDTH-1:0]];
                rd_ptr  <= rd_ptr + 1'b1;
            end
        end
    end
  
  //overflow
  
  property p_no_overflow;
  @(posedge clk)
  disable iff (rst)
  wr_en && full |-> $stable(wr_ptr);
endproperty

assert property (p_no_overflow);

endmodule

// priority fifo

module priority_fifo #(
    parameter MAX_HIGH_CONSECUTIVE = 4   // Tune anti-starvation threshold
)(
    input logic clk,
    input logic rst,                     // active-high reset (changed from rst_n)
    
    // Write interface
    input logic wr_en,
    input logic [31:0] wr_data,
    input logic [1:0]prio,         // 2'b10=HIGH, 01=MED, 00=LOW
    
    // Read interface
    input  logic       rd_en,
    output logic [31:0] rd_data,
    output logic       rd_valid,
    
    // Status
    output logic full,
    output logic empty
);

    // Internal write enables
    logic high_wr, med_wr, low_wr;
    
    // Internal read enables
    logic high_rd, med_rd, low_rd;
    
    // FIFO status
    logic high_empty, med_empty, low_empty;
    logic high_full,  med_full,  low_full;
    
    logic [31:0] high_data, med_data, low_data;
    
    logic [2:0] valid_queues;
    
    // Anti-starvation for high priority
    logic [$clog2(MAX_HIGH_CONSECUTIVE+1)-1:0] high_served_count;
    logic high_served_too_long;

    // Write decoding
    always_comb begin
        high_wr = 1'b0;
        med_wr  = 1'b0;
        low_wr  = 1'b0;
       if (wr_en) begin
    case (prio)
        2'b10: if (!high_full) high_wr = 1;
        2'b01: if (!med_full)  med_wr  = 1;
        2'b00: if (!low_full)  low_wr  = 1;
    endcase
     end
    end

    // Priority read with anti-starvation
    assign valid_queues = {~high_empty, ~med_empty, ~low_empty};

   logic [31:0] rd_data_next;
logic        rd_valid_next;

always_comb begin
    high_rd = 0; med_rd = 0; low_rd = 0;

    rd_valid_next = 0;
    rd_data_next  = '0;

    if (rd_en && !empty) begin
        if (valid_queues[2]) begin
            if (!high_served_too_long) begin
                high_rd = 1;
                rd_data_next = high_data;
                rd_valid_next = 1;
            end 
            else if (valid_queues[1]) begin
                med_rd = 1;
                rd_data_next = med_data;
                rd_valid_next = 1;
            end 
            else if (valid_queues[0]) begin
                low_rd = 1;
                rd_data_next = low_data;
                rd_valid_next = 1;
            end 
            else begin
                high_rd = 1;
                rd_data_next = high_data;
                rd_valid_next = 1;
            end
        end
        else if (valid_queues[1]) begin
            med_rd = 1;
            rd_data_next = med_data;
            rd_valid_next = 1;
        end
        else if (valid_queues[0]) begin
            low_rd = 1;
            rd_data_next = low_data;
            rd_valid_next = 1;
        end
    end
end
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        rd_data  <= '0;
        rd_valid <= 0;
    end
    else begin
        rd_data  <= rd_data_next;
        rd_valid <= rd_valid_next;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        high_served_count <= '0;
    end 
    else begin
        if (high_rd) begin
            if (high_served_count < MAX_HIGH_CONSECUTIVE)
                high_served_count <= high_served_count + 1;
            else
                high_served_count <= high_served_count; // optional (explicit hold)
        end 
        else if (med_rd || low_rd) begin
            high_served_count <= '0;
        end
        // else: implicit hold (no assignment needed)
    end
end
    assign high_served_too_long = (high_served_count >= MAX_HIGH_CONSECUTIVE);

    // Instantiate three FIFOs
    fifo fifo_high (
        .clk     (clk),
        .rst     (rst),
        .wr_en   (high_wr),
        .rd_en   (high_rd),
        .data_in (wr_data),
        .data_op (high_data),
        .full    (high_full),
        .empty   (high_empty)
    );

    fifo fifo_med (
        .clk     (clk),
        .rst     (rst),
        .wr_en   (med_wr),
        .rd_en   (med_rd),
        .data_in (wr_data),
        .data_op (med_data),
        .full    (med_full),
        .empty   (med_empty)
    );

    fifo fifo_low (
        .clk     (clk),
        .rst     (rst),
        .wr_en   (low_wr),
        .rd_en   (low_rd),
        .data_in (wr_data),
        .data_op (low_data),
        .full    (low_full),
        .empty   (low_empty)
    );

    // Overall status
    assign empty = high_empty && med_empty && low_empty;
   assign full =
    ( prio== 2'b10 && high_full) ||
    (prio == 2'b01 && med_full)  ||
    (prio == 2'b00 && low_full);
  
 // assertions 
  property p_read_valid;
  @(posedge clk)
  disable iff (rst)
  rd_en && !empty |=> rd_valid;
endproperty
  // if valid rd_data must be stable
assert property (p_read_valid);  
  
  property p_no_write_on_full;
  @(posedge clk)
  disable iff (rst)
  wr_en && full |-> 0;
endproperty

assert property (p_no_write_on_full);
  
  
  //underflow
  
  property p_no_underflow;
  @(posedge clk)
  disable iff (rst)
  rd_en && empty |=> !rd_valid;
endproperty

assert property (p_no_underflow);
  
 

  
  
  // high fifo priority
  property p_high_priority;
  @(posedge clk)
  disable iff (rst)
  (rd_en && !high_empty) |-> (high_rd);
endproperty

assert property (p_high_priority);
  
  //medium  priority
  
  property p_med_priority;
  @(posedge clk)
  disable iff (rst)
  (rd_en && high_empty && !med_empty) |-> med_rd;
endproperty

assert property (p_med_priority);
  
  //low priority
  property p_low_priority;
  @(posedge clk)
  disable iff (rst)
  (rd_en && high_empty && med_empty && !low_empty) |-> low_rd;
endproperty

assert property (p_low_priority);
  
  property p_starvation_prevention;
  @(posedge clk)
  disable iff (rst)
  (high_served_count >= MAX_HIGH_CONSECUTIVE && !med_empty)
  |-> med_rd;
endproperty

assert property (p_starvation_prevention);
  
  property p_reset_empty;
  @(posedge clk)
    rst |=>  empty;
endproperty

assert property (p_reset_empty);
  
  property p_no_valid_during_reset;
  @(posedge clk)
  rst |-> !rd_valid;
endproperty

assert property (p_no_valid_during_reset);
endmodule


