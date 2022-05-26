%%

m = 2^12; % row
n = 2^8; % column
k = 2^8; % reduced dimension
X = rand(m,n);

tic;
[U,S,V] = svd(X);
X_recon_k_svd = U*S*V';
elapsed_time_svd = toc;

error_k_svd_fro = norm(X-X_recon_k_svd,"fro")/norm(X,"fro");
error_k_svd_l2 = norm(X-X_recon_k_svd)/norm(X);

%%

tic;
% c = sketch dimension
c = k+10;
S = randn(n, c) / sqrt(c);
C = X * S;

% Find QR decompostion of C = AS = QR
[Q, ~] = qr(C, 0);
% Return SVD of Q'X
[Ubar, Stilde, Vtilde] = svds(Q' * X, k);
Utilde = Q * Ubar;
X_recon_k_rsvd = Utilde*Stilde*Vtilde';
elapsedtime_rsvd = toc;

error_k_rsvd_fro = norm(X-X_recon_k_rsvd,"fro")/norm(X,"fro");
error_k_rsvd_l2 = norm(X-X_recon_k_rsvd)/norm(X);


%%

% Generate matrix size (2^12)x(2^10),(2^12)x(2^8),(2^6)x(2^12)
% Each matrix is mxn
% Choose m and n values for fat and tall matrices use their svd to save U
% and V matrices, then change singular values accordingly
% After large m (n) value is chosen choose an array of small n (m) values
% Save different matrices
% Decaying spectrum
% Uniform spectrum
% Add noise to original matrix SNR = 0.1,0.25,0.5
% Compute svd compare truncated rsvd with direct svd with reduced dimension
% k

i = k; % reduced dimension
s = k + 10; % sampling/projection space
eps = 0.1; %Adjustable parameter
p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)

%% m = 2^15, n=2^12, k = 2^[4,5,6,7,8,9,10]

% generate a random matrix
m = 2^15; % row
n = 2^12; % column
X = rand(m,n);

% calculate left and right singular vectors
tic;
[U_X,S,V_X] = svd(X);
X_recon_k_svd = U_X*S*V_X';
toc;

% generate singular values with exponential decay
singular_value_exp_decay = zeros(m,n);
exp_sigma = fliplr(logspace(-1,15,n));
for i=1:1:n
    singular_value_exp_decay(i,i) = exp_sigma(i);
end

%%
% k: decreased dimension
k_arr = 6:1:10;
k_arr = 2.^k_arr;

% Arrays to keep track of error
error_k_svd_fro_arr = zeros(length(k_arr),1);
error_k_svd_l2_arr = zeros(length(k_arr),1);
error_k_rsvd_fro_arr = zeros(length(k_arr),1);
error_k_rsvd_l2_arr = zeros(length(k_arr),1);
error_k_faster_rsvd_fro_arr = zeros(length(k_arr),1);
error_k_faster_l2_arr = zeros(length(k_arr),1);

% Arrays to keep track of elapsed time
elapsed_time_rsvd_arr = zeros(length(k_arr),1);
elapsed_time_faster_rsvd_arr = zeros(length(k_arr),1);
elapsed_time_svd_arr = zeros(length(k_arr),1);

% Generate matrix with exponential spectral decay
X = U_X*singular_value_exp_decay*V_X';

%%
% Find svd, RSVD and faster RSVD for different k values
for i=1:1:length(k_arr)
    
    [m,n] = size(X);
    clearAllMemoizedCaches;

    % reduced dimension
    k = k_arr(i);
    % find k-svd, record error and elapsed time
