function [U, S, V, elapsedtime] = rSVDPI(A, k, i, s)
% This is fast randQB method
tic;
[m,n]= size(A);
B= randn(n, k+s);
if i == 0
    [Q, ~, ~] = eigSVD(A*B);
else
    [Q, ~] = lu(A*B);
end
for j = 1:i
    if j == i
        [Q, ~, ~] = eigSVD(A*(A'*Q));
    else
        [Q, ~]= lu(A*(A'*Q));
    end
end
kn = k+s;
T = A'*Q;
[v, d] = eig(T'*T);
ss=sqrt(diag(d));
S= spdiags(ss, 0, kn, kn);
u=(S\(T*v)')';
V = u;
x = kn-k+1:kn;
S = ss(x);
S = spdiags(S, 0, k, k);
U = Q*v(:, x);
V = V(:,x);
elapsedtime = toc;
end