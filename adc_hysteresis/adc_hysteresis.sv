module adc_hysteresis 
# (
	parameter high = 12'd3000,		
	parameter low = 12'd1000,
	parameter clk_hz = 25000000
) (
	input  clk,
	input  rst,				// Global RESET
	input  logic [11:0] d_signal,		// Digital signal from ADC
	output logic can_move_fwd		// Can move forward? (True/False)
);
	always_ff @(posedge clk or posedge rst) begin
		if (rst) can_move_fwd <= 0;
		else begin
			if (d_signal < low) can_move_fwd <= 0;
			else if (d_signal > high) can_move_fwd <= 1;
		end
	end
endmodule
