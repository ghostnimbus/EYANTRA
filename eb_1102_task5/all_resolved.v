module all_resolved(
    input  wire [1:0] subunit,      // 2-bit subunit number
    input  wire       RDM_active,   // Resource Deposition Message active signal
    output wire       resolved      // Output: high if subunit == 3 and RDM_active is high
);

  // resolved is asserted if subunit equals 3 (2'b11) and RDM_active is asserted.
  assign resolved = (subunit == 2'b11) && RDM_active;

endmodule
