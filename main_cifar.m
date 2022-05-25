clear all;
clc;
%Load downloaded cifar-10 dataset
%Expression is converted to double precision, before image reconstruction
%it is converted to uint8 again (in image recons function).
data_batch1 = load("data_batch_1.mat"); %I have only used data_batch1 for following results
data_batch1.data=im2double(data_batch1.data);
%%
k=10; %top k for kSVD
n = size(data_batch1.data,2);
eps = 0.1; %Adjustable parameter
q = ceil(log10(n/eps)); %Adjustable parameter (I used a formula suggested in paper)
[U_exact, S_exact, V_exact,t_exact]= Exactsvd(data_batch1.data);
for i =1:k
    i
    s = i/eps; %Adjustable Parameter (suggested formula)
    p1 = ceil(s^2*(log10(s/eps))^6+s/eps); %Adjustable parameter (suggested formula)
    p2 = ceil(s/eps*log10(s/eps)); %Adjustable parameter (suggested formula)

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
ylabel('Time for computation (s)')
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
%%
im_number = 9; %Number of images in montage (if we use 1 image make it 1 and give a matrix 1xn to image_recons)
%Lets reconstruct images from different approaches (according to max k value)
imlist_original=image_recons("original",im_number,n,k,U_exact,S_exact,V_exact);
imlist_BL=image_recons("BlockLanczos",im_number,n,k,U_BlockLanczos{k},S_BlockLanczos{k},V_BlockLanczos{k});
imlist_ksvdFaster=image_recons("ksvdFaster",im_number,n,k,U_ksvdFaster{k},S_ksvdFaster{k},V_ksvdFaster{k});
imlist_ksvdPrototype=image_recons("ksvdPrototype",im_number,n,k,U_ksvdPrototype{k},S_ksvdPrototype{k},V_ksvdPrototype{k});

imlist_lansvd=image_recons("lansvd",im_number,n,k,U_lansvd{k},S_lansvd{k},V_lansvd{k});
imlist_basicrSVD=image_recons("basicrSVD",im_number,n,k,U_basicrSVD{k},S_basicrSVD{k},V_basicrSVD{k});
imlist_cSVD=image_recons("cSVD",im_number,n,k,U_cSVD{k},S_cSVD{k},V_cSVD{k});
imlist_pcafast=image_recons("pcafast",im_number,n,k,U_pcafast{k},S_pcafast{k},V_pcafast{k});
imlist_rSVDBKI=image_recons("rSVDBKI",im_number,n,k,U_rSVDBKI{k},S_rSVDBKI{k},V_rSVDBKI{k});
imlist_rSVDPI=image_recons("rSVDPI",im_number,n,k,U_rSVDPI{k},S_rSVDPI{k},V_rSVDPI{k});
imlist_rSVDpack=image_recons("rSVDpack",im_number,n,k,U_rSVDpack{k},S_rSVDpack{k},V_rSVDpack{k});
%% Find SSIM for different approaches using first image
ssim_o=ssim(rgb2gray(imlist_original{1}),rgb2gray(imlist_original{1})); %Should be 1
ssim_BL=ssim(rgb2gray(imlist_BL{1}),rgb2gray(imlist_original{1}));
ssim_ksvdFaster=ssim(rgb2gray(imlist_ksvdFaster{1}),rgb2gray(imlist_original{1}));
ssim_ksvdPrototype=ssim(rgb2gray(imlist_ksvdPrototype{1}),rgb2gray(imlist_original{1}));
ssim_lansvd=ssim(rgb2gray(imlist_lansvd{1}),rgb2gray(imlist_original{1}));
ssim_basicrSVD=ssim(rgb2gray(imlist_basicrSVD{1}),rgb2gray(imlist_original{1}));
ssim_cSVD=ssim(rgb2gray(imlist_cSVD{1}),rgb2gray(imlist_original{1}));
ssim_pcafast=ssim(rgb2gray(imlist_pcafast{1}),rgb2gray(imlist_original{1}));
ssim_rSVDBKI=ssim(rgb2gray(imlist_rSVDBKI{1}),rgb2gray(imlist_original{1}));
ssim_rSVDPI=ssim(rgb2gray(imlist_rSVDPI{1}),rgb2gray(imlist_original{1}));
ssim_rSVDpack=ssim(rgb2gray(imlist_rSVDpack{1}),rgb2gray(imlist_original{1}));
%% Find PSNR for different approaches using first image in the montage
[psnr_o, ~] = psnr(rgb2gray(imlist_original{1}),rgb2gray(imlist_original{1}));
[psnr_BL, ~] = psnr(rgb2gray(imlist_BL{1}),rgb2gray(imlist_original{1}));
[psnr_ksvdFaster, ~] = psnr(rgb2gray(imlist_ksvdFaster{1}),rgb2gray(imlist_original{1}));
[psnr_ksvdPrototype, ~] = psnr(rgb2gray(imlist_ksvdPrototype{1}),rgb2gray(imlist_original{1}));
[psnr_lansvd, ~] = psnr(rgb2gray(imlist_lansvd{1}),rgb2gray(imlist_original{1}));
[psnr_basicrSVD, ~] = psnr(rgb2gray(imlist_basicrSVD{1}),rgb2gray(imlist_original{1}));
[psnr_cSVD, ~] = psnr(rgb2gray(imlist_cSVD{1}),rgb2gray(imlist_original{1}));
[psnr_pcafast, ~] = psnr(rgb2gray(imlist_pcafast{1}),rgb2gray(imlist_original{1}));
[psnr_rSVDBKI, ~] = psnr(rgb2gray(imlist_rSVDBKI{1}),rgb2gray(imlist_original{1}));
[psnr_rSVDPI, ~] = psnr(rgb2gray(imlist_rSVDPI{1}),rgb2gray(imlist_original{1}));
[psnr_rSVDpack, ~] = psnr(rgb2gray(imlist_rSVDpack{1}),rgb2gray(imlist_original{1}));
%% Video reconstruction example
v = VideoReader('xylophone.mp4');
i = 0;
while hasFrame(v)
    i=i+1;
    frame = readFrame(v);
    x{i} = im2double(reshape(frame,size(frame,1),size(frame,2)*3));
