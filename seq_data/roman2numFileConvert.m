function [filenum] = roman2numFileConvert(tdir,prefix,suffix,chrmax)

list = dir(tdir);
for i = 1:length(list)
	file = list(i);
	if (file.isdir==1)
		continue;
	end
	name = file.name;
	split1 = regexp(name,prefix,'split');
	if length(split1)==1
		continue;
	end

	split2 = regexp(split1{2},suffix,'split');
	if length(split2)==1
		continue;
	end
	roman = split2{1};
	number = roman2num(roman);
	if (isnan(number))
		continue;
	end
	
	if (number >chrmax)
		continue;
	end
	new_name = horzcat(prefix,num2str(number),suffix);
	cmd = horzcat('mv ',horzcat(tdir,name),' ' ,horzcat(tdir,new_name));
	system(cmd);
end
