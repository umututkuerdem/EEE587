function [U, S, V, elapsedtime] = Exactsvd(A)
tic;
[U,S,V] = svd(A);
elapsedtime = toc;
end