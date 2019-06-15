module rvfi_wrapper (
	input         clock,
	input         reset,
	`RVFI_OUTPUTS
);
	(* keep *) wire trap;

	(* keep *) `rvformal_rand_reg mem_ready;
	(* keep *) `rvformal_rand_reg [31:0] mem_rdata;

	(* keep *) wire        mem_valid;
	(* keep *) wire        mem_instr;
	(* keep *) wire [31:0] mem_addr;
	(* keep *) wire [31:0] mem_wdata;
	(* keep *) wire [3:0]  mem_wstrb;

	VeldFV uut (
		.clock       (clock),
		.reset       (reset),
		.trap        (trap ),

		.mem_valid (mem_valid),
		.mem_instr (mem_instr),
		.mem_ready (mem_ready),
		.mem_addr  (mem_addr ),
		.mem_wdata (mem_wdata),
		.mem_wstrb (mem_wstrb),
		.mem_rdata (mem_rdata),

		`RVFI_CONN
	);

`ifdef VELDT_FAIRNESS
	reg [2:0] mem_wait = 0;
	always @(posedge clock) begin
		mem_wait <= {mem_wait, mem_valid && !mem_ready};
		restrict(~mem_wait || trap);
	end
`endif

`ifdef PICORV32_CSR_RESTRICT
	always @* begin
		if (rvfi_valid && rvfi_insn[6:0] == 7'b1110011) begin
			if (rvfi_insn[14:12] == 3'b010) begin
				restrict (rvfi_insn[31:20] == 12'hC00 || rvfi_insn[31:20] == 12'hC01 || rvfi_insn[31:20] == 12'hC02 ||
						rvfi_insn[31:20] == 12'hC80 || rvfi_insn[31:20] == 12'hC81 || rvfi_insn[31:20] == 12'hC82);
				restrict (rvfi_insn[19:15] == 0);
			end
			restrict (rvfi_insn[14:12] != 3'b001);
			restrict (rvfi_insn[14:12] != 3'b011);
			restrict (rvfi_insn[14:12] != 3'b101);
			restrict (rvfi_insn[14:12] != 3'b110);
			restrict (rvfi_insn[14:12] != 3'b111);
		end
	end
`endif
endmodule
