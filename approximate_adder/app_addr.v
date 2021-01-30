

module adder (a0,a1,a2,a3,b0,b1,b2,b3,out);
input a0,a1,a2,a3,b0,b1,b2,b3;
output out;
wire x1,x2,x3,fs2,fs7,fs3,fs8,fs5,fs10,fs12,fs6,fs11,sx1,sx2,sx3,s0,s1,s2,s3,fs0,fs1,fs4,fs9,ss0,ss1,ss2,ss3;

// exact adder ckt
assign s0 = a0 ^ b0;
assign x1 = a0 & a1;
assign s1 = a1 ^ b1 ^ x1;
assign x2 = x1 & (a1 ^ b1) | (a1 & b1);
assign s2 = a2 ^ b2 ^ x2;
assign x3 = x2 & (a2 ^ b2) | (a2 & b2);
assign s3 = a3 ^ b3 ^ x3;


// approximate FPU
assign fs0 = a0 ^ b0;
assign fs1 = a1 ^ b1;
assign fs2 = a1 & b1;

assign fs3 = a2 ^ b2;
assign fs4 = fs2 ^ fs3;
assign fs5 = a2 & b2;
assign fs6 = fs2 & fs3;
assign fs7 = fs5 | fs6;

assign fs8 = a3 ^ b3;
assign fs9 = fs7 ^ fs8;
assign fs10 = a3 & b3;
assign fs11 = fs7 & fs8;
assign fs12 = fs10 | fs11;


//subtractor 
assign ss0 = ~(s0 ^ ~fs0) ;
assign sx1 = s0 | ~fs0;
assign ss1 = s1 ^ ~fs1 ^ sx1;
assign sx2 = sx1 & (s1 ^ ~fs1) | (s1 & ~fs1);
assign ss2 = s2 ^ ~fs4 ^ sx2;
assign sx3 = sx2 & (s2 ^ ~fs4) | (s2 & ~fs4);
assign ss3 = s3 ^ ~fs9 ^ sx3; 

//comparator
assign out = ss3 | ~ss3 & ss2 | ~ss3 & ~ss2 & ss1 & ~ss0 ;
 
endmodule
