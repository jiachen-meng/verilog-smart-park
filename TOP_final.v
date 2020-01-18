

module TOP(input [9:0]SW, input [3:0]KEY, input CLOCK_50, 
output [9:0]LEDR, output [6:0]HEX0, output [6:0]HEX1, output [6:0]HEX2, output [6:0]HEX3, 
output [6:0]HEX4, output [6:0]HEX5,  inout PS2_CLK, inout PS2_DAT, output VGA_CLK, output VGA_HS, 
output VGA_VS, output VGA_BLANK_N, output VGA_SYNC_N, output [7:0]VGA_R, output [7:0]VGA_G, output [7:0]VGA_B);

	wire leave; //from vending machine
	wire [8:0] occupied; //connect system with each spot
	wire [3:0] spot_number;
	wire [1:0] city;
	wire [8:0] car_in;
	wire [8:0] attempt;
	wire [8:0] leave_to_spots;
	wire [1:0] small_placeholder;
	wire [1:0] medium_placeholder;
	wire [1:0] large_placeholder;
	wire [1:0] spot1_size;
	wire [1:0] spot2_size;
	wire [1:0] spot3_size;
	wire [1:0] spot4_size;
	wire [1:0] spot5_size;
	wire [1:0] spot6_size;
	wire [1:0] spot7_size;
	wire [1:0] spot8_size;
	wire [1:0] spot9_size;
	wire [3:0] spot1_placeholder;
	wire [3:0] spot2_placeholder;
	wire [3:0] spot3_placeholder;
	wire [3:0] spot4_placeholder;
	wire [3:0] spot5_placeholder;
	wire [3:0] spot6_placeholder;
	wire [3:0] spot7_placeholder;
	wire [3:0] spot8_placeholder;
	wire [3:0] spot9_placeholder;
	wire [3:0] spot1_number;
	wire [3:0] spot2_number;
	wire [3:0] spot3_number;
	wire [3:0] spot4_number;
	wire [3:0] spot5_number;
	wire [3:0] spot6_number;
	wire [3:0] spot7_number;
	wire [3:0] spot8_number;
	wire [3:0] spot9_number;
	wire [8:0] read_start_time;
	wire [8:0] read_end_time;
	wire [8:0] read_random_password;
	wire [8:0] read_user_password;
	wire [8:0] check_password;
	wire [8:0] if_empty;
	wire [8:0] password_go;
	wire [8:0] password_correct;
	wire [8:0] password_maybe;
	wire city_done;
	wire read_vehicle_size;
	wire read_park_pick;
	wire read_spot;
	wire read_city;
	wire [8:0]calculate_fare;
	wire calculate_fare_out;
	wire ten_minutes;
	wire [8:0] current_time;
	wire enter_pressed ; // best used as posedge trigger//otherwise need to combine with key
	wire esc_pressed;
	reg enter_pressed_out;
	reg esc_pressed_out;
	wire receiving;
	wire resetting;
	wire fit;
	wire occupied_error;
	wire empty_error;
	wire [8:0] start1;
	wire [8:0] final1;
	wire [8:0] start2;
	wire [8:0] final2;
	wire [8:0] start3;
	wire [8:0] final3;
	wire [8:0] start4;
	wire [8:0] final4;
	wire [8:0] start5;
	wire [8:0] final5;
	wire [8:0] start6;
	wire [8:0] final6;
	wire [8:0] start7;
	wire [8:0] final7;
	wire [8:0] start8;
	wire [8:0] final8;
	wire [8:0] start9;
	wire [8:0] final9;
	wire [9:0] light1;
	wire [9:0] light2;
	wire [9:0] light3;
	wire [9:0] light4;
	wire [9:0] light5;
	wire [9:0] light6;
	wire [9:0] light7;
	wire [9:0] light8;
	wire [9:0] light9;
	wire [8:0] start_system;
	wire [8:0] final_system;
	wire [9:0] PASSWORD;
	wire [3:0] current_state_out;
	wire [1:0] vending_state;
	wire [2:0] spot_state1;
	wire [2:0] spot_state2;
	wire [2:0] spot_state3;
	wire [2:0] spot_state4;
	wire [2:0] spot_state5;
	wire [2:0] spot_state6;
	wire [2:0] spot_state7;
	wire [2:0] spot_state8;
	wire [2:0] spot_state9;
	wire [2:0] vehicle_size1;
	wire [2:0] vehicle_size2;
	wire [2:0] vehicle_size3;
	wire [2:0] vehicle_size4;
	wire [2:0] vehicle_size5;
	wire [2:0] vehicle_size6;
	wire [2:0] vehicle_size7;
	wire [2:0] vehicle_size8;
	wire [2:0] vehicle_size9;
	
	wire [9:0] fare_out;
	wire [9:0] current_sum_out;
	wire occupied_out;
	wire [3:0] current_spot_out;
	wire [1:0] spot_size_out;
	
	reg [9:0] screen;
	wire [3:0] movement;
	wire [3:0] errors;
