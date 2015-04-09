function [] = bed2bam(bed_file,gfile,bed,order)

split = regexp(bed_file,'/','split');
prefix = regexp(bed_file,split{length(split)},'split');
diary(horzcat([prefix{1},'/log.',split{length(split)}]));

if (bed)
	r_file = regexp(bed_file,'.bed','split');
else
	r_file = regexp(bed_file,'.bam','split');
end

r_file = r_file{1};

bam_file = horzcat(r_file,'.bam');
sort_bam_file_prefix = horzcat(r_file,'.sorted');
sort_bam_file = horzcat(r_file,'.sorted.bam');

if (bed)
	cmd = horzcat('bedtools bedtobam -i ',bed_file,' -g ',gfile,' > ',bam_file);
	system(cmd);
end

if (~isempty(find(order==1)))
cmd = horzcat('samtools sort ',bam_file,' ',sort_bam_file_prefix);
system(cmd);
end


if (~isempty(find(order==1)))
cmd = horzcat('samtools view -F 788 -q 0 ',sort_bam_file,' | wc');
system(cmd);
end


if (~isempty(find(order==3)))
cmd = horzcat('samtools index ',sort_bam_file);
system(cmd);
end
