`define DM_size 8192
`define word 0
`define half_word 1
`define byte 2   

module DM (
	input clk,
	input reset,
	input write_enable,
	input read_enable,
	input [1:0] dataType,
	input [31:0] address,
	input [31:0] write_data,
	input [31:0] currentPC,

	output [31:0] out_data,
	output [31:0] out_alter
);

reg [31:0] dm[0:`DM_size-1];
wire [12:0] word_addr = address[14:2];
wire [1:0] byte_sel = address[1:0];
wire half_sel = address[1];
wire [31:0] curReadFull = dm[word_addr];
assign out_data = 
(dataType == `byte) ? {{24'b0},{curReadFull[byte_sel*8+:8]}}:
(dataType == `half_word) ? {{16'b0},{curReadFull[half_sel*16+:16]}}:
curReadFull;

integer i;
initial begin
	for (i = 0; i<`DM_size; i=i+1) begin
		dm[i]<=0;
	end
end

always @(posedge clk ) begin
	if (reset) begin
		for (i = 0; i<`DM_size; i=i+1) begin
			dm[i]<=0;
		end
	end
	else begin
		if (write_enable) begin
			case (dataType)
				 `word:begin
					  dm[word_addr]<=write_data;
				 end
				 `half_word:begin
						if (half_sel == 0) begin
							dm[word_addr][15:0]  <= write_data[15:0];
						end
						else begin 
							dm[word_addr][31:16] <= write_data[15:0];
						end
				 end
				 `byte:begin
						case (byte_sel)
							0:begin
								dm[word_addr][7:0]  <= write_data[7:0];
							end
							1:begin
								dm[word_addr][15:8]  <= write_data[7:0];
							end
							2:begin
								dm[word_addr][23:16]  <= write_data[7:0];
							end
							3:begin
								dm[word_addr][31:24]  <= write_data[7:0];
							end
						endcase
				 end
			endcase 
			$display("@%h: *%h <= %h", currentPC, address, write_data);
		end
	end
end

endmodule //dm