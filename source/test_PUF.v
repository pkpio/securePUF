`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:03:50 07/09/2014 
// Design Name: 
// Module Name:    testUF 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: In test mode trigger is given as negative test fsm clock
// so that we get data on every clock cycle.
//
//////////////////////////////////////////////////////////////////////////////////
module testPUF #(
	parameter N_CB = 32,
	parameter CHALLENGE_WIDTH = 32,
	parameter PDL_CONFIG_WIDTH = 128,
	parameter RESPONSE_WIDTH = 6)(
	//Siam's ports
	input wire clk_1, // main clock for FSM
	input wire clk_2, // its freq is half that of clk_1, for the test 1.2 and 1.3 testing block will receive one input bit for two resonse bits from PUF
	input wire clk_RNG, // its freq is 8 times that of clk_1, challenge bits are generated at a higher rate
	input wire rst,
	//input wire start, // connect this to a push button
	//input wire sw,
	output reg mem_we, // write enable for memory
	output reg [12:0] mem_waddr, // write address for memory
	output reg [7:0] mem_din, // data in for memory
	//output wire [7:0] test_result,
	 
	 //Praveen's ports
	input wire clk,
	input wire reset,
	input wire calb_trigger,
	input wire [CHALLENGE_WIDTH-1:0] pc_challenge,
	input wire [PDL_CONFIG_WIDTH-1:0] pdl_config,
	output wire done,
	output wire [RESPONSE_WIDTH-1:0] raw_response,
	//output wire xor_response,
	
	// Other ports for integration
	input wire calibrate,  //Puf mode - calib or test.
	input wire read_temp, // do temperature test if set.
	input wire test_start, // To start the test FSM.
	output reg test_done,  //To tell SIRC FSM, test is done. They are using different clocks. 
   output reg [7:0] LED
	 );

parameter T = 19999;
	 
	 wire [N_CB-1:0] C;
	 reg [N_CB-1:0] gen_challenge;
	 wire [CHALLENGE_WIDTH-1:0] puf_challenge;
	 wire trigger;
	 wire test_trigger;
	 
	 
	 (* KEEP = "TRUE" *) (* S = "TRUE" *) wire xor_response;
	 
	// Choose challenge source based on mode
	assign puf_challenge[CHALLENGE_WIDTH-1:0] = (calibrate==1) ? pc_challenge : gen_challenge[CHALLENGE_WIDTH-1:0];


///////////		Challenge generator		////////////
	 challenge_gen #(N_CB) challenge_gen(
    .clk(clk_RNG),
	 .rst(rst),
    .C(C)
    );


//////////			Core PUF 			/////////////////
	mapping #(
		.CHALLENGE_WIDTH(32),
		.PDL_CONFIG_WIDTH(128),
		.RESPONSE_WIDTH(6)
	) puf_map (
		.clk(clk),
		.reset(reset),
		.trigger(trigger),
		.pdl_config(pdl_config),
		.challenge(puf_challenge),
		.done(done),
		.raw_response(raw_response),
		.xor_response(xor_response)
	);
	 
	// trigger generator
	assign trigger = (calibrate == 1)?calb_trigger:test_trigger;
	 
	
///////////		Clocks generator		////////////	
	wire clk_test;
	reg sel_clk_test;
	
	BUFGMUX_CTRL mux_clk_test (
	.O(clk_test), // 1-bit output: Clock output
	.I0(clk_1), // 1-bit input: Clock input (S=0)
	.I1(clk_2), // 1-bit input: Clock input (S=1)
	.S(sel_clk_test) // 1-bit input: Clock select
	);
	
	
///////////			NIST			////////////
	reg test_bit;
	wire [7:0] test_result;
	
	NIST NIST(
	.clk(clk_test),
	.rst(rst),
	.rand(test_bit),
	.test_result(test_result)
	);
	
	reg [14:0] test_bit_count; // count no of bits for tests; 
	reg [7:0] test_count; // no of testing rounds
	reg [7:0] test [7:0]; // count how many times each test passes
	reg [3:0] test_index;
	
	reg [7:0] count_resp, sum_resp;

   reg hold_resp_bit, bb;
	reg [N_CB-1:0] hold_challenge, challenge_bit_ctr, challenge_bit_ctr_0;
	

///// System Monitor //////
	reg signed [10:0] Temperature;
	reg [6:0] SysMonAddr;
	wire SysMonRdy;
	wire [15:0] SysMonData;
	SystemMonitor SystemMonitor1(
		 .clk(clk_1),
		 .DADDR_IN(SysMonAddr),
		 .DRDY_OUT(SysMonRdy),
		 .DO_OUT(SysMonData)
    );
    reg [5:0] state;


	 assign test_trigger = ~clk_1;
	 
	 always @(posedge clk_1) begin 
	 
		 if (rst) begin
			state <= 0;
		 end
		 else begin
			case (state)
		
			0:	begin
				mem_we <= 1; 
				mem_waddr <= 0;
				test_done <= 0;
				
				// Test mode operation requested
				if (test_start) begin
					
					// Read temperature mode
					if (read_temp) begin
						state <= 30;
					end
					
					// Normal test mode
					else begin
						state <= 1;
					end
					
				end
				
				// Calibration mode
				else begin
					state <= 0;
				end
				
				end

     1:	begin
			  if (~SysMonRdy) state <= 1;
		   	else begin
		    		Temperature <= {1'b0,SysMonData[15:6]};
			     	state <= 2;			
		    end
		    end
			
			2:	begin
				// init
				test_bit_count<= 0; 
				test_count <= 0; 
				test[0] <= 0; 
				test[1] <= 0; 
				test[2] <= 0; 
				test[3] <= 0;
				test[4] <= 0; 
				test[5] <= 0; 
				test[6] <= 0; 
				test[7] <= 0; 
				test_index <= 0;
				
				
				sel_clk_test <= 0; // for test 1.1 one response bit is generated per challenge, testing block operates at the same freq as the FSM
				
				gen_challenge <= C; // feed challenge
				
				state <= 3;
				end
				
			3:	begin
				gen_challenge <= C; // feed challenge
				test_bit <= xor_response; // read response and feed that to testing block
				test_bit_count <= test_bit_count+1; // count response bits
				
				if (test_bit_count == T) state <= 4; // one round of testing is done, go to next state and read test results
				else state <= 3; 
				end
				
			4: begin
				gen_challenge <= C; // feed challenge, while we are reading the test results, we should keep on testing
				test_bit <= xor_response; // read response and feed that to testing block
				test_bit_count <= 0; // reset bit count for next round of testing
				
				// add the results
				test[0] <= test[0] + test_result[0];
				test[1] <= test[1] + test_result[1];
				test[2] <= test[2] + test_result[2];
				test[3] <= test[3] + test_result[3];
				test[4] <= test[4] + test_result[4];
				test[5] <= test[5] + test_result[5];
				test[6] <= test[6] + test_result[6];
				test[7] <= test[7] + test_result[7];
				
				test_count <= test_count + 1;	// count the no of testing rounds		
				if (test_count==254) state <= 5;  // testing done for the first phase, go to next state to store the test results
				else state <= 3; // keep on testing
				end
				
			5:	begin
				gen_challenge <= C; // feed challenge
				test_bit <= xor_response; // read response and feed that to testing block
				
				mem_waddr <= mem_waddr + 1;
				test_index <= test_index + 1;
				if (test_index == 0) mem_din <= test[0];
				else if (test_index == 1) mem_din <= test[1];
				else if (test_index == 2) mem_din <= test[2];
				else if (test_index == 3) mem_din <= test[3];
				else if (test_index == 4) mem_din <= test[4];
				else if (test_index == 5) mem_din <= test[5];
				else if (test_index == 6) mem_din <= test[6];
				else if (test_index == 7) mem_din <= test[7];
							
				bb <= 1;
				
				if (test_index == 7) state <= 10; // storing test 1.1 results is done, go to test 1.2 
				else state <= 5; // keep on stroing test results
				end
			
			10:begin
				// init
				test_bit_count <= 0; 
				test_count <= 0; 
				test[0] <= 0; 
				test[1] <= 0; 
				test[2] <= 0; 
				test[3] <= 0;
				test[4] <= 0; 
				test[5] <= 0; 
				test[6] <= 0; 
				test[7] <= 0; 
				test_index <= 0;	

				if (bb) challenge_bit_ctr <= 1;
				else challenge_bit_ctr <= (challenge_bit_ctr << 1);
				bb <= 0;
				
				sel_clk_test <= 1; // for test 1.2 one response bit is generated per two challenges, testing block operates at half freq of the FSM
				
				gen_challenge <= C; // feed challenge
				hold_challenge <= C; // store challenege for next opertaion
				
				state <= 11;
				end
				
			11:begin
				gen_challenge <= hold_challenge^challenge_bit_ctr; // feed the same challenge with just one bit inverted
				hold_resp_bit <= xor_response; // store the response for previous challenge
				
				state <= 12;
				end
			
			12:begin
				gen_challenge <= C; // feed new challenge
				hold_challenge <= C; // store challenege for next opertaion
				
				test_bit <= xor_response^hold_resp_bit; // now we test the randomness in transition			
				test_bit_count <= test_bit_count+1; // count test bits
				
				if (test_bit_count == T) state <= 13;
				else state <= 11;
				end
				
			13:begin
				gen_challenge <= hold_challenge^challenge_bit_ctr; // feed the same challenge with just one bit inverted
				hold_resp_bit <= xor_response; // store the response for previous challenge
				
				test_bit_count <=  0; // reset bit count for next round of testing
				
				// add the results
				test[0] <= test[0] + test_result[0];
				test[1] <= test[1] + test_result[1];
				test[2] <= test[2] + test_result[2];
				test[3] <= test[3] + test_result[3];
				test[4] <= test[4] + test_result[4];
				test[5] <= test[5] + test_result[5];
				test[6] <= test[6] + test_result[6];
				test[7] <= test[7] + test_result[7];
				
				test_count <= test_count + 1;	// count the no of testing rounds		
				if (test_count==254) state <= 14;  // testing done for one round, go to next state to store the test results
				else state <= 12; // keep on testing
				end
				
			14:begin
				
				mem_waddr <= mem_waddr + 1;
				test_index <= test_index + 1;
				if (test_index == 0) mem_din <= test[0];
				else if (test_index == 1) mem_din <= test[1];
				else if (test_index == 2) mem_din <= test[2];
				else if (test_index == 3) mem_din <= test[3];
				else if (test_index == 4) mem_din <= test[4];
				else if (test_index == 5) mem_din <= test[5];
				else if (test_index == 6) mem_din <= test[6];
				else if (test_index == 7) mem_din <= challenge_bit_ctr[7:0];
				
				if (test_index == 7) begin
					if (challenge_bit_ctr[N_CB-1]) begin
						bb <= 1;
						state <= 20; // reached the last bit
					end
					else state <= 10; // start testing for next index in challenge vector
				end
				else state <= 14; // keep on stroing test results
				end
				
			20:begin
				// init
				test_bit_count <= 0; 
				test_count <= 0; 
				test[0] <= 0; 
				test[1] <= 0; 
				test[2] <= 0; 
				test[3] <= 0;
				test[4] <= 0; 
				test[5] <= 0; 
				test[6] <= 0; 
				test[7] <= 0; 
				test_index <= 0;	

				if (bb) begin
					challenge_bit_ctr <= 1;
					challenge_bit_ctr_0 <= 1;
				end
				else begin 
					challenge_bit_ctr <= challenge_bit_ctr_0;
				end
				bb <= 0;
				
				sel_clk_test <= 1; // for test 1.2 one response bit is generated per two challenges, testing block operates at half freq of the FSM
				
				gen_challenge <= C; // feed challenge
				hold_challenge <= C; // store challenege for next opertaion
				
				state <= 21;
				end
				
			21:begin
				gen_challenge <= hold_challenge^challenge_bit_ctr; // feed the same challenge with just one bit inverted
				hold_resp_bit <= xor_response; // store the response for previous challenge
				
				state <= 22;
				end
			
			22:begin
				gen_challenge <= C; // feed new challenge
				hold_challenge <= C; // store challenege for next opertaion
				challenge_bit_ctr <= {challenge_bit_ctr[(N_CB-2):0], challenge_bit_ctr[N_CB-1]};
				
				test_bit <= xor_response^hold_resp_bit; // now we test the randomness in transition			
				test_bit_count <= test_bit_count+1; // count test bits
				
				if (test_bit_count == T) state <= 23;
				else state <= 21;
				end
				
			23:begin
				gen_challenge <= hold_challenge^challenge_bit_ctr; // feed the same challenge with just one bit inverted
				hold_resp_bit <= xor_response; // store the response for previous challenge
				
				test_bit_count <=  0; // reset bit count for next round of testing
				
				// add the results
				test[0] <= test[0] + test_result[0];
				test[1] <= test[1] + test_result[1];
				test[2] <= test[2] + test_result[2];
				test[3] <= test[3] + test_result[3];
				test[4] <= test[4] + test_result[4];
				test[5] <= test[5] + test_result[5];
				test[6] <= test[6] + test_result[6];
				test[7] <= test[7] + test_result[7];
				
				test_count <= test_count + 1;	// count the no of testing rounds		
				if (test_count==254) state <= 24;  // testing done for one round, go to next state to store the test results
				else state <= 22; // keep on testing
				end
				
			24:begin
				
				mem_waddr <= mem_waddr + 1;
				test_index <= test_index + 1;
				if (test_index == 0) mem_din <= test[0];
				else if (test_index == 1) mem_din <= test[1];
				else if (test_index == 2) mem_din <= test[2];
				else if (test_index == 3) mem_din <= test[3];
				else if (test_index == 4) mem_din <= test[4];
				else if (test_index == 5) mem_din <= test[5];
				else if (test_index == 6) mem_din <= test[6];
				else if (test_index == 7) mem_din <= challenge_bit_ctr_0[7:0];
				
				if (test_index == 7) begin
					challenge_bit_ctr_0 <= {challenge_bit_ctr_0[(N_CB-2):0],1'b1};
					if (&challenge_bit_ctr_0) state <= 25; // reached the end of test 1.3
					else state <= 20; // start testing for next index in challenge vector
				end
				else state <= 24; // keep on stroing test results
				end

    25:begin
			test_index <= 0;
			if (SysMonRdy) begin
				Temperature <= Temperature + SysMonData[15:6];
				state <= 26;
			end
			else state <= 25;
			end
			
		26:begin
			mem_waddr <= mem_waddr + 1;
			test_index <= test_index + 1;
			
			if (test_index == 0) mem_din <= {5'b0,Temperature[10:8]};
			else mem_din <= Temperature[7:0];
			
			if (test_index == 1) state <= 63;
			else state <= 26;
			end
				
			30:begin
				Temperature <= 0;
				SysMonAddr <= 0;
				
				sel_clk_test <= 0;
				
				state <= 31;
				end
				
			31:begin			
				sum_resp <= 0;
				count_resp <= 0;
				test_index <= 0;
				
				gen_challenge <= C;
				hold_challenge <= C;
		

				if (~read_temp) state <= 36;
				else if (~SysMonRdy) state <= 31;
				else if (Temperature[10:1] >= SysMonData[15:6]) state <= 31;
				else begin
					Temperature <= {1'b0,SysMonData[15:6]};
					state <= 32;			
				end
				
				end
				
			32:begin
				gen_challenge <= hold_challenge;
				
				sum_resp <= sum_resp + xor_response;
				count_resp <= count_resp + 1;
				
				if (count_resp == 99) state <= 33;
				else state <= 32;
				end
				
			33:begin		
				gen_challenge <= C;
				hold_challenge <= C;
				
				mem_waddr <= mem_waddr + 1;
				test_index <= test_index + 1;
				
				mem_din <= sum_resp;
				sum_resp <= 0;
				count_resp <= 0;
				
				if (test_index == 5) state <= 34;
				else state <= 32;			
				end
				
			34:begin
				if (SysMonRdy) begin
					Temperature <= Temperature + SysMonData[15:6];
					state <= 35;
				end
				else state <= 34;
				end
				
			35:begin
				mem_waddr <= mem_waddr + 1;
				test_index <= test_index + 1;
				
				if (test_index == 6) mem_din <= {5'b0,Temperature[10:8]};
				else mem_din <= Temperature[7:0];
				
				if (test_index == 7) state <= 31;
				else state <= 35;
				end
				
			36:begin
				mem_waddr <= mem_waddr + 1;
				mem_din <= 8'HFF;
				
				state <= 63;
				end
				
			63:begin
				sel_clk_test <= 0;
				gen_challenge <= C; // feed challenge
				test_bit <= xor_response; // read response and feed that to testing block
				
				mem_we <= 0; // now we read the results from memory
				test_done <= 1;
				state <= 63;
				end
			
			endcase
		 end
		
	end


endmodule
