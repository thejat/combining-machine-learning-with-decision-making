%creates the ampl_combined.dat file.
%INPUTS
%trainingdata
%unLabeled
%numTrain
%numFeatures
%numUnlabeled
%C0
%C1
%C2
%i

filename = 'ampl_combined.dat';
fid = fopen(filename, 'w'); 
fprintf(fid, '#dat file generated through matlab script\n#ampl_combined.dat\n');
fprintf(fid, 'param C0 := %4.4f;\n',C0);
fprintf(fid, 'param C1 := %4.4f;\n',C1);
fprintf(fid, 'param C2 := %4.4f;\n',C2);
fprintf(fid, 'param numTrain := %d;\n',numTrain);
fprintf(fid, 'param dimLambda := %d;\n',numFeatures+1);
fprintf(fid, 'param numUnlabeled := %d;\n',numUnlabeled);
fprintf(fid, strcat(['param d : ' int2str(1:numUnlabeled) ' :=\n']));
for i=1:numUnlabeled-1
    fprintf(fid,strcat([num2str(i) ' ' num2str(C(i,:)) '\n']));
end
fprintf(fid, '%d %s;\n',numUnlabeled,num2str(C(end,:)));
fclose(fid);

%processing training and test data
trainingdata2write = [[1:numTrain]' ones(numTrain,1) trainingdata(:,1:numFeatures)];
traininglabels2write = [[1:numTrain]' trainingdata(:,end)];
unLabeleddata2write = [[1:numUnlabeled]' ones(numUnlabeled,1) unLabeled(:,1:numFeatures)];

%appending data to ampl dat file
fid = fopen(filename, 'a'); fprintf(fid, 'param: ytrain :=\n'); fclose(fid);
dlmwrite(filename ,traininglabels2write(1:numTrain-1,:), '-append','delimiter',' ');
fid = fopen(filename, 'a'); fprintf(fid, '%s;\nparam xtrain: %s :=\n',num2str(traininglabels2write(numTrain,:)),num2str(1:numFeatures+1)); fclose(fid);
dlmwrite(filename ,trainingdata2write(1:numTrain-1,:), '-append','delimiter',' ');
fid = fopen(filename, 'a'); fprintf(fid, '%s;\nparam xUnlabeled: %s :=\n',num2str(trainingdata2write(numTrain,:)),num2str(1:numFeatures+1)); fclose(fid);
dlmwrite(filename ,unLabeleddata2write(1:numUnlabeled-1,:), '-append','delimiter',' ');
fid = fopen(filename, 'a'); fprintf(fid, '%s;\n#append ends here---------------------------------------\n',num2str(unLabeleddata2write(numUnlabeled,:))); fclose(fid);



