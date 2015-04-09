order = [1,2,3];
gfile = '';
bed = 0;
bedfile = ...
{'/cluster/zeng/research/kmer/KMM/GM12878.H3K4me3/wgEncodeUwHistoneGm12878H3k4me3StdAlnRep1.bam',...
'/cluster/zeng/research/kmer/KMM/GM12878.H3K4me3/wgEncodeUwHistoneGm12878H3k4me3StdAlnRep2.bam'};


for i = 1:length(bedfile)
	fout = fopen(horzcat('matlab_cmd_',num2str(i)),'w');
	cmd = horzcat('try,bed2bam(''',bedfile{i},''',''',gfile,''',',num2str(bed),',[');
	for j = 1:length(order)
		cmd = horzcat(cmd,num2str(order(j)));
		if (j~=length(order))
			cmd = horzcat(cmd,',');
		end
	end
	cmd = horzcat(cmd,']),catch e,display(e.getReport()),end,quit');
	fprintf(fout,'%s\n',cmd);
	fclose(fout);
	cmd = horzcat('matlab -nosplash -nodesktop < matlab_cmd_',num2str(i),' &');
	system(cmd);
end
