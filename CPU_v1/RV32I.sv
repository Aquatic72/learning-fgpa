module RV32I (
	input  logic clk,
	input  logic rst,
	input  logic en,		// CPU doesn't work but sticked with instruction memory and data memory buses
	input  logic hold,		// CPU doesn't work and separated from instruction memory and data memory buses

	output logic [5:0] pc,		// Instruction address in instruction memory (128 32-bit words, 512 memory cells)
	input  logic [31:0] ins,	// Instruction (32-bit)
	output logic [11:0] daddr,	// Data address in data memory
	inout  logic [31:0] ddata,	// Data (32-bit)

	output logic drw,		// Read (0) or write (1) flag
	output logic fault,		// Operation in ALU didn't finished normally (error)
	output logic zf,		// Operation in ALU finished with 0
	output logic cf,		// Operation in ALU finished with overflow
	output logic sf			// Operation in ALU finished with pos (1) or neg (0) number
);

	localparam int R   = 1;		// Setting up indexes for all formations (instruction types, RISUBJ)
	localparam int I1  = 2;
	localparam int I2  = 3;
	localparam int I3  = 4;
	localparam int I4  = 5;
	localparam int S   = 6;
	localparam int U1  = 7;
	localparam int U2  = 8;
	localparam int B   = 9;
	localparam int J   = 10;
	localparam int UWN = 0;		// UKNOWN instruction type

	logic [6:0]  opcode;
	logic [4:0]  rs1;
	logic [4:0]  rs2;
	logic [4:0]  rd;

	logic [21:0] imm;

	logic [2:0] funct3;
	logic [6:0] funct7;

	logic [2:0] type;

	logic [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9;
	logic [31:0] x10, x11, x12, x13, x14, x15, x16, x17, x18, x19;
	logic [31:0] x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31;

	logic [31:0] f0, f1, f2, f3, f4, f5, f6, f7, f8, f9;
	logic [31:0] f10, f11, f12, f13, f14, f15, f16, f17, f18, f19;
	logic [31:0] f20, f21, f22, f23, f24, f25, f26, f27, f28, f29, f30, f31;
		

	always_ff @(posedge clk or posedge rst) begin

		if (rst) begin			// Resetting all output regs
			
			pc    <= 12'd0;
			
			type  <= UWN;			
			drw   <= 1'd0;
			fault <= 1'd0;
			zf    <= 1'd0;
			cf    <= 1'd0;
			sf    <= 1'd0;			

		end
	end


	assign opcode[6:0] = ins[6:0];
	assign zf = (rd == 32'd0);
	assign sf = rd[31];

	assign type = UWN;
	assign fault = 1'd0;
	assign rs1 = 5'd0;
	assign rs2 = 5'd0;
	assign rd = 5'd0;
	assign imm = 21'd0;
	assign funct3 = 3'd0;
	assign funct7 = 7'd0;

	assign cf = 1'd0;


	always_comb begin

//		type = UWN;
//		fault = 1'd0;
//		rs1 = 5'd0;
//		rs2 = 5'd0;
//		rd = 5'd0;
//		imm = 21'd0;
//		funct3 = 3'd0;
//		funct7 = 7'd0;

//		cf = 1'd0;

		case (opcode)								// Defining instruction type (ID) 
			7'b0110011: type = R;

			7'b0010011: type = I1;
			7'b0000011: type = I2;
			7'b1110011: type = I3;
			7'b1100111: type = I4;			

			7'b0100011: type = S;

			7'b0110111: type = U1;
			7'b0010111: type = U2;

			7'b1100011: type = B;
	
			7'b1101111: type = J;

			default:    type = UWN;
		endcase 



		case (type)								// Decoding instructions depending on their types (ID)
			R: begin
				rd[4:0]     = ins[11:7];
				rs1[4:0]    = ins[19:15];
				rs2[4:0]    = ins[24:20];
				funct3[2:0] = ins[14:12];
				funct7[6:0] = ins[31:25];
			end

			I1, I2, I3, I4: begin
				rd[4:0]     = ins[19:15];
				imm[11:0]   = ins[31:20];
				funct3[2:0] = ins[14:12];
			end

			S: begin
				imm[4:0]    = ins[11:7];
				imm[11:5]   = ins[31:25];
				rs1[4:0]    = ins[19:15];
				rs2[4:0]    = ins[24:20];
				funct3[2:0] = ins[14:12];
			end

			U1, U2: begin
				rd[4:0]   = ins[11:7];
				imm[19:0] = ins[31:12];
			end

			B: begin
				rs1[4:0]    = ins[19:15];
				rs2[4:0]    = ins[24:20];
				imm[11:0]   = {ins[31], ins[7], ins[30:25], ins[11:8]};
				funct3[2:0] = ins[14:12];
			end

			J: begin
				rd[4:0]   = ins[11:7];
				imm[20:0] = {ins[31], ins[19:12], ins[20], ins[30:21], 1'b0};
			end

			default: begin
				fault = 1'd1;
				rs1 = 5'd0;
				rs2 = 5'd0;
				rd = 5'd0;
				imm = 21'd0;
				funct3 = 3'd0;
				funct7 = 7'd0;
			end
		endcase

//		zf = (rd == 32'd0);
//		sf = rd[31];

		if (type == R) begin							// Executing instructions in ALU (EX)
			case (funct3)

				3'h0: begin
					if (funct7 == 7'h00) begin
						{cf, rd} = rs1 + rs2;				//add (unsigned)

					end else if (funct7 == 7'h20) begin
						{cf, rd} = rs1 - rs2;				//sub (unsigned)

					end else begin
						fault = 1'd1;					//fault
					end
				end

				3'h4: begin							//xor
					rd = rs1 ^ rs2;
				end

				3'h6: begin							//or
					rd = rs1 | rs2;
				end

				3'h7: begin							//and
					rd = rs1 & rs2;
				end

				3'h1: begin							//sll
					rd = rs1 << rs2;
				end

				3'h5: begin
					if (funct7 == 7'h0) begin
						rd = rs1 >> rs2;				//srl

					end else if (funct7 == 7'h20) begin
						rd = $signed(rs1) >>> $signed(rs2);		//sra

					end else fault = 1'd1;		//fault
				end

				3'h2: rd = ($signed(rs1) < $signed(rs2)) ? 1 : 0;		//slt
				3'h3: rd = (rs1 < rs2) ? 1 : 0;					//sltu
				
				default: fault = 1'd1;
			
			endcase



		end else if (type == I1) begin
			case (funct3)

//				3'h0: //addi
//				3'h4: //xori
//				3'h6: //ori
//				3'h7: //andi

				3'h1: if (imm[11:5] == 7'h0) begin
						//slli
					end else begin
						// fault
					end

				3'h5: if (imm[11:5] == 7'h0) begin
						//srli
					end else if (imm[11:5] == 7'h20) begin
						//srai
					end else begin
						//fault
					end

//				3'h2: //slti
//				3'h3: //sltiu	

				default: fault = 1'd1;
			
			endcase



		end else if (type == I2) begin
			case (funct3)

//				3'h0: //lb
//				3'h1: //lh
//				3'h2: //lw
//				3'h4: //lbu
//				3'h5: //lhu

//				default: //fault
			endcase



		end else if (type == S) begin
			case (funct3)

//				3'h0: //sb
//				3'h1: //sh
//				3'h2: //sw

//				default: //fault

			endcase



		end else if (type == B) begin
			case (funct3)

//				3'h0: //beq
//				3'h1: //bne
//				3'h4: //blt
//				3'h5: //bge
//				3'h6: //bltu
//				3'h7: //bgeu

//				default: //fault
			endcase

		end else if (type == J) begin
			//jal

		end else if (type == I3) begin
			//jalr
		
		end else if (type == U1) begin
			//lui

		end else if (type == U2) begin
			//auipc

		end else if (type == I4) begin
			case (imm)

//				32'h0: //ecall
//				32'h1: //ebreak

//				default: //fault
			endcase
		
		end else begin
			//fault
		end 

	end



endmodule

