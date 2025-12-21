module D_extend (
	input [15:0] immediate,
	input extOp,

	output [31:0] result
);

assign result = 
(extOp == 1) ? {{16{immediate[15]}},{immediate}} : 
{{16'b0},{immediate}};

endmodule //D_extend