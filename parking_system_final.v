module parking_system_datapath(input clock, input leave,
										input [8:0]occupied,
										input [2:0]vehicle_size,
										input [3:0]spot_number,
										input read_vehicle_size,
										input read_park_pick,
										input read_spot,
										input park_pick,
										input [8:0] start1,
                              input [8:0] final1,
                              input [8:0] start2,
                              input [8:0] final2,
                              input [8:0] start3,
                              input [8:0] final3,
                              input [8:0] start4,
                              input [8:0] final4,
                              input [8:0] start5,
                              input [8:0] final5,
                              input [8:0] start6,
                              input [8:0] final6,
                              input [8:0] start7,
                              input [8:0] final7,
                              input [8:0] start8,
                              input [8:0] final8,
                              input [8:0] start9,
                              input [8:0] final9,
										input [9:0] light1,
										input [9:0] light2,
										input [9:0] light3,
										input [9:0] light4,
										input [9:0] light5,
										input [9:0] light6,
										input [9:0] light7,
										input [9:0] light8,
										input [9:0] light9,
										input [2:0] vehicle_size1,
										input [2:0] vehicle_size2,
										input [2:0] vehicle_size3,
										input [2:0] vehicle_size4,
										input [2:0] vehicle_size5,
										input [2:0] vehicle_size6,
										input [2:0] vehicle_size7,
										input [2:0] vehicle_size8,
										input [2:0] vehicle_size9,
										input [8:0] calculate_fare,
										input [8:0] password_correct,
										output reg occupied_error/*also pass to VGA*/,
										output reg empty_error/*also pass to VGA*/,
										output reg fit/*also pass to VGA*/,
										output reg [8:0]car_in,
										output reg [8:0]attempt,
										output reg [8:0]leave_to_spots,
										output reg [8:0]start_system,
										output reg [8:0]final_system,
										output reg calculate_fare_out,
										output reg occupied_out,
										output [9:0]LEDR,
										output [3:0]current_spot_out,
										output reg [1:0]spot_size_out,
										output reg [2:0] current_vehicle_size,
										output reg [2:0] size_vga,
										output reg password_vga = 1
										);
//									reg [2:0]current_vehicle_size;
									reg current_park_pick;
									reg [3:0]current_spot;
									assign current_spot_out = current_spot;
									
//									integer my_spot;
//									
//									assign my_spot = current_spot;
									
									always @ (posedge read_vehicle_size) begin
										current_vehicle_size = vehicle_size;
									end
									
									always @ (posedge read_park_pick) begin
										current_park_pick = park_pick;
									end
									
									always @ (posedge read_spot) begin
										
										attempt[8:0] = 9'b0;
										current_spot = spot_number;
										occupied_error = 1'b1;
										empty_error = 1'b1;
										if (current_park_pick) begin
//											occupied_error = occupied[my_spot];
											occupied_error = occupied[current_spot];
											empty_error = 0;
										end
										
										fit = 1'b0;///////////////////////////////////////////
										if (!occupied_error) begin
											if (current_vehicle_size == 3'b001) begin //car always fits any spot
												fit = 1'b1;
											end
											else if (current_vehicle_size == 3'b010 & (current_spot == 4'b0110 |current_spot == 4'b0111 | current_spot == 4'b1000 ))begin //van needs medium or larger
												fit = 1'b1;
											end
											else if (current_vehicle_size == 3'b100 & current_spot == 4'b1000) begin //bus needs large
												fit = 1'b1;
											end
										end
										
//										if (fit & !occupied_error) begin
//											car_in[my_spot] = 1'b1;
//										end
											
										if (!current_park_pick) begin
//											empty_error = !occupied[my_spot];
											empty_error = !occupied[current_spot];
											occupied_error = 0;
										end
										
										if (!empty_error & !current_park_pick) begin
//											attempt[my_spot] = 1'b1;
											attempt[current_spot] = 1'b1;
										end
										
										
									end
									
