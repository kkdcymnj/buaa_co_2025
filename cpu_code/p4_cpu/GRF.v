module GRF (
	input clk,
	input reset,
	input write_enable,
	input [4:0] A1,
	input [4:0] A2,
	input [4:0] A3,
	input [31:0] write_data,
	input [31:0] currentPC,

	output [31:0] RD1,
	output [31:0] RD2  
);

reg [31:0] grf[31:0];

integer i;
initial begin
	for (i=0;i<=31;i=i+1) begin
		grf[i]<=0;
	end
end

always @(posedge clk ) begin
	if (reset) begin
		for (i=0;i<=31;i=i+1) begin
			grf[i]<=0;
		end
	end
	else begin
		if (write_enable && A3!=0) begin
			grf[A3] <= write_data;
			$display("@%h: $%d <= %h", currentPC, A3, write_data);
		end
		else begin
			grf[0]<=0;
		end
	end
end

assign RD1 = grf[A1];
assign RD2 = grf[A2];

endmodule //grf