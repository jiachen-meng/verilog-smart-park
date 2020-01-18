module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	enter_pressed_out,
	esc_pressed_out
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		enter_pressed_out;
output     esc_pressed_out;
reg enter_pressed;
reg esc_pressed;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

always @(posedge CLOCK_50)
begin
////		enter_pressed = 1'b0;
//		if (ps2_key_data == 8'h5A) begin
//			enter_pressed = 1'b1;
//		end
//		if (ps2_key_data == 8'h76) begin
//			esc_pressed = 1'b1;
//		end
//		if (ps2_key_data == 8'h29) begin
//			enter_pressed = 1'b0;
//			esc_pressed = 1'b0;
//		end
		enter_pressed = 1'b0;
		esc_pressed = 1'b0;
		if (ps2_key_data == 8'h5A & ps2_key_pressed) begin
			enter_pressed = 1'b1;
		end
		if (ps2_key_data == 8'h76 & ps2_key_pressed) begin
			esc_pressed = 1'b1;
		end
end
assign enter_pressed_out = enter_pressed;
assign esc_pressed_out = esc_pressed;
endmodule