//									always @ (*) begin
//										if (!empty_error)
//										attempt[my_spot] = 1'b1;
//										else
//										attempt[8:0] = 9'b0;
									
									always @ (*) begin
										car_in[8:0] = 9'b0;
									   if (fit)
//										car_in[my_spot] = 1'b1;
										car_in[current_spot] = 1'b1;
									end
									
										
									always @ (*) begin
										leave_to_spots = 9'b0;
										if (leave)
										leave_to_spots[current_spot] = 1'b1;
									end
									
									reg [9:0] light_assignment = 10'b0;
									assign LEDR[9:0] = light_assignment[9:0];
									

									
									always @ (*) begin
										occupied_out = 1'b0;
										calculate_fare_out = 1'b0;
										password_vga = 1;
										case(current_spot[3:0])
											4'b0000: begin
													start_system = start1;
													final_system = final1;
													light_assignment = light1;
													calculate_fare_out = calculate_fare[0];
													occupied_out = occupied[0]; //correct until this step Nov.23 19:57
													spot_size_out = 2'b10;
													size_vga = vehicle_size1;
													password_vga = 1;//password_correct[0];
													end
											4'b0001: begin
													start_system = start2;
													final_system = final2;
													light_assignment = light2;
													calculate_fare_out = calculate_fare[1];
													occupied_out = occupied[1];
													spot_size_out = 2'b10;
													size_vga = vehicle_size2;
													password_vga = 1;//password_correct[1];
													end
											4'b0010: begin
													start_system = start3;
													final_system = final3;
													light_assignment = light3;
													calculate_fare_out = calculate_fare[2];
													occupied_out = occupied[2];
													spot_size_out = 2'b10;
													size_vga = vehicle_size3;
													password_vga = 1;//password_correct[2];
													end
											4'b0011: begin
													start_system = start4;
													final_system = final4;
													light_assignment = light4;
													calculate_fare_out = calculate_fare[3];
													occupied_out = occupied[3];
													spot_size_out = 2'b10;
													size_vga = vehicle_size4;
													password_vga = 1;//password_correct[3];
													end
											4'b0100: begin
													start_system = start5;
													final_system = final5;
													light_assignment = light5;
													calculate_fare_out = calculate_fare[4];
													occupied_out = occupied[4];
													spot_size_out = 2'b10;
													size_vga = vehicle_size5;
													password_vga = 1;//password_correct[4];
													end
											4'b0101: begin
													start_system = start6;
													final_system = final6;
													light_assignment = light6;
													calculate_fare_out = calculate_fare[5];
													occupied_out = occupied[5];
													spot_size_out = 2'b10;
													size_vga = vehicle_size6;
													password_vga = 1;//password_correct[5];
													end
											4'b0110: begin
													start_system = start7;
													final_system = final7;
													light_assignment = light7;
													calculate_fare_out = calculate_fare[6];
													occupied_out = occupied[6];
													spot_size_out = 2'b01;
													size_vga = vehicle_size7;
													password_vga = 1;//password_correct[6];
													end
											4'b0111: begin
													start_system = start8;
													final_system = final8;
													light_assignment = light8;
													calculate_fare_out = calculate_fare[7];
													occupied_out = occupied[7];
													spot_size_out = 2'b01;
													size_vga = vehicle_size8;
													password_vga = 1;//password_correct[7];
													end
											4'b1000: begin
													start_system = start9;
													final_system = final9;
													light_assignment = light9;
													calculate_fare_out = calculate_fare[8];
													occupied_out = occupied[8];
													spot_size_out = 2'b11;
													size_vga = vehicle_size9;
													password_vga = 1;//password_correct[8];
													end
											default: begin
														password_vga = 1;
													end
										endcase
									end

endmodule

