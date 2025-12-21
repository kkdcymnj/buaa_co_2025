`include "constant.v"

module M_dataMem (
	input clk,
	input reset,
	input writeEnable,
	input [31:0] address,
	input [31:0] writeData,
	input [31:0] currentPC,
	input [1:0] dataType,
	input isSigned,

	//‘§¡Ù–≈∫≈
	input new,
	input [31:0] rsVal,

	input [4:0] rs,
	input [4:0] rt,

	output [31:0] readData,
	//‘§¡Ù–≈∫≈
	output [4:0] RegWriteAddrSpecial
);

reg [31:0] dm[0:`dm_size-1];

wire [12:0] word_addr = address[14:2];
wire [1:0] byte_sel = address[1:0];
wire half_sel = address[1];
wire [31:0] curReadFull = dm[word_addr];

wire [7:0] byte_content = curReadFull[byte_sel*8 +: 8];
wire [15:0] half_content = curReadFull[half_sel*16 +: 16];
wire [31:0] readData_normal = 
(dataType == `dm_BYTE) ? {{24'b0},{byte_content}}:
(dataType == `dm_half) ? {{16'b0},{half_content}}:
curReadFull;

wire isGreaterThanZero = (byte_content[7]==0);
wire [31:0] readData_special = {{24{byte_content[7]}},{byte_content}};

assign RegWriteAddrSpecial = 
(new && isGreaterThanZero) ? rt : rs;

assign readData = 
(new) ? readData_special : readData_normal;

integer i;
initial begin
	for (i = 0; i<`dm_size; i=i+1) begin
		dm[i]<=0;
	end
end


always @(posedge clk ) begin
	if (reset) begin
		for (i = 0; i<`dm_size; i=i+1) begin
			dm[i]<=0;
		end
	end
	else begin
	if (writeEnable) begin
		case (dataType)
			`dm_word:begin
				dm[word_addr]<=writeData;
			end
			`dm_half:begin
				if (half_sel == 0) begin
					dm[word_addr][15:0]  <= writeData[15:0];
				end
				else begin 
					dm[word_addr][31:16] <= writeData[15:0];
				end
			end
			`dm_BYTE:begin
				case (byte_sel)
					0:begin
						dm[word_addr][7:0]  <= writeData[7:0];
					end
					1:begin
						dm[word_addr][15:8]  <= writeData[7:0];
					end
					2:begin
						dm[word_addr][23:16]  <= writeData[7:0];
					end
					3:begin
						dm[word_addr][31:24]  <= writeData[7:0];
					end
				endcase
			end
		endcase 
		$display("%d@%h: *%h <= %h", $time, currentPC, address, writeData);
	end
	end
end

endmodule //M_dataMem