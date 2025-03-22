module ir_check (
	input  logic clk,
	input  logic rst,
	input  logic [31:0] nec_signal,
	output logic [2:0] command
);

	logic [7:0] nec_address;
	logic [7:0] nec_address_rev;
	logic [7:0] nec_command;
	logic [7:0] nec_command_rev;

	nec_address <= nec_signal[7:0];
	nec_address_rev <= nec_signal[15:8];
	nec_command <= nec_signal[23:16];
	nec_command_rev <= nec_signal[31:24];

	always_ff (posedge clk) begin
		if (nec_adress == ~nec_adress_rev && nec_command == ~nec_command_rev && ~rst) begin
			case (nec_command)
				8'b00000000: command <= 3'b000;
				8'b00000001: command <= 3'b000;
				// вписать команды c пульта ДУ!
			endcase		
		end
	end

endmodule
