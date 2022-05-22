clear all;
clc;
addpath('D:\EEE587 Project\EEE587-main-sk\SVD Methods')
addpath('D:\EEE587 Project\EEE587-main-sk\CIFAR Extraction\cifar-10-batches-mat')
addpath('D:\EEE587 Project\EEE587-main-sk\Sketch Methods')
addpath('D:\EEE587 Project\EEE587-main-sk\matlab-master\PROPACK')
addpath('D:\EEE587 Project\EEE587-main-sk\fSVT-master\SVT')
addpath('D:\EEE587 Project\EEE587-main-sk\fSVT-master\rSVD')

%Load downloaded cifar-10 dataset
data_batch1 = load("data_batch_1.mat"); %I have only used data_batch1 for following results

%%
%Expression is converted to double precision, before image reconstruction
%it is converted to uint8 again (in image recons function).
data_batch1.data=im2double(data_batch1.data);

%%
k=10;
n = size(data_batch1.data,2);
eps = 0.1; %Adjustable parameter
q = ceil(log10(n/eps)); %Adjustable parameter (I used a formula suggested in paper)

[U_exact, S_exact, V_exact,t_exact]= Exactsvd(data_batch1.data);
for i = 1:k
    i
    s = min([n,i/eps]); %Adjustable Parameter (suggested formula)
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)
    [U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i},t_BlockLanczos(i)]= BlockLanczos(data_batch1.data,i,q);
    [U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i},t_ksvdFaster(i)]= ksvdFaster(data_batch1.data,i,s,p1,p2);
    [U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i},t_ksvdPrototype(i)]= ksvdPrototype(data_batch1.data,i,s);
    
    p = q;
    [U_lansvd{i}, S_lansvd{i}, V_lansvd{i},~,~,t_lansvd(i)]= lansvd(data_batch1.data,i,'L');
    [U_basicrSVD{i}, S_basicrSVD{i}, V_basicrSVD{i},t_basicrSVD(i)]= basicrSVD(data_batch1.data,i,p,s);
    [U_cSVD{i}, S_cSVD{i}, V_cSVD{i},t_cSVD(i)]= cSVD(data_batch1.data,i,p,s);
    [U_pcafast{i}, S_pcafast{i}, V_pcafast{i},t_pcafast(i)]= pcafast(data_batch1.data,i,p,s);
    [U_rSVDBKI{i}, S_rSVDBKI{i}, V_rSVDBKI{i},t_rSVDBKI(i)]= rSVDBKI(data_batch1.data,i,p,s);
    [U_rSVDPI{i}, S_rSVDPI{i}, V_rSVDPI{i},t_rSVDPI(i)]= rSVDPI(data_batch1.data,i,p,s);
    [U_rSVDpack{i}, S_rSVDpack{i}, V_rSVDpack{i},t_rSVDpack(i)]= rSVDpack(data_batch1.data,i,p,s);
    
    Err_BlockLanczos(i) = errorsvd(data_batch1.data,U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i});
    Err_ksvdFaster(i)= errorsvd(data_batch1.data,U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i});
    Err_ksvdPrototype(i)= errorsvd(data_batch1.data,U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i});
    
  
    Err_lansvd(i)= errorsvd(data_batch1.data,U_lansvd{i}, S_lansvd{i}, V_lansvd{i});
    Err_basicrSVD(i)= errorsvd(data_batch1.data,U_basicrSVD{i}, S_basicrSVD{i}, V_basicrSVD{i});
    Err_cSVD(i)= errorsvd(data_batch1.data,U_cSVD{i}, S_cSVD{i}, V_cSVD{i});
    Err_pcafast(i)= errorsvd(data_batch1.data,U_pcafast{i}, S_pcafast{i}, V_pcafast{i});
    Err_rSVDBKI(i)= errorsvd(data_batch1.data,U_rSVDBKI{i}, S_rSVDBKI{i}, V_rSVDBKI{i});
    Err_rSVDPI(i)= errorsvd(data_batch1.data,U_rSVDPI{i}, S_rSVDPI{i}, V_rSVDPI{i});
    Err_rSVDpack(i)= errorsvd(data_batch1.data,U_rSVDpack{i}, S_rSVDpack{i}, V_rSVDpack{i});

