`timescale 1ns/1ps
module aes_sbox_tb;
  reg [7:0] d;
  wire [7:0] q;

  aes_sbox u_dut (.d(d), .q(q));

  initial begin
    d = 8'h00; #10; if (q !== 8'h63) $error("S(0)=0x63");
    d = 8'h53; #10; if (q !== 8'hED) $error("S(0x53)=0xED");
    d = 8'hFF; #10; if (q !== 8'h16) $error("S(0xFF)=0x16");
    $display("aes_sbox_tb PASS");
    $finish;
  end
endmodule
