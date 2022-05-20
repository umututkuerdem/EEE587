function [Utilde, Stilde, Vtilde,elapsedtime] = ksvdPrototype(A, k, s)
tic;
C = CountSketch(A, s);
[Q, R] = qr(C, 0);
[Ubar, Stilde, Vtilde] = svds(Q' * A, k);
Utilde = Q * Ubar;
elapsedtime = toc;
end