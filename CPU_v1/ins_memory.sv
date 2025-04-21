module instruction_memory
(
	input  logic clk,
	input  logic rst,
	input  logic [5:0] pc,
	output logic [31:0] ins
);

	localparam ins_mem_size = 16;

	logic [31:0] ins_mem [0:ins_mem_size-1];

	initial $readmemh("im.bit", ins_mem);

	// assign ins [32:0] = ins_mem[pc[5:2]];

	always_ff @(posedge rst or posedge clk) begin

		if (rst) ins <= 32'd0;
		if (clk) ins <= ins_mem[pc[5:2]];

	end

endmodule


/*      rst
        en
        hold
        iaddr
        idata
        daddr
        ddata
        drw
        fault
        zf
        cf
        sf

*/
