module W_GRF (
    input clk,
    input reset,
    input writeEnable,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] writeData,
    input [31:0] currentPC,

    output [31:0] RD1,
    output [31:0] RD2  
);

reg [31:0] w_grf[31:0];

integer i;
initial begin
    for (i=0;i<=31;i=i+1) begin
        w_grf[i]<=0;
    end
end

always @(posedge clk ) begin
    if (reset) begin
        for (i=0;i<=31;i=i+1) begin
            w_grf[i]<=0;
        end
    end
    else begin
        if (writeEnable && A3!=0) begin
            w_grf[A3] <= writeData;
            //$display("@%h: $%d <= %h", currentPC, A3, writeData);
        end
        else begin
            w_grf[0]<=0;
        end
    end
end

assign RD1 = w_grf[A1];
assign RD2 = w_grf[A2];

endmodule //W_GRF