end
t_exact_arr = ones(1,k)*t_exact;
fprintf('\n Time to calculate exact svd for batch 1 is %f',t_exact)
fprintf('\n Time to calculate BlockLanczos svd for batch 1 is %f',t_BlockLanczos(k))
fprintf('\n Time to calculate kSVDFaster for batch 1 is %f ',t_ksvdFaster(k))
fprintf('\n Time to calculate kSVDPrototype for batch 1 is %f',t_ksvdPrototype(k))
fprintf('\n BlockLanczos svd error for batch 1 is %f',Err_BlockLanczos(k))
fprintf('\n kSVDFaster svd error for batch 1 is %f',Err_ksvdFaster(k))
fprintf('\n kSVDPrototype svd error for batch 1 is %f \n\n',Err_ksvdPrototype(k))
fprintf('\n lansvd svd error for batch 1 is %f \n\n',Err_lansvd(k))
fprintf('\n basicrSVD svd error for batch 1 is %f \n\n',Err_basicrSVD(k))
fprintf('\n cSVD svd error for batch 1 is %f \n\n',Err_cSVD(k))
fprintf('\n pcafast svd error for batch 1 is %f \n\n',Err_pcafast(k))
fprintf('\n rSVDBKI svd error for batch 1 is %f \n\n',Err_rSVDBKI(k))
fprintf('\n rSVDPI svd error for batch 1 is %f \n\n',Err_rSVDPI(k))
fprintf('\n rSVDpack svd error for batch 1 is %f \n\n',Err_rSVDpack(k))
%%
opengl software
figure
semilogy(1:k,t_exact_arr,'DisplayName','texact');
hold on
semilogy(1:k,t_BlockLanczos,'DisplayName','tBL');
hold on 
semilogy(1:k,t_ksvdFaster,'DisplayName','tFaster');
hold on
semilogy(1:k,t_ksvdPrototype,'DisplayName','tPrototype');
hold on
semilogy(1:k,t_lansvd,'DisplayName','tlansvd');
hold on
semilogy(1:k,t_basicrSVD,'DisplayName','tbasicrSVD');
hold on
semilogy(1:k,t_cSVD,'DisplayName','cSVD');
hold on
semilogy(1:k,t_pcafast,'DisplayName','tpcafast');
hold on
semilogy(1:k,t_rSVDBKI,'DisplayName','trSVDBKI');
hold on
semilogy(1:k,t_rSVDPI,'DisplayName','trSVDPI');
hold on
semilogy(1:k,t_rSVDpack,'DisplayName','trSVDpack');
hold off
legend
xlabel('k')
ylabel('Time for computation')
grid on

%%
figure
semilogy(1:k,Err_BlockLanczos,'DisplayName','Err-BL');
hold on 
semilogy(1:k,Err_ksvdFaster,'DisplayName','Err-Faster');
hold on
semilogy(1:k,Err_ksvdPrototype,'DisplayName','Err-Prototype');
hold on
semilogy(1:k,Err_lansvd,'DisplayName','Err-lansvd');
hold on
semilogy(1:k,Err_basicrSVD,'DisplayName','Err-basicrSVD');
hold on
semilogy(1:k,Err_cSVD,'DisplayName','Err-cSVD');
hold on
semilogy(1:k,Err_pcafast,'DisplayName','Err-pcafast');
hold on
semilogy(1:k,Err_rSVDBKI,'DisplayName','Err-rSVDBKI');
hold on
semilogy(1:k,Err_rSVDPI,'DisplayName','Err-rSVDPI');
hold on
semilogy(1:k,Err_rSVDpack,'DisplayName','Err-rSVDpack');
hold off
legend
xlabel('k')
ylabel('Error for different randomized SVD Approaches')
grid on