//	wire flag1;
//	wire flag2;
//	wire flag3;
//	wire flag4;
//	wire flag5;
//	wire flag6;
//	wire flag7;
//	wire flag8;
//	wire flag9;
	wire go;
	wire errors_go;
	wire reverse;
	wire change_background;
	
	wire [2:0] size_vga;
	wire password_vga;
	
	wire [2:0] current_vehicle_size;

	
	always@(posedge CLOCK_50) begin
	enter_pressed_out = 1'b0;
	esc_pressed_out = 1'b0;
		if (enter_pressed)
			enter_pressed_out = 1'b1;
		if (esc_pressed)
			esc_pressed_out = 1'b1;
	end
	
	assign small_placeholder = 2'b10;
	assign medium_placeholder = 2'b01;
	assign large_placeholder = 2'b00;
	
	assign spot1_placeholder = 4'b0000;
	assign spot2_placeholder = 4'b0001;
	assign spot3_placeholder = 4'b0010;
	assign spot4_placeholder = 4'b0011;
	assign spot5_placeholder = 4'b0100;
	assign spot6_placeholder = 4'b0101;
	assign spot7_placeholder = 4'b0110;
	assign spot8_placeholder = 4'b0111;
	assign spot9_placeholder = 4'b1000;
	
//	seg7 u11(1'b0,1'b0,1'b0, password_correct[0], HEX0[6:0]); //debgging
//	seg7 u11(1'b0,1'b0,1'b0, leave_to_spots[0], HEX0[6:0]); //debgging
//	seg7 u11(current_spot_out[3],current_spot_out[2],current_spot_out[1], current_spot_out[0], HEX0[6:0]); //debgging
//	seg7 u13(current_time[7],current_time[6],current_time[5], current_time[4], HEX1[6:0]); //debgging
//	seg7 u11(start_system[3],start_system[2],start_system[1], start_system[0], HEX0[6:0]); //debgging
//	seg7 u11(0,0, 0, movement[1], HEX0[6:0]); //debgging
////	seg7 u13(current_state_out[3], current_state_out[2], current_state_out[1], current_state_out[0], HEX1[6:0]); //debgging
//	seg7 u14(current_spot_out[3],current_spot_out[2],current_spot_out[1], current_spot_out[0], HEX2[6:0]); //debgging
//	seg7 u15(1'b0,1'b0,vending_state[1], vending_state[0], HEX3[6:0]); //debgging
////	seg7 u16(1'b0,1'b0,1'b0, occupied[0], HEX4[6:0]); //debgging
////	seg7 U12(1'b0,1'b0,1'b0, leave, HEX5[6:0]); //debgging
////	seg7 u16(fare_out[3],fare_out[2],fare_out[1], fare_out[0], HEX4[6:0]); //debgging
////	seg7 U12(fare_out[7],fare_out[6],fare_out[5], fare_out[4], HEX5[6:0]); //debgging
////	seg7 u16(current_sum_out[3],current_sum_out[2],current_sum_out[1], current_sum_out[0], HEX4[6:0]); //debgging
////	seg7 u16(final_system[3],final_system[2],final_system[1], final_system[0], HEX4[6:0]); //debgging
////	seg7 U12(fare_out[3],fare_out[2],fare_out[1], fare_out[0] , HEX5[6:0]); //debgging
//	seg7 u16(errors[0],errors[1],errors[2],errors[3] , HEX4[6:0]); //debgging
//	seg7 U12(screen[3],screen[2],screen[1],screen[0] , HEX5[6:0]); //debgging
//	
	
	
	
	seg7 u11(errors[3],errors[2],errors[1],errors[0] , HEX0[6:0]);
	seg7 u13(current_state_out[3], current_state_out[2], current_state_out[1], current_state_out[0], HEX1[6:0]);
	seg7 u14(current_sum_out[3],current_sum_out[2],current_sum_out[1], current_sum_out[0], HEX2[6:0]);
	seg7 u15(current_sum_out[7],current_sum_out[6],current_sum_out[5], current_sum_out[4], HEX3[6:0]);
	seg7 u16(fare_out[3],fare_out[2],fare_out[1], fare_out[0], HEX4[6:0]); 
	seg7 U12(fare_out[7],fare_out[6],fare_out[5], fare_out[4], HEX5[6:0]); 
	
	fill u88(.CLOCK_50(CLOCK_50), .SW(screen), .KEY(movement), .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));

