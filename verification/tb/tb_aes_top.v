`timescale 1ns/1ps

module tb_aes_top;
	reg clk;
	reg rst_n;
	reg start;
	reg [127:0] 	plaintext;
	reg [127:0] 	key;
	reg [127:0] 	ciphertext;
	reg 	  	done;

	reg [127:0] test_vectors [0:2];

	//DUT
	aes_top_unprotected u_dut (
		.clk(clk),
		.rst_n(rst_n),
		.start(start),
		.plaintext(plaintext),
		.key(key),
		.ciphertext(ciphertext),
		.done(done)
	);
	//50MHz
	always #10 clk = ~clk;

	// Main Test Scenario Sequence
	initial begin
		$dumpfile("results/aes_simulation.vcd");
		$dumpvars(0, tb_aes_top);

		clk 		= 0;
		rst_n 		= 0;
		start		= 0;
		plaintext	= 0;
		key		= 0;

		$readmemh("verification/vector/aes_vectors.hex", test_vectors);

		#40;
		rst_n = 1;
		#20;

		plaintext 	= test_vectors[0];
		key 		= test_vectors[1];

		$display("[SIM_INFO] 암호화 시작 - Plaintext: %h", plaintext);
		$display("[SIM_INFO] 암호화 시작 - Input Key: %h", key);

		@(posedge clk);
		start = 1'b1;
		@(posedge clk);
		start = 1'b0;

		while(!done) begin
			@(posedge clk);
			if (u_dut.current_state != 3'b000) begin
				$display("[ROUND_LOG] Clock %0d | Round: %0d | State_Reg: %h | Keg_Reg: %h", $time/20, u_dut.round_count, u_dut.state_reg, u_dut.key_reg);
			end
		end

		@(posedge clk);
		$display("[SIM_INFO] 암호화 완료 / 연산 종료 완료.");
		$display("[RESULT] Output Ciphertext: %h", ciphertext);
		$display("[EXPECT] Golden Ciphertext: %h", test_vectors[2]);

		if (ciphertext === test_vectors[2]) begin
			$display("==================================================");
			$display(" [SUCCESS] 기본형 코어 기능 검증 완벽 일치 (PASS) ");
			$display("==================================================");
		end
		else begin
			$display("==================================================");
			$display("[FAIL] NIST 표준 벡터와 결과 불일치 (BUG DETECTED)");
			$display("[DEBUG] XOR Mismatch Mask: %h", (ciphertext ^ test_vectors[2]));
			$display("==================================================");
		end

		#100
		$finish;
	end
	endmodule
       	       
