`timescale 1 ns / 1 ns
module Line_Shift_RAM_8Bit 
#(
	parameter	[10:0]	RAM_Length = 11'd1280	//1280*720
)
(
	clken,
	clock,
	shiftin,
	shiftout,
	taps0x,
	taps1x);

	input	  clken;
	input	  clock;
	input	[7:0]  shiftin;
	output	[7:0]  shiftout;
	output	[7:0]  taps0x;
	output	[7:0]  taps1x;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clken;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [7:0] sub_wire0;
	wire [15:0] sub_wire1;
	wire [7:0] shiftout = sub_wire0[7:0];
	wire [15:8] sub_wire3 = sub_wire1[15:8];
	wire [7:0] sub_wire2 = sub_wire1[7:0];
	wire [7:0] taps0x = sub_wire2[7:0];
	wire [7:0] taps1x = sub_wire3[15:8];

	altshift_taps	ALTSHIFT_TAPS_component (
				.clock (clock),
				.clken (clken),
				.shiftin (shiftin),
				.shiftout (sub_wire0),
				.taps (sub_wire1)
				// synopsys translate_off
				,
				.aclr ()
				// synopsys translate_on
				);
	defparam
		ALTSHIFT_TAPS_component.intended_device_family = "Cyclone IV E",
		ALTSHIFT_TAPS_component.lpm_hint = "RAM_BLOCK_TYPE=M9K",
		ALTSHIFT_TAPS_component.lpm_type = "altshift_taps",
		ALTSHIFT_TAPS_component.number_of_taps = 2,
		ALTSHIFT_TAPS_component.tap_distance = RAM_Length,
		ALTSHIFT_TAPS_component.width = 8;


endmodule