//	always @(posedge occupied[0], posedge occupied[1], posedge occupied[2], posedge occupied[3], posedge occupied[4], posedge occupied[5], posedge occupied[6], posedge occupied[7], posedge occupied[8]) begin
		
		
//		case (car_in) //if not, try current_spot
//			9'b000000001: begin
//									screen[3:0] <= 4'b0;
//									movement[1] <= 0;
//								end
//								
//			9'b000000010: begin
//									screen[3:0] <= 4'b0001;
//									movement[1] <= 0;
//								end
//								
//			9'b000000100: begin
//									screen[3:0] <= 4'b0010;
//									movement[1] <= 0;
//								end
//								
//			9'b000001000: begin
//									screen[3:0] <= 4'b0011;
//									movement[1] <= 0;
//								end	
//			
//			9'b000010000: begin
//									screen[3:0] <= 4'b0100;
//									movement[1] <= 0;
//								end
//								
//			9'b000100000: begin
//									screen[3:0] <= 4'b0101;
//									movement[1] <= 0;
//								end
//								
//			9'b000100000: begin
//									screen[3:0] <= 4'b0101;
//									movement[1] <= 0;
//								end
//			
//			9'b001000000: begin
//									screen[3:0] <= 4'b0111;
//									movement[1] <= 0;
//								end
//								
//			9'b010000000: begin
//									screen[3:0] <= 4'b0110;
//									movement[1] <= 0;
//								end
//			
//			9'b100000000: begin
//									screen[3:0] <= 4'b1000;
//									movement[1] <= 0;
//								end
//			
//		endcase

	assign movement[0] = 1;
	assign movement[1] = (go)? 0: 1;
	assign movement[2] = !SW[9];
	assign movement[3] = reverse? 0:1;
	assign errors[0] = occupied_error;
	assign errors[1] = empty_error;
	assign errors[2] = !fit;
	assign errors[3] = !password_vga;
	
	errors_prompt u99(errors, CLOCK_50, errors_go);
	
	always@(*) begin
		screen[7] = !KEY[0];
	end
	
	always@(*) begin
		case (current_spot_out) //if not, try current_spot
			4'b0000: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0;
									//movement[1] = 0;
								end
								
			4'b0001: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0001;
									//movement[1] = 0;
								end
								
			4'b0010: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0010;
									//movement[1] = 0;
								end
								
			4'b0011: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0011;
									//movement[1] = 0;
								end	
			
			4'b0100: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0100;
									//movement[1] = 0;
								end
								
			4'b0101: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0101;
									//movement[1] = 0;
								end
								
			
			4'b0110: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0111;
									//movement[1] = 0;
								end
								
			4'b0111: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b0110;
									//movement[1] = 0;
								end
			
			4'b1000: begin
