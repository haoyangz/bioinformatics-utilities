function[] = parseSNP(snpdir,snpfile)

snp = fopen(horzcat(snpdir,snpfile),'r');

oneLine = fgets(snp);
chr='-1';
out = -1;
while ischar(oneLine)
    if (oneLine(1)~='#')
        myVector = regexp(oneLine, '\t','split');
        if (~strcmp(chr,myVector{1}))
            chr = myVector{1};
            if (out>=0)
                fclose(out);
            end
            outfile = horzcat([snpdir,'/chr',chr,'.vcf']);
            out = fopen(outfile,'w');
        end
        fprintf(out,oneLine);
    end
    
    oneLine = fgets(snp);
end

fclose(out);
fclose(snp);
