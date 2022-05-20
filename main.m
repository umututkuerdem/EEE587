clear all;
clc;
%Load downloaded cifar-10 dataset
batches_meta = load("batches.meta.mat");
data_batch1 = load("data_batch_1.mat");
data_batch2 = load("data_batch_2.mat");
data_batch3 = load("data_batch_3.mat");
data_batch4 = load("data_batch_4.mat");
data_batch5 = load("data_batch_5.mat");
%%
data_batch1.data=im2double(data_batch1.data);
data_batch2.data=im2double(data_batch2.data);
data_batch3.data=im2double(data_batch3.data);
data_batch4.data=im2double(data_batch4.data);
data_batch5.data=im2double(data_batch5.data);
%%
k=50;
n = 3072;
eps = 0.1;
q = ceil(log10(n/eps));

[U_exact, S_exact, V_exact,t_exact]= Exactsvd(data_batch1.data);
for i =1:k
    s = min([3072,i/eps]);
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps));
    p2 = min(n,ceil(s/eps*log10(s/eps)));
    [U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i},t_BlockLanczos{i}]= BlockLanczos(data_batch1.data,i,q);
    [U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i},t_ksvdFaster{i}]= ksvdFaster(data_batch1.data,i,s,p1,p2);
    [U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i},t_ksvdPrototype{i}]= ksvdPrototype(data_batch1.data,i,s);
    Err_BlockLanczos{i} = errorsvd(data_batch1.data,U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i});
    Err_ksvdFaster{i}= errorsvd(data_batch1.data,U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i});
    Err_ksvdPrototype{i}= errorsvd(data_batch1.data,U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i});
end

%%
fprintf('\n Exact svd calculation for batch 1 is %f',t_exact)
fprintf('\n BlockLanczos svd calculation for batch 1 is %f',t_BlockLanczos{50})
fprintf('\n kSVDFaster svd calculation for batch 1 is %f',t_ksvdFaster{50})
fprintf('\n kSVDPrototype svd calculation for batch 1 is %f',t_ksvdPrototype{50})
%%
Err_BlockLanczos= errorsvd(data_batch1.data,U_BlockLanczos, S_BlockLanczos, V_BlockLanczos);
Err_ksvdFaster= errorsvd(data_batch1.data,U_ksvdFaster, S_ksvdFaster, V_ksvdFaster);
Err_ksvdPrototype= errorsvd(data_batch1.data,U_ksvdPrototype, S_ksvdPrototype, V_ksvdPrototype);
fprintf('\n BlockLanczos svd error for batch 1 is %f',Err_BlockLanczos)
fprintf('\n kSVDFaster svd error for batch 1 is %f',Err_ksvdFaster)
fprintf('\n kSVDPrototype svd error for batch 1 is %f \n\n',Err_ksvdPrototype)