//									screen[9:7] = 3'b100;
									screen[3:0] = 4'b1000;
									//movement[1] = 0;
								end
			default: begin
									screen[3:0] = 4'b0;
						end
		endcase
		
		case (size_vga) /////////////////////////////////////////////////////
			3'b001: begin
							screen[6:4] = 3'b000;
						end
			3'b010: begin
							screen[6:4] = 3'b001;
						end
			3'b100: begin
							screen[6:4] = 3'b011;
						end
			default: screen[6:4] = 3'b000;
		endcase
		
//		case (errors)
//			4'b0001: begin 
//							screen [9:7] = 3'b001;
//							screen [3:0] = 4'b1111;
//						end
//			4'b0010: begin
//							screen [9:7] = 3'b000;
//							screen [3:0] = 4'b1111;
//						end
//			4'b0100: begin
//							screen [9:7] = 3'b010;
//							screen [3:0] = 4'b1111;
//						end
//			4'b1000: begin	
//							screen [9:7] = 3'b011;
//							screen [3:0] = 4'b1111;
//						end
//			default : screen[9:7] = 3'b100;
//		endcase
		
	end
	
	
	
	parking_system_datapath u1(CLOCK_50, leave,
										occupied,
										SW[9:7],
										spot_number[3:0],
										read_vehicle_size,
										read_park_pick,
										read_spot,
										SW[6],
										start1,
										final1,
										start2,
										final2,
										start3,
										final3,
										start4,
										final4,
										start5,
										final5,
										start6,
										final6,
										start7,
										final7,
										start8,
										final8,
										start9,
										final9,
										light1,
										light2,
										light3,
										light4,
										light5,
										light6,
										light7,
										light8,
										light9,
										vehicle_size1,
										vehicle_size2,
										vehicle_size3,
										vehicle_size4,
										vehicle_size5,
										vehicle_size6,
										vehicle_size7,
										vehicle_size8,
										vehicle_size9,
										password_correct,
										calculate_fare,
										occupied_error/*also pass to VGA*/,
										empty_error/*also pass to VGA*/,
										fit /*also pass to VGA*/,
										car_in[8:0],
										attempt[8:0],
										leave_to_spots[8:0],
										start_system [8:0],
										final_system [8:0],
										calculate_fare_out,
										occupied_out,
										LEDR[9:0],
										current_spot_out,
										spot_size_out[1:0],
										current_vehicle_size,
										size_vga,
										password_vga
										);
										
	parking_sysytem_control u4(!KEY[2],
										 city_done,
										 enter_pressed_out,
										 SW[6], /*park=1, pick=0*/
										 !KEY[3],
										 leave /*from vending machine*/,
										 !KEY[0],
										 fit,
										 occupied_out, /////////////////////////////////////////////
										 esc_pressed_out,
										 CLOCK_50,
										 read_vehicle_size,
										 read_park_pick,
										 read_spot,
										 read_city,
										 //calculate_fare,
										 current_state_out,
										 go,
										 reverse,
										 change_background
										 );

										
	spot_select u2(SW[8:0], spot_number[3:0]);
	city_select u3(read_city, !KEY[0], SW[2:0], city[1:0],city_done);
	
	vending_machine_control u5(!KEY[2],!KEY[1], leave, !KEY[0], CLOCK_50, resetting, receiving,vending_state[1:0]);
	vending_machine_datapath u6(start_system[8:0]/*info from the spot*/, ///////////////////////////////////////////////////////////NEED TO CHANGE
										final_system[8:0]/*info from the spot*/, ///////////////////////////////////////////////////////////NEED TO CHANGE
										spot_size_out/*info from the spot*/, ///////////////////////////////////////////////////////////NEED TO CHANGE 
										city[1:0]/*info from the city select*/,
										SW[3:0]/*from SW*/, 
										receiving/*info from control*/, 
										resetting/*info from control*/, 
										!KEY[1],
										calculate_fare_out,
										leave/*info to update spot through system*/,
										fare_out,
										current_sum_out
										);	
										
	random_number u7(CLOCK_50, PASSWORD[9:0]);
	
	
	
