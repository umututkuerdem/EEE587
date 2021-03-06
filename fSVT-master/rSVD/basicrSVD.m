function [U, S, V, elapsedtime] = basicrSVD(A, k, p, s)
tic;
% the randQB method in [Halko et al., 2011] paper 
[m, n] = size(A);
B = randn(n, k+s);
[Q, ~] = qr(A*B, 0);
for j = 1:p
    [Q, ~] = qr((A'*Q), 0);
    [Q, ~] = qr((A*Q), 0);
end
B = Q'*A;
[U, S, V] = svd(B, 'econ');
U = Q*U;
U = U(:, 1:k);
S = S(1:k, 1:k);
V = V(:, 1:k);
elapsedtime = toc;
end