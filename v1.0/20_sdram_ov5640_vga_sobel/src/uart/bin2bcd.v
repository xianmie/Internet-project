module bin2bcd_13 (
    input wire clk, nrst,
    input wire start,
    input wire [12:0] bin,
    output reg [15:0] bcd,
    output reg valid
    );
    
    reg [12:0] bin_in;
    reg op;
    reg [3:0] cnt;

    always @(posedge clk or negedge nrst) begin
    if(nrst == 0)
            bin_in <= 0;
    else if(start)
        bin_in <= bin;
    end
    
    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            op <= 0;
        else if(start)
            op <= 1;
        else if(cnt == 13 - 1)
            op <= 0;
    end

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt <= 0;
        else if(op)
            cnt <= cnt + 1'b1;
        else
            cnt <= 0;
    end

    function [3:0] fout(input reg [3:0] fin);
        fout = (fin > 4) ? fin + 4'd3 : fin;
    endfunction

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            bcd <= 0;
        else if(op) begin
            bcd[0] <= bin_in[12-cnt];
            bcd[4:1] <= fout(bcd[3:0]);
            bcd[8:5] <= fout(bcd[7:4]);
            bcd[12:9] <= fout(bcd[11:8]);
				bcd[15:13] <= fout(bcd[15:12]);
          end
        else
            bcd <= 0;
    end

    always @(posedge clk or negedge nrst) begin
    if(nrst == 0)
        valid <= 0;
    else if(cnt == 13 - 1)
        valid <= 1;
    else
        valid <= 0;    
    end
endmodule