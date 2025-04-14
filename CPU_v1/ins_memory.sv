module instructions
(
	input  logic clk,
	input  logic rst,
	input  logic [11:0] pc,
	output logic [31:0] ins
);

	logic [31:0] ins_memory [0:255];

	initial begin
		memory[0] = 32'h00000000;
		memory[1] = 32'h00000000;
		memory[2] = 32'h00000000;
		memory[3] = 32'h00000000;
		memory[4] = 32'h00000000;
	end

	always_ff @(posedge clk or posedge rst) begin

		if (rst) begin
			ins <= 32'd0;

		end else begin
			ins <= program[pc[11:2]]			
		
		end
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
