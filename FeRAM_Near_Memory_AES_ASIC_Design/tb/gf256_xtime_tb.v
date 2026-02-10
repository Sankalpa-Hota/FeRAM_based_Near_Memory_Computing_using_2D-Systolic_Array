`timescale 1ns/1ps
module gf256_xtime_tb;
  reg [7:0] a;
  wire [7:0] y;

  gf256_xtime u_dut (.a(a), .y(y));

  initial begin
    a = 8'h00; #10; if (y !== 8'h00) $error("xtime(0)");
    a = 8'h01; #10; if (y !== 8'h02) $error("xtime(1)");
    a = 8'h80; #10; if (y !== (8'h00 ^ 8'h1B)) $error("xtime(0x80)");
    a = 8'h53; #10; if (y !== 8'hA6) $error("xtime(0x53)");  // AES MixColumns ref
    $display("gf256_xtime_tb PASS");
    $finish;
  end
endmodule