//	time_counter_parking u8(CLOCK_50, ten_minutes); 
	general_clock u9(CLOCK_50, current_time[8:0]);
	PS2_Demo u10(.CLOCK_50(CLOCK_50), .KEY(KEY[3:0]), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .enter_pressed_out(enter_pressed), .esc_pressed_out(esc_pressed));
	
	parking_spot_datapath spot_1_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[0],
									  read_end_time[0],
									  read_random_password[0],
									  read_user_password[0],
									  password_maybe[0],
									  if_empty[0],
									  check_password[0],
									  small_placeholder,
									  spot1_placeholder,
									  current_vehicle_size,
									  start1, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final1,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot1_size, /*nature of the spot*/
									  spot1_number, /*nature of the spot*/
									  occupied[0],
									  password_correct[0],
									  password_go[0],
									  light1[9:0],
									  vehicle_size1[2:0]
									  );
									  
   parking_spot_control spot_1_control(car_in[0], /*info from the system*/
									 attempt[0], /*info from the system*/
									 password_go[0], /*info from the system*/
									 leave_to_spots[0], /*info from the system*/
									 password_correct[0],
									 CLOCK_50,
									 read_start_time[0],
									 read_end_time[0],
									 read_random_password[0],
									 read_user_password[0],
									 check_password[0],
									 if_empty[0],
									 password_maybe[0],
									 spot_state1,
									 calculate_fare[0]);
									 
	parking_spot_datapath spot_2_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[1],
									  read_end_time[1],
									  read_random_password[1],
									  read_user_password[1],
									  password_maybe[1],
									  if_empty[1],
									  check_password[1],
									  small_placeholder,
									  spot2_placeholder,
									  current_vehicle_size,
									  start2, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final2,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot2_size, /*nature of the spot*/
									  spot2_number, /*nature of the spot*/
									  occupied[1],
									  password_correct[1],
									  password_go[1],
									  light2[9:0],
									  vehicle_size2[2:0]
									  );
									  
   parking_spot_control spot_2_control(car_in[1], /*info from the system*/
									 attempt[1], /*info from the system*/
									 password_go[1], /*info from the system*/
									 leave_to_spots[1], /*info from the system*/
									 password_correct[1],
									 CLOCK_50,
									 read_start_time[1],
									 read_end_time[1],
									 read_random_password[1],
									 read_user_password[1],
									 check_password[1],
									 if_empty[1],
									 password_maybe[1],
									 spot_state2,
									 calculate_fare[1]);
									 
	parking_spot_datapath spot_3_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[2],
									  read_end_time[2],
									  read_random_password[2],
									  read_user_password[2],
									  password_maybe[2],
									  if_empty[2],
									  check_password[2],
									  small_placeholder,
									  spot3_placeholder,
									  current_vehicle_size,
									  start3, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final3,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot3_size, /*nature of the spot*/
									  spot3_number, /*nature of the spot*/
									  occupied[2],
									  password_correct[2],
									  password_go[2],
									  light3[9:0],
									  vehicle_size3[2:0]
									  );
									  
   parking_spot_control spot_3_control(car_in[2], /*info from the system*/
									 attempt[2], /*info from the system*/
									 password_go[2], /*info from the system*/
									 leave_to_spots[2], /*info from the system*/
									 password_correct[2],
									 CLOCK_50,
									 read_start_time[2],
									 read_end_time[2],
									 read_random_password[2],
									 read_user_password[2],
									 check_password[2],
									 if_empty[2],
									 password_maybe[2],
									 spot_state3,
									 calculate_fare[2]);
									 
	parking_spot_datapath spot_4_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[3],
									  read_end_time[3],
									  read_random_password[3],
									  read_user_password[3],
									  password_maybe[3],
									  if_empty[3],
									  check_password[3],
									  small_placeholder,
									  spot4_placeholder,
									  current_vehicle_size,
									  start4, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final4,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot4_size, /*nature of the spot*/
									  spot4_number, /*nature of the spot*/
									  occupied[3],
									  password_correct[3],
									  password_go[3],
									  light4[9:0],
									  vehicle_size4[2:0]
									  );
									  
   parking_spot_control spot_4_control(car_in[3], /*info from the system*/
									 attempt[3], /*info from the system*/
									 password_go[3], /*info from the system*/
									 leave_to_spots[3], /*info from the system*/
									 password_correct[3],
									 CLOCK_50,
									 read_start_time[3],
									 read_end_time[3],
									 read_random_password[3],
									 read_user_password[3],
									 check_password[3],
									 if_empty[3],
									 password_maybe[3],
									 spot_state4,
									 calculate_fare[3]);
									 
	parking_spot_datapath spot_5_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[4],
									  read_end_time[4],
									  read_random_password[4],
									  read_user_password[4],
									  password_maybe[4],
									  if_empty[4],
									  check_password[4],
									  small_placeholder,
									  spot5_placeholder,
									  current_vehicle_size,
									  start5, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final5,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot5_size, /*nature of the spot*/
									  spot5_number, /*nature of the spot*/
									  occupied[4],
									  password_correct[4],
									  password_go[4],
									  light5[9:0],
									  vehicle_size5[2:0]
									  );
									  
   parking_spot_control spot_5_control(car_in[4], /*info from the system*/
									 attempt[4], /*info from the system*/
									 password_go[4], /*info from the system*/
									 leave_to_spots[4], /*info from the system*/
									 password_correct[4],
									 CLOCK_50,
									 read_start_time[4],
									 read_end_time[4],
									 read_random_password[4],
									 read_user_password[4],
									 check_password[4],
									 if_empty[4],
									 password_maybe[4],
									 spot_state5,
									 calculate_fare[4]);
									 
	parking_spot_datapath spot_6_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[5],
									  read_end_time[5],
									  read_random_password[5],
									  read_user_password[5],
									  password_maybe[5],
									  if_empty[5],
									  check_password[5],
									  small_placeholder,
									  spot6_placeholder,
									  current_vehicle_size,
									  start6, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final6,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot6_size, /*nature of the spot*/
									  spot6_number, /*nature of the spot*/
									  occupied[5],
									  password_correct[5],
									  password_go[5],
									  light6[9:0],
									  vehicle_size6[2:0]
									  );
									  
   parking_spot_control spot_6_control(car_in[5], /*info from the system*/
									 attempt[5], /*info from the system*/
									 password_go[5], /*info from the system*/
									 leave_to_spots[5], /*info from the system*/
									 password_correct[5],
									 CLOCK_50,
									 read_start_time[5],
									 read_end_time[5],
									 read_random_password[5],
									 read_user_password[5],
									 check_password[5],
									 if_empty[5],
									 password_maybe[5],
									 spot_state6,
									 calculate_fare[5]);
									 
	parking_spot_datapath spot_7_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[6],
									  read_end_time[6],
									  read_random_password[6],
									  read_user_password[6],
									  password_maybe[6],
									  if_empty[6],
									  check_password[6],
									  medium_placeholder,
									  spot7_placeholder,
									  current_vehicle_size,
									  start7, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final7,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot7_size, /*nature of the spot*/
									  spot7_number, /*nature of the spot*/
									  occupied[6],
									  password_correct[6],
									  password_go[6],
									  light7[9:0],
									  vehicle_size7[2:0]
									  );
									  
   parking_spot_control spot_7_control(car_in[6], /*info from the system*/
									 attempt[6], /*info from the system*/
									 password_go[6], /*info from the system*/
									 leave_to_spots[6], /*info from the system*/
									 password_correct[6],
									 CLOCK_50,
									 read_start_time[6],
									 read_end_time[6],
									 read_random_password[6],
									 read_user_password[6],
									 check_password[6],
									 if_empty[6],
									 password_maybe[6],
									 spot_state7,
									 calculate_fare[6]);
									 
	parking_spot_datapath spot_8_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[7],
									  read_end_time[7],
									  read_random_password[7],
									  read_user_password[7],
									  password_maybe[7],
									  if_empty[7],
									  check_password[7],
									  medium_placeholder,
									  spot8_placeholder,
									  current_vehicle_size,
									  start8, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final8,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot8_size, /*nature of the spot*/
									  spot8_number, /*nature of the spot*/
									  occupied[7],
									  password_correct[7],
									  password_go[7],
									  light8[9:0],
									  vehicle_size8[2:0]
									  );
									  
   parking_spot_control spot_8_control(car_in[7], /*info from the system*/
									 attempt[7], /*info from the system*/
									 password_go[7], /*info from the system*/
									 leave_to_spots[7], /*info from the system*/
									 password_correct[7],
									 CLOCK_50,
									 read_start_time[7],
									 read_end_time[7],
									 read_random_password[7],
									 read_user_password[7],
									 check_password[7],
									 if_empty[7],
									 password_maybe[7],
									 spot_state8,
									 calculate_fare[7]);
									 
	parking_spot_datapath spot_9_datapath(current_time,
									  PASSWORD[9:0], /*info from password generator*/
									  SW[9:0], /*user's password input using SW*/
									  enter_pressed_out, /*should be a key?*/
									  read_start_time[8],
									  read_end_time[8],
									  read_random_password[8],
									  read_user_password[8],
									  password_maybe[8],
									  if_empty[8],
									  check_password[8],
									  large_placeholder,
									  spot9_placeholder,
									  current_vehicle_size,
									  start9, ///////////////////////////////////////////////////////////NEED TO CHANGE
									  final9,///////////////////////////////////////////////////////////NEED TO CHANGE
									  spot9_size, /*nature of the spot*/
									  spot9_number, /*nature of the spot*/
									  occupied[8],
									  password_correct[8],
									  password_go[8],
									  light9[9:0],
									  vehicle_size9[2:0]
									  );
									  
   parking_spot_control spot_9_control(car_in[8], /*info from the system*/
									 attempt[8], /*info from the system*/
									 password_go[8], /*info from the system*/
									 leave_to_spots[8], /*info from the system*/
									 password_correct[8],
									 CLOCK_50,
									 read_start_time[8],
									 read_end_time[8],
									 read_random_password[8],
									 read_user_password[8],
									 check_password[8],
									 if_empty[8],
									 password_maybe[8],
									 spot_state9,
									 calculate_fare[8]);

	
endmodule

module errors_prompt(input [3:0]errors, input clock, output reg errors_go);
	localparam  S_WAIT = 4'd0,
				   S_PROMPT = 4'd1;
	 reg [3:0] current_state=S_WAIT;
	 reg [3:0] next_state; 	
	 
	 always@(*)
				 begin: state_table 
						case (current_state)
							S_WAIT: next_state = (errors == 4'b0)? S_WAIT : S_PROMPT;
							S_PROMPT: next_state = S_WAIT;
						endcase
				end
				
				always@(posedge clock) begin 
											current_state <= next_state;
										end
										
				always@(*) begin
										errors_go = 1'b0;
										case(current_state)
											S_PROMPT : errors_go <= 1'b1;
										endcase
								end
endmodule