%     tic;
%     [U,S,V] = svds(X,k);
%     X_recon_k_svd = U*S*V';
%     % record elapsed time and error
%     elapsed_time_svd_arr(i) = toc;
%     error_k_svd_fro_arr(i) = norm(X-X_recon_k_svd,"fro")/norm(X,"fro");
%     error_k_svd_l2_arr(i) = norm(X-X_recon_k_svd)/norm(X);

    % RSVD
    % Sample X matrix and find lower dimensional matrix's svd
    tic; % start timer
    % c = sketch dimension
    c = k_arr(i)+10;
    S = randn(n, c) / sqrt(c);
    C = X * S;

    % Find QR decompostion of C = AS = QR
    [Q, ~] = qr(C, 0);
    % Return SVD of Q'X
    [Ubar, Stilde, Vtilde] = svds(Q'*X, k);
    Utilde = Q * Ubar;
    X_recon_k_rsvd = Utilde*Stilde*Vtilde';
    % Save elapsed time and error for rsvd
    elapsed_time_rsvd_arr(i) = toc;
    error_k_rsvd_fro_arr(i) = norm(X-X_recon_k_rsvd,"fro")/norm(X,"fro");
    error_k_rsvd_l2_arr(i) = norm(X-X_recon_k_rsvd)/norm(X);
    
    % Faster RSVD
    tic;

    % Parameters
    s = k + 10; % sampling/projection space
    eps = 0.1; %Adjustable parameter
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)
    
    % Following lines: C = CountSketch(A, s);
    sgn = randi(2, [1, n]) * 2 - 3; % one half are +1 and the rest are -1
    A = bsxfun(@times, X, sgn); % flip the signs of each column w.p. 50%
    ll = randsample(s, n, true); % sample n items from [s] with replacement
    C = zeros(m, s); % initialize C
    for j = 1: n
        C(:, ll(j)) = C(:, ll(j)) + A(:, j);
    end    

    A = [X, C];
    A = A';

    % Following lines: sketch = CountSketch(A, p1);  
    s = p1;
    [m,n] = size(A);
    sgn = randi(2, [1, n]) * 2 - 3; % one half are +1 and the rest are -1
    A = bsxfun(@times, A, sgn); % flip the signs of each column w.p. 50%
    ll = randsample(s, n, true); % sample n items from [s] with replacement
    sketch = zeros(m, s); % initialize C
    for j = 1: n
        sketch(:, ll(j)) = sketch(:, ll(j)) + A(:, j);
    end  

    % Following lines: sketch = GaussianProjection(sketch, p2);
    c = p2;
    S = randn(size(sketch,2), c) / sqrt(c);
    sketch = sketch * S;

    sketch = sketch';
    L = sketch(:, 1:size(X,2));
    D = sketch(:, size(X,2)+1:end);
    [QD, RD] = qr(D, 0);
    [Ubar, Sbar, Vbar] = svds(QD' * L, k);
    C = C * (pinv(RD) * (Ubar * Sbar));
    [Utilde, Stilde, Vhat] = svd(C, 'econ');
    Vtilde = Vbar * Vhat;
    X_recon_k_faster_rsvd = Utilde*Stilde*Vtilde';
    
    % Record elapsed time and error
    elapsed_time_faster_rsvd_arr(i) = toc;
    error_k_faster_rsvd_fro_arr(i) = norm(X-X_recon_k_faster_rsvd,"fro")/norm(X,"fro");
    error_k_faster_l2_arr(i) = norm(X-X_recon_k_faster_rsvd)/norm(X);
end

%% Plots

% Plot singular values
% !!! Ratio of (k+1)^th singular value and sum of the rest !!!

% Error
figure
hold on
plot(k_arr,error_k_svd_fro_arr);
plot(k_arr,error_k_rsvd_fro_arr);
plot(k_arr,error_k_svd_l2_arr);
plot(k_arr,error_k_rsvd_l2_arr);
hold off
legend('SVD (Fro)','RSVD (Fro)','SVD (L2)','RSVD (L2)')
title('Error for K-SVD m = 2^{16}, n = 2^{12}' )
xlabel('k')
ylabel('Relative Error')

% Elapsed time
figure
hold on
plot(k_arr,elapsed_time_svd_arr);
plot(k_arr,elapsed_time_rsvd_arr);
hold off
legend('SVD','RSVD')
title('Elapsed time for K-SVD m = 2^{16}, n = 2^{12}' )
xlabel('k')
ylabel('Elapsed Time (second)')

% Plot the singular values
figure
plot(diag(singular_value_exp_decay));
title('Exponentially Decaying Singular Values')
xlabel('k')
ylabel('Singular Values')

figure
plot(diag(singular_value_linear_decay));
title('Linearly Decaying Singular Values')
xlabel('k')
ylabel('Singular Values')

%% Linear spectral decay

% generate a random matrix
m = 2^15; % row
n = 2^12; % column
X = rand(m,n);

% calculate left and right singular vectors
tic;
[U_X,S,V_X] = svd(X);
X_recon_k_svd = U_X*S*V_X';
toc

% generate singular values with linear decay
singular_value_linear_decay = zeros(m,n);

lin_sigma = fliplr(linspace(1,10^3,n));
for i=1:1:n
    singular_value_linear_decay(i,i) = lin_sigma(i);
end

%%
% k: decreased dimension
k_arr = 4:1:10;
k_arr = 2.^k_arr;

% Arrays to keep track of error
error_k_svd_fro_arr = zeros(length(k_arr),1);
error_k_svd_l2_arr = zeros(length(k_arr),1);
error_k_rsvd_fro_arr = zeros(length(k_arr),1);
error_k_rsvd_l2_arr = zeros(length(k_arr),1);

% Arrays to keep track of elapsed time
elapsed_time_rsvd_arr = zeros(length(k_arr),1);
elapsed_time_svd_arr = zeros(length(k_arr),1);

% Generate matrix with linear spectral decay
X = U_X*singular_value_linear_decay*V_X';

% Find svd and rsvd for different k values
for i=1:1:length(k_arr)

    clearAllMemoizedCaches;

    % reduced dimension
    k = k_arr(i);
    % find k-svd, record error and elapsed time
    tic;
    [U,S,V] = svds(X,k);
    X_recon_k_svd = U*S*V';
    % record elapsed time and error
    elapsed_time_svd_arr(i) = toc;
    error_k_svd_fro_arr(i) = norm(X-X_recon_k_svd,"fro")/norm(X,"fro");
    error_k_svd_l2_arr(i) = norm(X-X_recon_k_svd)/norm(X);

    % Sample X matrix and find lower dimensional matrix's svd
    tic; % start timer
    % c = sketch dimension
    c = k_arr(i)+10;
    S = randn(n, c) / sqrt(c);
    C = X * S;

    % Find QR decompostion of C = AS = QR
    [Q, ~] = qr(C, 0);
    % Return SVD of Q'X
    [Ubar, Stilde, Vtilde] = svds(Q'*X, k);
    Utilde = Q * Ubar;
    X_recon_k_rsvd = Utilde*Stilde*Vtilde';
    % Save elapsed time and error for rsvd
    elapsed_time_rsvd_arr(i) = toc;
    error_k_rsvd_fro_arr(i) = norm(X-X_recon_k_rsvd,"fro")/norm(X,"fro");
    error_k_rsvd_l2_arr(i) = norm(X-X_recon_k_rsvd)/norm(X);
end

%% Plots

% !!! Ratio of (k+1)^th singular value and sum of the rest !!!

% Error
figure
hold on
plot(k_arr,error_k_svd_fro_arr);
plot(k_arr,error_k_rsvd_fro_arr);
plot(k_arr,error_k_svd_l2_arr);
plot(k_arr,error_k_rsvd_l2_arr);
hold off
legend('SVD (Fro)','RSVD (Fro)','SVD (L2)','RSVD (L2)')
title('Error for K-SVD m = 2^{16}, n = 2^{12}' )
xlabel('k')
ylabel('Relative Error')

% Elapsed time
figure
hold on
plot(k_arr,elapsed_time_svd_arr);
plot(k_arr,elapsed_time_rsvd_arr);
hold off
legend('SVD','RSVD')
title('Elapsed time for K-SVD m = 2^{16}, n = 2^{12}' )
xlabel('k')
ylabel('Elapsed Time (second)')

%% Generate the matrix and add noise to it m=2^13,n=2^10,k=2^[4,5,6,7,8,9]

% generate a random matrix
m = 2^13; % row
n = 2^10; % column
x = rand(m,n);

% calculate left and right singular vectors
tic;
[U_X,S,V_X] = svd(x);
X_recon_k_svd = U_X*S*V_X';
toc;

% generate singular values with exponential decay
singular_value_exp_decay = zeros(m,n);
exp_sigma = fliplr(logspace(1,5,n));
for i=1:1:n
    singular_value_exp_decay(i,i) = exp_sigma(i);
end

x = U_X*singular_value_exp_decay*V_X';

%% Add noise at different levels then use K-SVD to approximate the matrix

% noise level
sigma_noise = linspace(0,1,5);
% k: decreased dimension
k_arr = 4:1:9;
k_arr = 2.^k_arr;

% Array to keep track of errors
error_k_svd_fro_arr = zeros(length(sigma_noise),length(k_arr));
error_k_svd_l2_arr = zeros(length(sigma_noise),length(k_arr));
error_k_rsvd_fro_arr = zeros(length(sigma_noise),length(k_arr));
error_k_rsvd_l2_arr = zeros(length(sigma_noise),length(k_arr));

% Loop over different noise levels
for i=1:1:length(sigma_noise)
    % If i is 1, there is no noise. Else, scale noise matrix accordingly.
    if(i == 1)
        x_noise = 0;
    else
        x_noise = rand(m,n);
        x_noise = x_noise.*(sigma_noise(i)*norm(x,"fro")/norm(x_noise,"fro"));
    end

    X = x + x_noise;
    % Loop over different k values
    for j=1:1:length(k_arr)

        clearAllMemoizedCaches;
        % reduced dimension
        k = k_arr(j);
        % find k-svd, record error
        [U,S,V] = svds(X,k);
        X_recon_k_svd = U*S*V';
        % record error
        error_k_svd_fro_arr(i,j) = norm(x-X_recon_k_svd,"fro")/norm(x,"fro");
        error_k_svd_l2_arr(i,j) = norm(x-X_recon_k_svd)/norm(x);

        % Sample X matrix and find lower dimensional matrix's svd
        % c = sketch dimension
        c = k_arr(j)+10;
        S = randn(n, c) / sqrt(c);
        C = X * S;

        % Find QR decompostion of C = AS = QR
        [Q, ~] = qr(C, 0);
        % Return SVD of Q'X
        [Ubar, Stilde, Vtilde] = svds(Q'*X, k);
        Utilde = Q * Ubar;
        X_recon_k_rsvd = Utilde*Stilde*Vtilde';
        % Save error for rsvd
        error_k_rsvd_fro_arr(i,j) = norm(x-X_recon_k_rsvd,"fro")/norm(x,"fro");
        error_k_rsvd_l2_arr(i,j) = norm(x-X_recon_k_rsvd)/norm(x);
    end
end

%% Plot

% Error
figure
hold on
for i=1:1:length(sigma_noise)
    plot(k_arr,error_k_svd_fro_arr(i,:));
    plot(k_arr,error_k_rsvd_fro_arr(i,:));
end
hold off
legend('SVD (Sigma = 0)','RSVD (Sigma = 0)','SVD (Sigma = 0.25)','RSVD (Sigma = 0.25)','SVD (Sigma = 0.5)','RSVD (Sigma = 0.5)','SVD (Sigma = 0.75)','RSVD (Sigma = 0.75)','SVD (Sigma = 1)','RSVD (Sigma = 1)')
title('Error of noisy reconstruction for K-SVD m = 2^{13}, n = 2^{10}' )
xlabel('k')
ylabel('Relative Error')
