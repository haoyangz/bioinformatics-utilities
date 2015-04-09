clear;close all;clc;

snpfile= '/mnt/work/zeng/kmer/chr10.vcf'
%snpfile= '/Users/haoyangz/Documents/haoyangz/study/graduate/2013Fall/David/kmer/snp.vcf';
snp = fopen(snpfile);

oneLine = fgets(snp);
cnt = 0;
linecnt = 0;
while ischar(oneLine)
    if (oneLine(1)~='#')
        linecnt = linecnt + 1;
        myVector = regexp(oneLine, '\t','split');
        if (strcmp('PASS',myVector{7}))
            cnt = cnt + 1;
        end
    end
    
    oneLine = fgets(snp);
end
cnt
linecnt
cnt/linecnt

fclose(snp);