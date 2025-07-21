module csl_valid(
    input  wire go_to_pu,  // Prototyping Unit signal
    input  wire go_to_fu,  // Fabrication Unit signal
    input  wire go_to_wu,  // Warehouse Unit signal
    output wire csl_valid  // Combined valid signal
);

  // Logical OR of all input signals
  assign csl_valid = go_to_pu | go_to_fu | go_to_wu;

endmodule
