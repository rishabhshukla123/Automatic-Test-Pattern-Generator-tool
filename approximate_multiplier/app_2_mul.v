//multiplier ckt
// approximate circuit
module approximate(a0,a1,b0,b1,out);
input a0,a1,b0,b1;
output out;
wire fs0,fs1,fs2,fs3,fs4,out0,out1,out2,out3,x1,x2,x3,x4,s0,s1,s2,s3,c1,c2,c3;

and and0 (fs0,b0,a0);

and and1 (fs3,b1,a0);

and and2 (fs4,b0,a1);

and and3 (fs2,b1,a1);

or or0 (fs1,fs4,fs3);

// non approximate circuit

and and4 (out0,a0,b0);
and and5 (x1,b1,a0);
and and6 (x2,b0,a1);
and and7 (x3,a1,b1);
and and8 (x4,x2,x1);
and and9 (out3,x3,x4);

xor xor10 (out1,x2,x1);
xor xor11 (out2,x3,x4);

//subtractor

assign s0 = (fs0 ^ out0);
assign c1 = (out0 | ~fs0) ;
assign s1 = (out1 ^ ~fs1 ^ c1);
assign c2 = (c1) & ~(out1 ^ fs1) | (out1 & ~fs1);
assign s2 = (out2 ^ ~fs2 ^ c2);
assign c3 = (c2) & ~(out2 ^ fs2) | (out2 & ~fs2);
assign s3 = (out3 ^ c3);


// comparator

assign out = s3 | (~s3 & s2) | (~s3) & (~s2) & (s1);

endmodule
