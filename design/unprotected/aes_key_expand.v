`timescale 1ns/1ps

module aes_key_expand (
	input	[127:0] key_in,
	input	[3:0]  	round_count,
	output	[127:0] key_out
);

	wire [31:0] w0 = key_in[127:96];
	wire [31:0] w1 = key_in[95:64];
	wire [31:0] w2 = key_in[63:32];
	wire [31:0] w3 = key_in[31:0];
	
	// RotWord
	wire [31:0] rot_w3 = {w3[23:0], w3[31:24]};
	wire [31:0] sub_w3;
	
	// SubWord
	aes_sbox sbox_b0 (.in_byte(rot_w3[31:24]), .out_byte(sub_w3[31:24]));
	aes_sbox sbox_b1 (.in_byte(rot_w3[23:16]), .out_byte(sub_w3[23:16]));
	aes_sbox sbox_b2 (.in_byte(rot_w3[15:8]), .out_byte(sub_w3[15:8]));
	aes_sbox sbox_b3 (.in_byte(rot_w3[7:0]), .out_byte(sub_w3[7:0]));

	//Rcon Table
	reg [7:0] rcon;
	always @(*) begin
		case (round_count)
			4'd1: 	rcon = 8'h01;
			4'd2:	rcon = 8'h02;
			4'd3:	rcon = 8'h04;
			4'd4: 	rcon = 8'h08;
			4'd5: 	rcon = 8'h10;
			4'd6:	rcon = 8'h20;
			4'd7:	rcon = 8'h40;
			4'd8: 	rcon = 8'h80;
			4'd9:	rcon = 8'h1b;
			4'd10:	rcon = 8'h36;
			default: rcon = 8'h00;
		endcase
	end
	//Rcon XOR, Sequential columns XOR Op
	wire [31:0] g_func = sub_w3 ^ {rcon, 24'h000000};

	wire [31:0] next_w0 = w0 ^ g_func;
	wire [31:0] next_w1 = w1 ^ next_w0;
	wire [31:0] next_w2 = w2 ^ next_w1;
	wire [31:0] next_w3 = w3 ^ next_w2;
	
	//key_out 
	assign key_out = {next_w0, next_w1, next_w2, next_w3};
	endmodule
