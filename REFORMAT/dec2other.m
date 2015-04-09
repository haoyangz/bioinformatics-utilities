function [out] = dec2other(in,ksize,num)
out = zeros(1,ksize);
dominator = num^(ksize-1);
decnum = in;
for j = ksize:-1:1
	module = mod(decnum,dominator);
	out(j) = (decnum-module)/dominator;
	decnum = module;
	dominator = dominator / num;
end
