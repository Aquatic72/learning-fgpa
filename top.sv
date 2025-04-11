module top (
	input  logic clk25,
	input  logic [3:0] key,
	inout  logic [3:0] gpio,
	output logic [3:0] led
);

	logic [7:0] motor_dc;
	logic [7:0] servo_dc;
	logic direction;
	logic ack;

	logic state;

	logic ir_ready;
	logic ctl_valid;
	logic [31:0] command;

	logic [11:0] d_dignal;
	logic can_move_fwd;

	assign led[0] = state;
	assign led[1] = direction;
	assign led[2] = motor_dc[7];
	assign led[3] = servo_dc[7];

	logic rst;
	assign rst = key[3];

        control
        # (
                .clk_hz(25000000),
		.sclk_hz(256),
		.servo_step(16)
        ) control_inst (
		.state(state),
		.clk(clk25),
		.rst(rst),
		.ir_ready(ir_ready),
		.command(command),
		.can_move_fwd(1'd1),
		.ctl_valid(ctl_valid),
		.ack(ack),
		.motor_dc(motor_dc),
		.direction(direction),
		.servo_dc(servo_dc)
        );

	motor_drv 
	# (
		.clk_hz(25000000),
		.pwm_hz(250)
	) motor_inst (
		.clk(clk25),
		.enable(1'd1),
		.rst(rst),
		.direction(direction),
		.duty_cycle(motor_dc),
		.pwm_outA(gpio[0]),
		.pwm_outB(gpio[1])
	);

	servo_pdm
	# (
		.clk_hz(25000000)
	) servo_inst (
		.rst(rst),
		.clk(clk25),
		.en(ctl_valid),
		.duty(servo_dc),
		.pdm_done(gpio[2])
	);

	ir_decoder decoder_inst (
		.clk(clk25),
		.rst(rst),
		.ack(ack),
		.enable(ctl_valid),
		.ir_input(gpio[3]),
		.ready(ir_ready),
		.command(command)
	);

	adc_hysteresis
	# (
		.clk_hz(25000000),
		.high(12'd3000),
		.low(12'd1000)
	) hysteresis_inst (
		.rst(rst),
		.clk(clk25),
		.d_signal(d_signal),
		.can_move_fwd(can_move_fwd)
	);
	
	adc_capture 
	# (
		.clk_hz(25000000),
		.sclk_hz(500000),
		.cycle_pause(30)
	) adc_capture_inst (
		.clk(clk25),
		.rst(rst),
		.ctl_valid(ctl_valid),
		.adc_ack(adc_ack),
		.address(address),
		.dout_bit(dout_bit),
		.sclk(sclk),
		.cs(cs),
		.adc_ready(adc_ready),
		.din_bit(din_bit),
		.d_signal(d_signal)
	);

/*	localparam CLOCK_DIV = 25000000 / (2 * sclk2_hz) - 1;
	logic [$clog2(CLOCK_DIV) - 1:0] clkdiv;

	logic sclk2;
	always_ff @(posedge clk25 or posedge rst) begin

		if (rst) begin
			clkdiv <= 'd0;
			sclk2 <= 1'd0;

		end else if (clkdiv == CLOCK_DIV) begin
			sclk2 <= ~sclk2;
		end else begin
			clkdiv <= clkdiv + 'd1;
		end

	end
*/
	always_ff @(posedge sclk or posedge rst) begin

		if (rst) begin
			adc_ack <= 1'd0;
			ctl_valid <= 1'd1;
			address <= 3'b000;			
			
		end else if (adc_ready) begin
			adc_ack <= 1'd1;
//			address <= address + 3'b001;
			address <= 3'b001;
			
		end else begin
			adc_ack <= 1'd0;
		end

	end

	assign adc_spi_sclk = sclk;
	assign adc_spi_mosi = din_bit;
	assign adc_spi_csn = cs;
	assign dout_bit = adc_spi_miso;

	assign gpio[0] = sclk;
	assign gpio[1] = cs;
	assign gpio[2] = din_bit;
	assign gpio[3] = dout_bit;

	assign rst = key[3];

	always_comb begin

		case (key[2:0])

			3'b001: led = d_signal[3:0];
			3'b010: led = d_signal[7:4];
			3'b011: led = d_signal[11:8];
			3'b100: led = {1'b0, address};

			default: led = {rst, cs, adc_ack, adc_ready};

		endcase

	end

endmodule
