clear all;
clc;
%Load downloaded cifar-10 dataset
batches_meta = load("batches.meta.mat");
data_batch1 = load("data_batch_1.mat"); %I have only used data_batch1 for following results
data_batch2 = load("data_batch_2.mat");
data_batch3 = load("data_batch_3.mat");
data_batch4 = load("data_batch_4.mat");
data_batch5 = load("data_batch_5.mat");
%%
%Expression is converted to double precision, before image reconstruction
%it is converted to uint8 again (in image recons function).
data_batch1.data=im2double(data_batch1.data);
data_batch2.data=im2double(data_batch2.data);
data_batch3.data=im2double(data_batch3.data);
data_batch4.data=im2double(data_batch4.data);
data_batch5.data=im2double(data_batch5.data);
%%
k=100;
n = 3072;
eps = 0.1; %Adjustable parameter
q = ceil(log10(n/eps)); %Adjustable parameter (I used a formula suggested in paper)

[U_exact, S_exact, V_exact,t_exact]= Exactsvd(data_batch1.data);
for i =1:k
    s = min([3072,i/eps]); %Adjustable Parameter (suggested formula)
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)
    [U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i},t_BlockLanczos(i)]= BlockLanczos(data_batch1.data,i,q);
    [U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i},t_ksvdFaster(i)]= ksvdFaster(data_batch1.data,i,s,p1,p2);
    [U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i},t_ksvdPrototype(i)]= ksvdPrototype(data_batch1.data,i,s);
    Err_BlockLanczos(i) = errorsvd(data_batch1.data,U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i});
    Err_ksvdFaster(i)= errorsvd(data_batch1.data,U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i});
    Err_ksvdPrototype(i)= errorsvd(data_batch1.data,U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i});
end
t_exact_arr = ones(1,k)*t_exact;
fprintf('\n Time to calculate exact svd for batch 1 is %f',t_exact)
fprintf('\n Time to calculate BlockLanczos svd for batch 1 is %f',t_BlockLanczos(k))
fprintf('\n Time to calculate kSVDFaster for batch 1 is %f ',t_ksvdFaster(k))
fprintf('\n Time to calculate kSVDPrototype for batch 1 is %f',t_ksvdPrototype(k))
fprintf('\n BlockLanczos svd error for batch 1 is %f',Err_BlockLanczos(k))
fprintf('\n kSVDFaster svd error for batch 1 is %f',Err_ksvdFaster(k))
fprintf('\n kSVDPrototype svd error for batch 1 is %f \n\n',Err_ksvdPrototype(k))
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
hold off
legend
xlabel('k')
ylabel('Error for different randomized SVD Approaches')
grid on
%%
%Lets reconstruct images from different Approaches (according to max k value)
image_recons("original",k,U_exact,S_exact,V_exact)
image_recons("BlockLanczos",k,U_BlockLanczos{k},S_BlockLanczos{k},V_BlockLanczos{k})
image_recons("ksvdFaster",k,U_ksvdFaster{k},S_ksvdFaster{k},V_ksvdFaster{k})
image_recons("ksvdPrototype",k,U_ksvdPrototype{k},S_ksvdPrototype{k},V_ksvdPrototype{k})



