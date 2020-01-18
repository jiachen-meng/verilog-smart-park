//module password_input(input [9:0]user_input, input enable, output reg [9:0]user_password);//user input=[9:0]sw,key=enable,
//	always@(posedge enable) begin
//			user_password <= user_input;
//		end
//endmodule
//		


//module time_counter_parking(input clock, output ten_minutes); 
////this counter should output a "1" per ideal ten minutes
////it should only start to count when enabled (by reset to original value)
//
//
//	assign ten_minutes = !Q;
//	reg [26:0] Q = 0;
//	
//	always @(posedge clock) begin
//		if (Q)
//			Q <= Q - 1;
//		else
//			Q <= 50000000;
//	end
//endmodule



//module general_clock(input ten_minutes, output reg [8:0] current_time = 0);
//	
//	always @(posedge ten_minutes) begin
//		current_time = current_time + 1;
////		time_up = 1'b0;
////		if (current_time >= 9'd145) begin
////			time_up = 1'b1;
////		end
//	end
//endmodule

module general_clock(input clock, output reg [8:0] current_time = 0);
	wire ten_minutes;
	assign ten_minutes = !Q;
	reg [26:0] Q = 0;
	
	always @(posedge clock) begin
		if (Q)
			Q <= Q - 1;
		else
			Q <= 50000000;
	end
	always @(posedge ten_minutes) begin
		current_time = current_time + 1;
//		time_up = 1'b0;
//		if (current_time >= 9'd145) begin
//			time_up = 1'b1;
//		end
	end
endmodule



//module top(input [9:0]SW, input [3:0]KEY, input CLOCK_50, output [9:0]LEDR); //only for testing purpose
//	wire ten_minutes;
//	wire [8:0]current_time;
//	wire [9:0]correct_password;
//	time_counter_parking u1(CLOCK_50, ten_minutes);
//	general_clock u2(ten_minutes, current_time);
//	assign correct_password = 10'b1111100000;
//	assign start = 9'd30;
//	assign final = 9'd31;
//	parking_spot_datapath u3( current_time,
//									  correct_password, /*info from password generator*/
//									  SW[9:0], /*user's password input using SW*/
//									  input read_start_time,
//									  input read_end_time,
//									  input read_random_password,
//									  input read_user_password;
//									  input if_empty,
//									  input check_password,
//									  output reg [8:0]start, 
//									  output reg [8:0]final,
//									  output [1:0]size, /*nature of the spot*/
//									  output [3:0]spot_number, /*nature of the spot*/
//									  output occupied,
//									  output reg password_correct
//									  );
	

module parking_spot_datapath(input [8:0]current_time,
									  input [9:0]correct_password, /*info from password generator*/
									  input [9:0]user_input, /*user's password input using SW*/
									  input password_done, /*should be a key?*/
									  input read_start_time,
									  input read_end_time,
									  input read_random_password,
									  input read_user_password,
									  input password_maybe,
									  input if_empty,
									  input check_password,
									  input [1:0]size_in,
									  input [3:0]spot_number_in,
									  input [2:0]current_vehicle_size,
									  output [8:0]start, 
									  output [8:0]final1,
									  output [1:0]size, /*nature of the spot*/
									  output [3:0]spot_number, /*nature of the spot*/
									  output occupied,
									  output password_correct_out,
									  output password_go_out,
									  output [9:0]light,
									  output reg [2:0]current_vehicle_size_remember = 3'b0
									  );
									  
									  reg [9:0]stored_password = 10'b0;
									  reg [9:0]user_password = 10'b0;
									  reg [8:0]start_temp = 9'b0;
									  reg [8:0]final1_temp = 9'b0;
									  assign start = start_temp;
									  assign final1 = final1_temp;
									  
									  always @ (posedge  read_start_time) begin //read start time from general clock count
											start_temp <= current_time;
											current_vehicle_size_remember <= current_vehicle_size;
									  end
									  
									  always @ (posedge  read_end_time) begin //read final time from general clock count
											final1_temp <= current_time;
									  end
									  
									  always @ (posedge read_random_password) begin
											stored_password = correct_password;
									  end
									  
									  
									  assign light[9:0] = stored_password; //////////////////////////A problem here
									  
									  always@(posedge read_user_password) begin
											user_password <= user_input;
											
									  end
									  
									  
									  reg password_correct = 1;
									  assign password_correct_out = password_correct;
									  always @ (posedge check_password) begin
											password_correct = 0;
											password_correct = ((stored_password) == (user_password)) ? 1:0;
									  
									  end
									  
									  reg password_go = 1'b0;
									  assign password_go_out = password_go;
									  always @ (posedge password_done) begin
											password_go =1'b0;
											if (password_done & password_maybe)
											password_go = 1'b1;
									  end
										
									  assign occupied = !if_empty;
									  
									  assign size = size_in; //THIS WILL CHANGE ACCORDINGLY
									  assign spot_number = spot_number_in; //THIS WILL CHANGE ACCORDINGLY
									  

endmodule

module parking_spot_control(input car_in, /*info from the system*/
									 input attempt, /*info from the system*/
									 input password_go, /*info from the system*/
									 input leave, /*info from the system*/
									 input password_correct,
									 input clock,
									 output reg read_start_time,
									 output reg read_end_time,
									 output reg read_random_password,
									 output reg read_user_password,
									 output reg check_password,
									 output reg if_empty,
									 output reg password_maybe,
									 output [2:0] spot_state,
									 output reg calculate_fare);
									 
									 reg [2:0] current_state = S_EMPTY;
									 reg [2:0] next_state; 
									 assign spot_state = current_state;
									 
									 localparam  S_EMPTY = 3'd0,
													 S_OCCUPIED   = 3'd1,
													 S_PASSWORD = 3'd3,
													 S_PAYMENT       = 3'd2,
													 S_CHECK_PASSWORD = 3'd4;
													 
									  //Next state logic aka our state table
									  always@(*)
									  begin: state_table 
												case (current_state)
													S_EMPTY: next_state = car_in? S_OCCUPIED : S_EMPTY;
													S_OCCUPIED: next_state = attempt? S_PASSWORD : S_OCCUPIED;
													S_PASSWORD: next_state = password_go? S_CHECK_PASSWORD : S_PASSWORD;
													S_CHECK_PASSWORD: next_state = password_correct? S_PAYMENT :S_PASSWORD;
													S_PAYMENT: next_state = leave? S_EMPTY : S_PAYMENT;
												endcase
									  end
									  
									always@(posedge clock) begin 
											current_state <= next_state;
										end				 
										
									always@(*) begin
										read_start_time = 1'b0;
										read_end_time = 1'b0;
										read_user_password = 1'b0;
										read_random_password = 1'b0;
										check_password = 1'b0;
										if_empty = 1'b0;
										password_maybe = 1'b0;
										calculate_fare = 1'b0;
										case(current_state)
											S_EMPTY : if_empty <= 1'b1;
											S_OCCUPIED: begin
															read_start_time <= 1'b1;
															read_random_password <= 1'b1;
															end
											S_PAYMENT: begin read_end_time <= 1'b1;
															calculate_fare <= 1'b1;
															end
											
											S_PASSWORD: password_maybe <= 1'b1;
											S_CHECK_PASSWORD: begin
															check_password <=1'b1;
															read_user_password <= 1'b1;
														  end
										endcase
									end
endmodule

