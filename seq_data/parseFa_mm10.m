clear;close all;clc;

fafile= '/mnt/work/zeng/kmer/mm10.fa';
%fafile= '/Users/haoyangz/Documents/haoyangz/study/graduate/2013Fall/David/kmer/mm10.fa';
fa = fopen(fafile);

oneLine = fgets(fa);
cnt = 0;
while ischar(oneLine)
    if (oneLine(1)=='>')
        cnt = cnt+1;
        if (cnt~=1)
            fclose(out);
        end
        outfile = horzcat(['/mnt/work/zeng/kmer/',oneLine(2:(length(oneLine)-1)),'.fa']);
        %ooutfile = horzcat(['/Users/haoyangz/Documents/haoyangz/study/graduate/2013Fall/David/kmer/chr',num2str(cnt),'.fa']);
        out = fopen(outfile,'wt');
    end
    fprintf(out,oneLine);
    oneLine = fgets(fa);
end

fclose(out);
fclose(fa);