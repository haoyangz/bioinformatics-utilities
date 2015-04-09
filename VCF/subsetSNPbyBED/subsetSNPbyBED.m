function [] = subsetSNPbyBED(snpdir,bedfile,flank,maf,vt,outdir)
if (exist(outdir)==0)
	system(horzcat('mkdir ',outdir));
end
[chr,spos,epos,~,~,~] = textread(bedfile,'%s %s %s %s %s %s');

uni_chr = unique(chr);
for chridx=1:length(uni_chr)
	thischr = uni_chr{chridx};
	display(horzcat('subseting ',thischr));
	snpfile = horzcat(snpdir,'/',thischr,'.vcf');
	if (exist(snpfile)==0)
		continue;
	end
	outfile = horzcat(outdir,'/',thischr,'.vcf');
	
	pick = find(ismember(chr,thischr));
                                                                              
    tempfile = horzcat(thischr,'.temp');
    out = fopen(tempfile,'w');
	for i = 1:length(pick)
		fprintf(out,'%s\t%s\t%s\n',chr{pick(i)},spos{pick(i)},epos{pick(i)});
	end
	fclose(out);
	
	if (exist(outfile)~=0)
		system(horzcat('rm ',outfile));
	end
	cmd = horzcat('python subsetSNPbyBED.py ',snpfile,' ', tempfile,' ',num2str(flank),' ',num2str(maf),' ',vt,' >> ',outfile);
	system(cmd);
	system(horzcat('rm ',tempfile));
end
