function [] = vcf2fasta(vcfdir,genomefile,sizedir,out_fafile,out_pairfile,flank_len)
keys = {0,1,2,3,4};
values = {'A','T','G','C','N'};
dic = containers.Map(keys, values);

fin = fopen(genomefile,'r');
genome = fread(fin);
fclose(fin);

sizes = dlmread(horzcat(sizedir,'/all.size.txt'));
vcffiles = dir(vcfdir);
out_fa = fopen(out_fafile,'w');
out_pair = fopen(out_pairfile,'w');

for i = 1:length(vcffiles)
    filename = vcffiles(i).name;
    display(filename);
    if (isempty(strfind(filename,'.vcf')))
        continue;
    end

    split = regexp(filename,'chr','split');
    split1 = regexp(split{2},'[.]','split');
    offset = sizes(str2num(split1{1}));

    in = fopen(horzcat(vcfdir,'/',filename),'r');
    line = fgetl(in);
    while(ischar(line))
        split = regexp(line,'\t','split');
        chr = split{1};
        ref = split{4};
        alt = split{5};
        pos = str2num(split{2});
        s = offset + pos - flank_len;
        e = offset + pos + flank_len;

        seq = genome(s:e);

        seq_name_1 = horzcat('ref:chr',chr,'-',num2str(pos));
        seq_name_2 = horzcat('alt:chr',chr,'-',num2str(pos));

        fprintf(out_pair,'%s\t%s\n',seq_name_1,seq_name_2);
        fprintf(out_fa,'>%s\n',seq_name_1);
        for i = 1:(e-s+1)
            fprintf(out_fa,dic(seq(i)));
            if (i==(1+flank_len))
                if (dic(seq(i)) ~= ref)
                    error(horzcat('Ref doesn''t match at ',chr,':',num2str(pos)));
                end
            end
        end
        fprintf(out_fa,'\n');
    
        fprintf(out_fa,'>%s\n',seq_name_2);
        for i = 1:(e-s+1)
            if (i==(1+flank_len))
                fprintf(out_fa,alt);
            else
                fprintf(out_fa,dic(seq(i)));
            end
        end
        fprintf(out_fa,'\n');
    
        line = fgetl(in);

    end
    fclose(in);
end


fclose(out_fa);
fclose(out_pair);
