module mecanum_drv
# (
	parameter clk_hz  = 25000000,
	parameter step_hz = 1000,
	parameter step_number = 6000
) (
	input  logic clk,
	input  logic rst,
	input  logic enable,
	input  logic ctl_valid,
	input  logic dx,
	input  logic dy,
	input  logic da,
	output logic nen,
	output logic dir,
	output logic step,
	output logic drv_ready
);

	always_ff @(posedge clk or posedge rst) begin

		if (rst) begin
			nen  <= 1'd1;
			dir  <= 1'd0;
			step <= 1'd0;

			drv_ready <= 1'd0;

		end else if (ctl_valid) begin
			


		end	
	
	end

endmodule
