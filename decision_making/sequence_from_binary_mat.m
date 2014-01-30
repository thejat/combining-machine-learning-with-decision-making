function seq = sequence_from_binary_mat(mat)

seq = zeros(size(mat,1)+1,1);
seq(1) = 1;
for i=1:size(mat,1)
    seq(i+1) = find(mat(seq(i),:)==1);
end

seq = seq(2:end)';