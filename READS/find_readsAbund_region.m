function [] = find_readsAbund_region(readsfile,threshold,winsize,maxchr,sizedir,outputfile)
display('Reading Reads');
fin = fopen(readsfile,'r');
reads = fread(fin,'single');
fclose(fin);

sizemat = zeros(1,maxchr);
for i = 1:maxchr
	sizefile = horzcat(sizedir,'/chr',num2str(i),'.size.txt');
	sizemat(i) = dlmread(sizefile);
end

display('Parsing reads');
cnt = 0;
reads_cnt = cell(maxchr,1);
for i = 1:maxchr
	thissize = sizemat(i);
	reads_part= reshape(reads( (cnt+1):(cnt+thissize-mod(thissize,winsize))),winsize,floor(thissize/winsize));
	reads_cnt{i} = ones(1,winsize) * reads_part;
	cnt = cnt + thissize;
end

display('Finding Cutoff');
all_reads_cnt = cat(2,reads_cnt{1:maxchr});
all_reads_cnt_sort = sort(all_reads_cnt,'descend');
cutoff = all_reads_cnt_sort(floor(length(all_reads_cnt_sort)*threshold));

display('Outputing region');
fout = fopen(outputfile,'w');
for i= 1:maxchr
	pick = find(reads_cnt{i}>=cutoff);
	for j = 1:length(pick)
		fprintf(fout,'chr%d\t%d\t%d\n',i,(pick(j)-1)*winsize,pick(j)*winsize);
	end
end
fclose(fout);
