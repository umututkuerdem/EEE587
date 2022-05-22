function [U, S, V, elapsedtime] = pcafast(A, k, p, s)
% The method in [Li et al., 2017] paper
tic;
[m, n] = size(A);
B = randn(n, k+s);
if p == 0
    [Q, ~] = qr(A*B, 0);
else
    [Q, ~] = lu(A*B);
end
for j = 1:p
    [Q, ~] = lu((A'*Q));
    if j == p
        [Q, ~] = qr((A*Q), 0);
    else
        [Q, ~] = lu(A*Q);
    end
end
B = Q'*A;
[U, S, V] = svd(B, 'econ');
U = Q*U;
U = U(:, 1:k);
S = S(1:k, 1:k);
V = V(:, 1:k);
elapsedtime = toc;
end