module message_select(
    input  wire        RDM_active,   // Active when RDM message is to be sent
    input  wire        RPM_active,   // Active when RPM message is to be sent
    input  wire        SLM_active,   // Active when SLM message is to be sent
    input  wire [7:0]  RDM_data,     // 8-bit data for RDM
    input  wire [7:0]  RPM_data,     // 8-bit data for RPM
    input  wire [7:0]  SLM_data,     // 8-bit data for SLM
    input  wire        RDM_tx_start, // tx_start signal for RDM
    input  wire        RPM_tx_start, // tx_start signal for RPM
    input  wire        SLM_tx_start, // tx_start signal for SLM
    output reg  [7:0]  tx_data,      // Selected 8-bit data to transmit
    output reg         tx_start      // Selected tx_start signal
);

  always @(*) begin
    // Priority: RDM > RPM > SLM.
    if (RDM_active) begin
      tx_data   = RDM_data;
      tx_start  = RDM_tx_start;
    end else if (RPM_active) begin
      tx_data   = RPM_data;
      tx_start  = RPM_tx_start;
    end else if (SLM_active) begin
      tx_data   = SLM_data;
      tx_start  = SLM_tx_start;
    end else begin
      tx_data   = 8'd0; // Default data value when none active
      tx_start  = 1'b0;
    end
  end

endmodule
