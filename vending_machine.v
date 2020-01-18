module vending_machine_control(input gl_reset,input go, input full, input resetn, input clock, 
                               output reg resetting, output reg receiving, output [1:0]vending_state);
	reg [1:0] current_state = S_MONEY_WAIT; 
	reg [1:0] next_state; 
	 assign vending_state = current_state;
    localparam  S_MONEY_WAIT = 2'd0,
                S_MONEY_IN   = 2'd1,
                S_PAID       = 2'd2,
					 S_RESETTING  = 2'd3;
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
					S_MONEY_WAIT: next_state = go? S_MONEY_IN : S_MONEY_WAIT;
					S_MONEY_IN: next_state = full? S_PAID : S_MONEY_WAIT;
					//S_PAID: next_state = S_MONEY_WAIT;
					S_PAID: next_state = S_MONEY_WAIT;
					S_RESETTING: next_state = S_MONEY_WAIT;
					default: next_state = S_MONEY_WAIT;
				endcase
	 end
	 
	 always@(posedge clock)
    begin 
		if (gl_reset) begin
			current_state <= S_MONEY_WAIT;
		end
		else if (!resetn) begin //we use active low resetn
			current_state <= next_state;
		end
		else if (resetn) begin
			current_state <= S_RESETTING;
	   end
	 end
	 
	always @ ( * ) begin
    resetting = 1'b0;
	 receiving = 1'b0;
    case(current_state)
        S_RESETTING: resetting <= 1'b1;
//		  S_MONEY_WAIT: receiving <= 1'b1;
		  S_MONEY_IN: receiving <= 1'b1;
    endcase
   end

endmodule

//module top(input [9:0]SW,input [3:0]KEY, output [9:0]LEDR); //only for test purpose
//	wire [8:0]start, final1;
//	wire [1:0]city, money;
//	assign start = 9'd71;
//	assign final1 = 9'd73;
//	assign city = 2'b00;
//	assign size = 2'b00;
//	wire leave;
//	assign LEDR[0]=leave;
//	vending_machine_datapath(start,final1,size,city,SW[3:0],SW[9],KEY[0],leave);
//	
//endmodule

module vending_machine_datapath(input [8:0]start/*info from the spot*/, 
										input [8:0]final1/*info from the spot*/,
										input [1:0]size/*info from the spot*/, 
										input [1:0]city/*info from the city select*/,
										input [3:0]money/*from SW*/, 
										input receiving/*info from control*/, 
										input resetting/*info from control*/, 
										input clock,
										input calculate_fare,
										output leave/*info to update spot*/,
										output [9:0]fare_out,
										output [9:0]current_sum_out
										);	
			wire [9:0]fare;
			wire [9:0]current_sum;
			wire [9:0]new_sum;
			rate_converter converter (size, city, start, final1, calculate_fare, fare);
			ALU alu(receiving, current_sum, money, new_sum);
			Register register(.D(new_sum), .clock(clock), .resetn(resetting), .Q(current_sum));	
			assign leave = (current_sum >= fare & calculate_fare & receiving)? 1 : 0;
			assign fare_out = fare;
			assign current_sum_out = current_sum;
endmodule

module rate_converter(input [1:0]size /*info from the spot*/, 
								input [1:0]city/*info from the city select*/, 
								input [8:0] start/*info from the spot*/, 
								input [8:0] final1/*info from the spot*/, 
								input calculate_fare,
								output reg [9:0]fare);
		reg [9:0] original_fare_day, original_fare_night; //fares before any multiplier
		reg [1:0] citycode, sizecode; //multipliers involved
		always@(*)
		begin
			//fare = 10'd0;
			if (calculate_fare) begin
			if (final1 <= 9'd72) begin
				if ((final1 - start) <= 9'd6) begin
					original_fare_day = 10'd3;
   				original_fare_night =10'd0;
				end
				else if ((final1 - start) <=9'd12) begin
					original_fare_day =10'd5;
					original_fare_night =10'd0;
				end
				else if((final1 - start) <=9'd24) begin
					original_fare_day= 10'd8;
					original_fare_night =10'd0;
				end
				else begin
					original_fare_day= 10'd15;
					original_fare_night =10'd0;
				end
			end
			else begin
				if ((final1 - 9'd72) <= 9'd24) begin
						if(((9'd72 - start) <= 9'd6) & (start <= 9'd72)) begin
							original_fare_day = 10'd3;
						end
						else if(((9'd72 - start) <= 9'd12) & (start <= 9'd72)) begin
							original_fare_day = 10'd5;
						end
						else if(((9'd72 - start) <= 9'd24) & (start <= 9'd72)) begin
							original_fare_day = 10'd8;
						end
						else if(((9'd72 - start) > 9'd24) & (start <= 9'd72)) begin
							original_fare_day = 10'd15;
						end
						else begin
							original_fare_day = 10'd0;
						end
						original_fare_night =10'd5;
				end
				else begin
					if(((9'd72 - start) <= 9'd6) & (start <= 9'd72)) begin
							original_fare_day = 10'd3;
						end
						else if(((9'd72 - start) <= 9'd12) & (start <= 9'd72)) begin
							original_fare_day = 10'd5;
						end
						else if(((9'd72 - start) <= 9'd24) & (start <= 9'd72)) begin
							original_fare_day = 10'd8;
						end
						else if(((9'd72 - start) > 9'd24) & (start <= 9'd72)) begin
							original_fare_day = 10'd15;
						end
						else begin
							original_fare_day = 10'd0;
						end
					   original_fare_night = 10'd15;
				end
			end
			
			if (city == 2'b01) begin
				citycode = 2'd2; //Toronto Downtown
			end
			else if (city == 2'b00) begin
				citycode = 2'd3; //NYC Downtown
			end
			else begin
				citycode = 2'd1; //Waterloo
			end
			
			if (size == 2'b01) begin
				sizecode = 2'd2; //medium
			end
			else if (size == 2'b11) begin
				sizecode = 2'd3; //large
			end
			else if (size == 2'b10) begin
				sizecode = 2'd1; //small
			end
			fare = (original_fare_day + original_fare_night) * citycode * sizecode;
		end
		end
			
endmodule


module Register(D, clock, resetn, Q);
	input [9:0]D;
	input clock, resetn;
	output reg [9:0]Q = 0;

	always@(posedge resetn, posedge clock)
	begin
	if (resetn)
		Q <= 1'b0;
	else
		Q <= D;
	end 		
endmodule

module ALU(input receiving, input [9:0]current_sum, input[3:0]SW, output reg[9:0] new_sum = 0);

	
	always @(*)
	begin
		if (receiving) begin
		case (SW[3:0])
			4'b0001 : //$1
				new_sum = current_sum + 10'd1;
			4'b0010 : //$2
				new_sum = current_sum + 10'd2;
			4'b0100 : //$5
				new_sum = current_sum + 10'd5;
			4'b1000 : //credit or debit
				new_sum = 10'd300;
		   4'b0000 : new_sum = current_sum;
			default: //default case
				new_sum = current_sum;
		endcase
		end
	end
endmodule