end

%%
n = size(frame,2)*3;
eps = 0.1; %Adjustable parameter
q = ceil(log10(n/eps)); %Adjustable parameter (I used a formula suggested in paper)
for m=1:size(x,2)    
    [Uv_exact{m}, Sv_exact{m}, Vv_exact{m},tv_exact{m}]= Exactsvd(x{m});
    s = min([n,k/eps]); %Adjustable Parameter (suggested formula)
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)
    [Uv_BlockLanczos{m}, Sv_BlockLanczos{m}, Vv_BlockLanczos{m},tv_BlockLanczos(m)]= BlockLanczos(x{m},k,q);
    [Uv_ksvdFaster{m}, Sv_ksvdFaster{m}, Vv_ksvdFaster{m},tv_ksvdFaster(m)]= ksvdFaster(x{m},k,s,p1,p2);
    [Uv_ksvdPrototype{m}, Sv_ksvdPrototype{m}, Vv_ksvdPrototype{m},tv_ksvdPrototype(m)]= ksvdPrototype(x{m},k,s);
end
%%
for i=1:size(x,2)    
    vid1{i} = video_recons("original",Uv_exact{i},Sv_exact{i},Vv_exact{i});
    vid2{i} = video_recons("BlockLanczos",Uv_BlockLanczos{i},Sv_BlockLanczos{i},Vv_BlockLanczos{i});
    vid3{i} = video_recons("ksvdFaster",Uv_ksvdFaster{i},Sv_ksvdFaster{i},Vv_ksvdFaster{i});
    vid4{i} = video_recons("ksvdPrototype",Uv_ksvdPrototype{i},Sv_ksvdPrototype{i},Vv_ksvdPrototype{i});
end

video1 = VideoWriter("vid1.avi");
video2 = VideoWriter("vid2.avi");
video3 = VideoWriter("vid3.avi");
video4 = VideoWriter("vid4.avi");
open(video1); open(video2); open(video3); open(video4);
for i=1:size(x,2) 
    writeVideo( video1,vid1{i} ); writeVideo( video2,vid2{i} ); writeVideo( video3,vid3{i} ); writeVideo( video4,vid4{i} );
end
close(video1); close(video2); close(video3); close(video4);
