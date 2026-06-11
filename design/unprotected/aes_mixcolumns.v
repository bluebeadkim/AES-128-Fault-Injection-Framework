`timescale 1ns/1ps

module aes_mixcolumns (
	input 	wire [127:0] in_state, 
	output 	wire [127:0] out_state
);
	// g_mul2: x02 operation (xtime)
	function [7:0] g_mul2;
		input [7:0] b;
		begin
			g_mul2 = (b[7] == 1'b1) ? ((b << 1) ^ 8'h1b) : (b << 1);
		end
	endfunction

	// g_mul3: x03 operation (03 = 02 XOR 01)
	function [7:0] g_mul3;
		input [7:0] b;
		begin
			g_mul3 = g_mul2(b) ^ b;
		end
	endfunction

	// Col 0
	wire [7:0] c0_b0 = in_state[127:120];
	wire [7:0] c0_b1 = in_state[119:112];
	wire [7:0] c0_b2 = in_state[111:104];
	wire [7:0] c0_b3 = in_state[103:96];
	
	wire [7:0] c0_out0 = g_mul2(c0_b0) ^ g_mul3(c0_b1) ^ c0_b2 ^ c0_b3;
	wire [7:0] c0_out1 = c0_b0 ^ g_mul2(c0_b1) ^ g_mul3(c0_b2) ^c0_b3;
	wire [7:0] c0_out2 = c0_b0 ^ c0_b1 ^ g_mul2(c0_b2) ^ g_mul3(c0_b3);
	wire [7:0] c0_out3 = g_mul3(c0_b0) ^ c0_b1 ^ c0_b2 ^ g_mul2(c0_b3);
	
	// Col 1
	wire [7:0] c1_b4 = in_state[95:88];
	wire [7:0] c1_b5 = in_state[87:80];
	wire [7:0] c1_b6 = in_state[79:72];
	wire [7:0] c1_b7 = in_state[71:64];
	
	wire [7:0] c1_out4 = g_mul2(c1_b4) ^ g_mul3(c1_b5) ^ c1_b6 ^ c1_b7;
	wire [7:0] c1_out5 = c1_b4 ^ g_mul2(c1_b5) ^ g_mul3(c1_b6) ^ c1_b7;
	wire [7:0] c1_out6 = c1_b4 ^ c1_b5 ^ g_mul2(c1_b6) ^ g_mul3(c1_b7);
	wire [7:0] c1_out7 = g_mul3(c1_b4) ^ c1_b5 ^ c1_b6 ^ g_mul2(c1_b7);
	
	// Col 2
	wire [7:0] c2_b8 = in_state[63:56];
	wire [7:0] c2_b9 = in_state[55:48];
	wire [7:0] c2_b10 = in_state[47:40];
	wire [7:0] c2_b11 = in_state[39:32];
	
	wire [7:0] c2_out8 = g_mul2(c2_b8) ^ g_mul3(c2_b9) ^ c2_b10 ^ c2_b11;
	wire [7:0] c2_out9 = c2_b8 ^ g_mul2(c2_b9) ^ g_mul3(c2_b10) ^ c2_b11;
	wire [7:0] c2_out10 = c2_b8 ^ c2_b9 ^ g_mul2(c2_b10) ^ g_mul3(c2_b11);
	wire [7:0] c2_out11 = g_mul3(c2_b8) ^ c2_b9 ^ c2_b10 ^ g_mul2(c2_b11);
	
	// Col 3
	wire [7:0] c3_b12 = in_state[31:24];
	wire [7:0] c3_b13 = in_state[23:16];
	wire [7:0] c3_b14 = in_state[15:8];
	wire [7:0] c3_b15 = in_state[7:0];
	
	wire [7:0] c3_out12 = g_mul2(c3_b12) ^ g_mul3(c3_b13) ^ c3_b14 ^ c3_b15;
	wire [7:0] c3_out13 = c3_b12 ^ g_mul2(c3_b13) ^ g_mul3(c3_b14) ^ c3_b15;
	wire [7:0] c3_out14 = c3_b12 ^ c3_b13 ^ g_mul2(c3_b14) ^ g_mul3(c3_b15);
	wire [7:0] c3_out15 = g_mul3(c3_b12) ^ c3_b13 ^ c3_b14 ^ g_mul2(c3_b15);

	assign out_state = {
		c0_out0, c0_out1, c0_out2, c0_out3,
		c1_out4, c1_out5, c1_out6, c1_out7,
		c2_out8, c2_out9, c2_out10, c2_out11,
		c3_out12, c3_out13, c3_out14, c3_out15
		};	
endmodule

