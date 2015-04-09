function [] = qtlBED2ID(qtlfile,snpdir,outfile)
if (exist(outfile)~=0)
system(horzcat('rm ',outfile));
end
[chr,spos,epos,~,~,~] = textread(qtlfile,'%s %s %s %s %s %s');
uni_chr = unique(chr);
uni_chr_num = zeros(1,length(uni_chr));
for chridx = 1:length(uni_chr)
    split = regexp(uni_chr{chridx},'chr','split');
    uni_chr_num(chridx) = str2num(split{2});
end
[~,rank] = sort(uni_chr_num);
uni_chr = uni_chr(rank);

for chridx=1:length(uni_chr)
	thischr = uni_chr{chridx};
	display(horzcat('converting ',thischr));
	pick = find(ismember(chr,thischr));

	tempfile = horzcat(thischr,'.temp');
	out = fopen(tempfile,'w');
	for i = 1:length(pick)
		fprintf(out,'%s\t%s\t%s\n',chr{pick(i)},spos{pick(i)},epos{pick(i)});
	end

	vcffile = horzcat(snpdir,'/',thischr,'.vcf');
	
	cmd = horzcat('python SNPbed2ID.py ',vcffile,' ',tempfile,' >> ',outfile);
	system(cmd);
	system(horzcat('rm ',tempfile));
end
