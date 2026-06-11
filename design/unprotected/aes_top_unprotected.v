module aes_top_unprotected (
	input	wire		clk,
	input	wire		rst_n,
	input	wire		start,
	input 	wire	[127:0]	plaintext,
	input 	wire	[127:0]	key,
	output 	reg	[127:0]	ciphertext,
	output 	reg 		done
);
	//FSM definition
	localparam STATE_IDLE = 3'b000;
	localparam STATE_INIT = 3'b001;
	localparam STATE_ROUND = 3'b010;
	localparam STATE_FINAL = 3'b011;
	localparam STATE_DONE = 3'b100;

	reg [2:0] 	current_state, next_state;
	reg [3:0]	round_count;

	reg [127:0]	state_reg;
	reg [127:0]	key_reg;
	
	//Inner CombiLogic & Path wire
	wire [127:0] subbytes_out;
	wire [127:0] shiftrows_out;
	wire [127:0] mixcolumns_out;
	wire [127:0] next_round_key;
	
	//At 10 Round(FINAL), mixcolums output
	wire [127:0] addkey_in = (current_state == STATE_FINAL) ? shiftrows_out : mixcolumns_out;

	//Integration
	// 1 Subbytes
	aes_subbytes u_subbytes (
		.in_state(state_reg),
		.out_state(subbytes_out)
	);
	// 2 ShiftRows
	aes_shiftrows u_shiftrows (
		.in_state(subbytes_out),
		.out_state(shiftrows_out)
	);
	// 3 MixColumns
	aes_mixcolumns u_mixcolumns (
		.in_state(shiftrows_out),
		.out_state(mixcolumns_out)
	);
	// KeyExpansion
	aes_key_expand u_key_expand (
		.key_in(key_reg),
		.round_count(round_count),
		.key_out(next_round_key)
	);

	//Sequential Logic
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			current_state <= STATE_IDLE;

			round_count 	<= 4'd0;
			state_reg 	<= 128'h0;
			key_reg 	<= 128'h0;
			ciphertext 	<= 128'h0;
			done 		<=1'b0;
		end else begin 
			current_state <= next_state;

			case (current_state)
				STATE_IDLE: begin
					done <= 1'b0;
					if (start) begin
						key_reg <= key; //Input initial key
					end
				end

				STATE_INIT: begin 
					state_reg 	<= plaintext ^ key_reg;
					round_count 	<= 4'd1;
				end

				STATE_ROUND: begin
					state_reg 	<= addkey_in ^ next_round_key;
					key_reg 	<= next_round_key;
					round_count	<= round_count + 1'b1;
				end

				STATE_FINAL: begin
					state_reg 	<= addkey_in ^ next_round_key;
					key_reg		<= next_round_key;
				end

				STATE_DONE: begin
					ciphertext	<= state_reg;
					done		<= 1'b1;
				end
			endcase
		end
	end

	//Combinational Logic
	always @(*) begin
		next_state = current_state;

		case (current_state)
			STATE_IDLE: begin
				if (start) 	next_state = STATE_INIT;
				else		next_state = STATE_IDLE;
			end
			STATE_INIT: begin
				next_state = STATE_ROUND;
			end
			STATE_ROUND: begin
				if (round_count == 4'd9) next_state = STATE_FINAL;
				else			 next_state = STATE_ROUND;
			end
			STATE_FINAL: begin
				next_state = STATE_DONE;
			end
			STATE_DONE: begin
				next_state = STATE_IDLE;
			end
			default: next_state = STATE_IDLE;
		endcase
	end
endmodule	
