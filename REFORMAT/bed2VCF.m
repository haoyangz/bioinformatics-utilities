bedfile = '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/grant/region.bed';
genomefile = '/cluster/projects/wordfinder/data/genome/hg19.in';
outdir = '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/grant/VCF/';
sizefile = '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/seq_data/all.size.txt';

if (exist(outdir)==0)
	mkdir(outdir);
end
chrsize = dlmread(sizefile);

genomeread = fopen(genomefile,'r');

mapper = {'A','T','G','C'};
bed = fopen(bedfile,'r');
line = fgetl(bed);
last_chr = '';
last_chr_num = -1;
while(ischar(line))
	display(line)
	split = regexp(line,'\t','split');
	chr = split{1};
	if (~strcmp(chr,last_chr))
		splitchr = regexp(chr,'chr','split');
		chr_num = str2double(splitchr{2});
		offset = chrsize(chr_num);
		gsize = chrsize(chr_num+1) - offset;
		fseek(genomeread,offset,-1);
		genome =fread(genomeread,gsize);
		if (~isempty(last_chr))
			fclose(out);
		end
		outfile = horzcat(outdir,'/',chr,'.vcf');
		out = fopen(outfile,'w');
		last_chr = chr;
		last_chr_num = str2num(splitchr{2});
	end

	range = (str2num(split{2})+1) : str2num(split{3});
	for (k = 1:length(range))
		pos = range(k);
		ref = mapper{genome(pos)+1};
		for (nuc = 1:3)
			alt = mapper{mod((genome(pos)+nuc), 4)+1};
			line = strjoin({num2str(last_chr_num),num2str(pos),strjoin({num2str(last_chr_num),num2str(pos),ref,alt},'-'),ref,alt,'100','PASS','AC=1;AF=0.5;VT=SNP'},'\t');
			line = horzcat(line,'\n');
			fprintf(out,line);	
		end
	end
	line = fgetl(bed);
end
fclose(bed);
fclose(genomeread);
