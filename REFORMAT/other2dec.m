function [out] = other2dec(in,ksize,num,mi)
if (isempty(mi))
	out = 0;
	mul = 1;
	for i = 1:ksize
		out = out + mul*in(i);
		mul = mul*num;
	end
else
	out = mi * in;
end