module parking_sysytem_control(
										 input gl_reset,
										 input city_done,
										 input parkpick_confirm,
										 input parkpick, /*park=1, pick=0*/
										 input spot_entered,
										 input leave /*from vending machine*/,
										 input size_entered,
										 input fit,
										 input car_in_done,
										 input resetn,
										 input clock,
										 output reg read_vehicle_size,
										 output reg read_park_pick,
										 output reg read_spot,
										 output reg read_city,
										 //output reg calculate_fare,
										 output [3:0]current_state_out,
										 output reg go,
										 output reg reverse,
										 output reg change_background
										 );
									assign current_state_out = current_state;
									 
									 localparam  S_WAIT_USER = 4'd0,
													 S_WAIT_PARKPICK = 4'd1,	
													 S_CHOOSE_SPOT_OUT = 4'd2,
													 S_SPOT_SELF_OUT       = 4'd3,
													 S_CHOOSE_VEHICLE_SIZE = 4'd4,
													 S_CHOOSE_SPOT_IN = 4'd5,
													 S_SPOT_FIT = 4'd6,
													 S_SPOT_SELF_IN = 4'd7,
													 S_CHOOSE_CITY = 4'd8,
													 S_BACKGROUND = 4'd9;
									 
									 reg [3:0] current_state=S_CHOOSE_CITY;
									 reg [3:0] next_state; 

									  //Next state logic aka our state table
									  always@(*)
									  begin: state_table 
												case (current_state)
													S_CHOOSE_CITY: next_state = city_done ? S_BACKGROUND : S_CHOOSE_CITY;
													S_BACKGROUND: next_state = S_WAIT_USER;
													S_WAIT_USER: next_state = parkpick_confirm? S_WAIT_PARKPICK : S_WAIT_USER;
													S_WAIT_PARKPICK: next_state = parkpick? S_CHOOSE_VEHICLE_SIZE : S_CHOOSE_SPOT_OUT;
													S_CHOOSE_SPOT_OUT: next_state = spot_entered? S_SPOT_SELF_OUT : S_CHOOSE_SPOT_OUT;
													S_SPOT_SELF_OUT: next_state = leave? S_WAIT_USER : S_SPOT_SELF_OUT;
													S_CHOOSE_VEHICLE_SIZE: next_state = size_entered? S_CHOOSE_SPOT_IN :S_CHOOSE_VEHICLE_SIZE;
													S_CHOOSE_SPOT_IN: next_state = spot_entered? S_SPOT_FIT : S_CHOOSE_SPOT_IN;
													S_SPOT_FIT: next_state = fit? S_SPOT_SELF_IN: S_CHOOSE_SPOT_IN;
													S_SPOT_SELF_IN : next_state = car_in_done? S_WAIT_USER : S_SPOT_SELF_IN;
													default: next_state = S_CHOOSE_CITY;
												endcase
									  end
									  
									  always@(posedge clock) begin 
											if (gl_reset) begin
											    current_state <= S_CHOOSE_CITY;
											end
											else if (resetn) begin
												 current_state <= S_WAIT_USER;
												
											end
											else begin
												current_state <= next_state;
											end
										end				 
										
									always@(*) begin
										read_city = 1'b0;
										read_vehicle_size = 1'b0;
										read_park_pick = 1'b0;
										read_spot = 1'b0;
										go = 1'b0;
										reverse = 1'b0;
										change_background = 1'b0;
										//calculate_fare = 1'b0;
										case(current_state)
											S_CHOOSE_CITY: read_city = 1'b1;
											S_SPOT_FIT: read_spot = 1'b1;
											S_CHOOSE_SPOT_IN: read_vehicle_size = 1'b1;
											S_WAIT_PARKPICK: read_park_pick = 1'b1;
											S_SPOT_SELF_OUT: begin
																read_spot = 1'b1;
																//calculate_fare = 1'b1;
																go = 1'b1;
																reverse = 1'b1;
																end
											S_SPOT_SELF_IN: go = 1'b1;
											S_BACKGROUND: change_background = 1'b1;
										endcase
									end
									  
endmodule

	
	