`timescale 1ns/1ps

module aes_subbytes (
	input	 wire	 [127:0] in_state,
	output	 wire	 [127:0] out_state
);

	aes_sbox sbox0 	(.in_byte(in_state[127:120]),	.out_byte(out_state[127:120]));
	aes_sbox sbox1 	(.in_byte(in_state[119:112]),	.out_byte(out_state[119:112]));
	aes_sbox sbox2 	(.in_byte(in_state[111:104]),	.out_byte(out_state[111:104]));
	aes_sbox sbox3 	(.in_byte(in_state[103:96]),	.out_byte(out_state[103:96]));

	aes_sbox sbox4 	(.in_byte(in_state[95:88]),	.out_byte(out_state[95:88]));
	aes_sbox sbox5 	(.in_byte(in_state[87:80]),	.out_byte(out_state[87:80]));
	aes_sbox sbox6 	(.in_byte(in_state[79:72]),	.out_byte(out_state[79:72]));
	aes_sbox sbox7 	(.in_byte(in_state[71:64]),	.out_byte(out_state[71:64]));

	aes_sbox sbox8 	(.in_byte(in_state[63:56]),	.out_byte(out_state[63:56]));
	aes_sbox sbox9 	(.in_byte(in_state[55:48]),	.out_byte(out_state[55:48]));
	aes_sbox sbox10 (.in_byte(in_state[47:40]),	.out_byte(out_state[47:40]));
	aes_sbox sbox11 (.in_byte(in_state[39:32]),	.out_byte(out_state[39:32]));

	aes_sbox sbox12	(.in_byte(in_state[31:24]),	.out_byte(out_state[31:24]));
	aes_sbox sbox13	(.in_byte(in_state[23:16]),	.out_byte(out_state[23:16]));
	aes_sbox sbox14	(.in_byte(in_state[15:8]),	.out_byte(out_state[15:8]));
	aes_sbox sbox15	(.in_byte(in_state[7:0]),	.out_byte(out_state[7:0]));
	
	endmodule
