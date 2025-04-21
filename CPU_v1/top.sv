module top (
	input  logic clk25,
	input  logic [3:0] key,
	output logic [3:0] led
);

	logic [31:0] ins;
	logic [5:0] pc;

	RV32I RV_inst (
		.clk(clk25),
		.rst(key[0]),
		.en(key[1]),
		.hold(key[2]),
		.ins(ins),
		.pc(pc),
		.fault(led[0]),
		.zf(led[1]),
		.cf(led[2]),
		.sf(led[3])
	);

	instruction_memory im_inst (
		.clk(clk25),
		.rst(key[0]),
		.pc(pc),
		.ins(ins)
	);

endmodule
