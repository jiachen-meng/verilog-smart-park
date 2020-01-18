module city_select(input read_city, input enable, input [2:0]select, output reg [1:0]city, output city_done_out);
//at the very beginning of the program, the user can choose one from
//the three following locations: NYC Downtown, Toronto Downtown, Missisauga


//NEED TO HAVE A CONFIRMATION FEATURE WHILE CHOOSING LOCATION
//INCLUDE ONE MORE KEY AS A CONDITION TO PROCEED IN FSM IMPLEMENTATION

//SHOULD USE LEDR TO INDICATE CURRENT CITY SELECTION
reg city_done = 1'b0;
	always @ (negedge enable) begin
	if (read_city) begin
		case(select[2:0])
		 3'b100: begin city = 2'b00; //case0, NYC Downtown
							city_done = 1'b1;
					end
		 3'b010: begin city = 2'b01; //case1, Toronto Downtown
							city_done = 1'b1;
					end
		 3'b001: begin city = 2'b10; //case2, Waterloo
							city_done = 1'b1;
					end
		 default: city = 2'b00;
		endcase
	end
	else 
	    city_done = 1'b0;
	end
assign city_done_out = city_done;
endmodule

module spot_select(input [8:0]select, output reg [3:0]spot);

	always @ (*) begin
		case(select[8:0])
		 9'b000000001: spot = 4'b0000;
		 9'b000000010: spot = 4'b0001; 
		 9'b000000100: spot = 4'b0010;
		 9'b000001000: spot = 4'b0011;  
		 9'b000010000: spot = 4'b0100; 
		 9'b000100000: spot = 4'b0101; 
		 9'b001000000: spot = 4'b0110; 
		 9'b010000000: spot = 4'b0111; 
		 9'b100000000: spot = 4'b1000; 
		 
		 
//		 default: spot = 4'b0000;
		endcase
	end
endmodule
