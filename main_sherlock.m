clear all;
clc;
testImage = "sherlock.jpg";
Ireference = imread(testImage);
datax = im2double(Ireference);
imshow(Ireference)
title("High-Resolution Reference Image")
datax=im2double(reshape(datax,640,960*3));
%%
k=20; %rank k for kSVD
n = size(datax,2);
eps = 0.1; %Adjustable parameter
q = ceil(log10(n/eps)); %Adjustable parameter (I used a formula suggested in paper)
[U_exact, S_exact, V_exact,t_exact]= Exactsvd(datax);
for i =1:k
    i
    s = min([n,i/eps]); %Adjustable Parameter (suggested formula)
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)

    [U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i},t_BlockLanczos(i)]= BlockLanczos(datax,i,q);
    [U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i},t_ksvdFaster(i)]= ksvdFaster(datax,i,s,p1,p2);
    [U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i},t_ksvdPrototype(i)]= ksvdPrototype(datax,i,s);

    p = q;
    [U_lansvd{i}, S_lansvd{i}, V_lansvd{i},~,~,t_lansvd(i)]= lansvd(datax,i,'L');
    [U_basicrSVD{i}, S_basicrSVD{i}, V_basicrSVD{i},t_basicrSVD(i)]= basicrSVD(datax,i,p,s);
    [U_cSVD{i}, S_cSVD{i}, V_cSVD{i},t_cSVD(i)]= cSVD(datax,i,p,s);
    [U_pcafast{i}, S_pcafast{i}, V_pcafast{i},t_pcafast(i)]= pcafast(datax,i,p,s);
    %[U_rSVDBKI{i}, S_rSVDBKI{i}, V_rSVDBKI{i},t_rSVDBKI(i)]= rSVDBKI(datax,i,p,s);
    [U_rSVDPI{i}, S_rSVDPI{i}, V_rSVDPI{i},t_rSVDPI(i)]= rSVDPI(datax,i,p,s);
    [U_rSVDpack{i}, S_rSVDpack{i}, V_rSVDpack{i},t_rSVDpack(i)]= rSVDpack(datax,i,p,s);

    Err_BlockLanczos(i) = errorsvd(datax,U_BlockLanczos{i}, S_BlockLanczos{i}, V_BlockLanczos{i});
    Err_ksvdFaster(i)= errorsvd(datax,U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i});
    Err_ksvdPrototype(i)= errorsvd(datax,U_ksvdPrototype{i}, S_ksvdPrototype{i}, V_ksvdPrototype{i});

    Err_lansvd(i)= errorsvd(datax,U_lansvd{i}, S_lansvd{i}, V_lansvd{i});
    Err_basicrSVD(i)= errorsvd(datax,U_basicrSVD{i}, S_basicrSVD{i}, V_basicrSVD{i});
    Err_cSVD(i)= errorsvd(datax,U_cSVD{i}, S_cSVD{i}, V_cSVD{i});
    Err_pcafast(i)= errorsvd(datax,U_pcafast{i}, S_pcafast{i}, V_pcafast{i});
    %Err_rSVDBKI(i)= errorsvd(datax,U_rSVDBKI{i}, S_rSVDBKI{i}, V_rSVDBKI{i});
    Err_rSVDPI(i)= errorsvd(datax,U_rSVDPI{i}, S_rSVDPI{i}, V_rSVDPI{i});
    Err_rSVDpack(i)= errorsvd(datax,U_rSVDpack{i}, S_rSVDpack{i}, V_rSVDpack{i});
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
%fprintf('\n rSVDBKI svd error for batch 1 is %f \n\n',Err_rSVDBKI(k))
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
%semilogy(1:k,t_rSVDBKI,'DisplayName','trSVDBKI');
%hold on
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
%semilogy(1:k,Err_rSVDBKI,'DisplayName','Err-rSVDBKI');
%hold on
semilogy(1:k,Err_rSVDPI,'DisplayName','Err-rSVDPI');
hold on
semilogy(1:k,Err_rSVDpack,'DisplayName','Err-rSVDpack');
hold off
legend
xlabel('k')
ylabel('Error for different randomized SVD Approaches')
grid on
%%
%Lets reconstruct images from different approaches (according to max k value)
im_original=image_recons2("original",size(datax,1),size(datax,2),k,U_exact,S_exact,V_exact);
im_BL=image_recons2("BlockLanczos",size(datax,1),size(datax,2),k,U_BlockLanczos{k},S_BlockLanczos{k},V_BlockLanczos{k});
im_ksvdFaster=image_recons2("ksvdFaster",size(datax,1),size(datax,2),k,U_ksvdFaster{k},S_ksvdFaster{k},V_ksvdFaster{k});
im_ksvdPrototype=image_recons2("ksvdPrototype",size(datax,1),size(datax,2),k,U_ksvdPrototype{k},S_ksvdPrototype{k},V_ksvdPrototype{k});

im_lansvd=image_recons2("lansvd",size(datax,1),size(datax,2),k,U_lansvd{k},S_lansvd{k},V_lansvd{k});
im_basicrSVD=image_recons2("basicrSVD",size(datax,1),size(datax,2),k,U_basicrSVD{k},S_basicrSVD{k},V_basicrSVD{k});
im_cSVD=image_recons2("cSVD",size(datax,1),size(datax,2),k,U_cSVD{k},S_cSVD{k},V_cSVD{k});
im_pcafast=image_recons2("pcafast",size(datax,1),size(datax,2),k,U_pcafast{k},S_pcafast{k},V_pcafast{k});
%im_rSVDBKI=image_recons2("rSVDBKI",size(datax,1),size(datax,2),k,U_rSVDBKI{k},S_rSVDBKI{k},V_rSVDBKI{k});
im_rSVDPI=image_recons2("rSVDPI",size(datax,1),size(datax,2),k,U_rSVDPI{k},S_rSVDPI{k},V_rSVDPI{k});
im_rSVDpack=image_recons2("rSVDpack",size(datax,1),size(datax,2),k,U_rSVDpack{k},S_rSVDpack{k},V_rSVDpack{k});
%% Find SSIM for different approaches using first image
ssim_o=ssim(rgb2gray(im_original),rgb2gray(im_original)); %Should be 1
ssim_BL=ssim(rgb2gray(im_BL),rgb2gray(im_original));
ssim_ksvdFaster=ssim(rgb2gray(im_ksvdFaster),rgb2gray(im_original));
ssim_ksvdPrototype=ssim(rgb2gray(im_ksvdPrototype),rgb2gray(im_original));
ssim_lansvd=ssim(rgb2gray(im_lansvd),rgb2gray(im_original));
ssim_basicrSVD=ssim(rgb2gray(im_basicrSVD),rgb2gray(im_original));
ssim_cSVD=ssim(rgb2gray(im_cSVD),rgb2gray(im_original));
ssim_pcafast=ssim(rgb2gray(im_pcafast),rgb2gray(im_original));
%ssim_rSVDBKI=ssim(rgb2gray(im_rSVDBKI),rgb2gray(im_original));
ssim_rSVDPI=ssim(rgb2gray(im_rSVDPI),rgb2gray(im_original));
ssim_rSVDpack=ssim(rgb2gray(im_rSVDpack),rgb2gray(im_original));

fprintf('\n SSIM for exact: %f \n',ssim_o)
fprintf('\n SSIM for BL: %f \n',ssim_BL)
fprintf('\n SSIM for ksvdFaster: %f \n',ssim_ksvdFaster)
fprintf('\n SSIM for ksvdPrototype: %f \n',ssim_ksvdPrototype)
fprintf('\n SSIM for lansvd: %f \n',ssim_lansvd)
fprintf('\n SSIM for basicrSVD: %f \n',ssim_basicrSVD)
fprintf('\n SSIM for cSVD: %f \n',ssim_cSVD)
fprintf('\n SSIM for pcafast: %f \n',ssim_pcafast)
fprintf('\n SSIM for rSVDPI: %f \n',ssim_rSVDPI)
fprintf('\n SSIM for rSVDpack: %f \n',ssim_rSVDpack)


%% Find PSNR for different approaches using first image in the montage
[psnr_o, ~] = psnr(rgb2gray(im_original),rgb2gray(im_original));
[psnr_BL, ~] = psnr(rgb2gray(im_BL),rgb2gray(im_original));
[psnr_ksvdFaster, ~] = psnr(rgb2gray(im_ksvdFaster),rgb2gray(im_original));
[psnr_ksvdPrototype, ~] = psnr(rgb2gray(im_ksvdPrototype),rgb2gray(im_original));
[psnr_lansvd, ~] = psnr(rgb2gray(im_lansvd),rgb2gray(im_original));
[psnr_basicrSVD, ~] = psnr(rgb2gray(im_basicrSVD),rgb2gray(im_original));
[psnr_cSVD, ~] = psnr(rgb2gray(im_cSVD),rgb2gray(im_original));
[psnr_pcafast, ~] = psnr(rgb2gray(im_pcafast),rgb2gray(im_original));
%[psnr_rSVDBKI, ~] = psnr(rgb2gray(im_rSVDBKI),rgb2gray(im_original));
[psnr_rSVDPI, ~] = psnr(rgb2gray(im_rSVDPI),rgb2gray(im_original));
[psnr_rSVDpack, ~] = psnr(rgb2gray(im_rSVDpack),rgb2gray(im_original));


fprintf('\n\n\n PSNR for exact: %f \n',psnr_o)
fprintf('\n PSNR for BL: %f \n',psnr_BL)
fprintf('\n PSNR for ksvdFaster: %f \n',psnr_ksvdFaster)
fprintf('\n PSNR for ksvdPrototype: %f \n',psnr_ksvdPrototype)
fprintf('\n PSNR for lansvd: %f \n',psnr_lansvd)
fprintf('\n PSNR for basicrSVD: %f \n',psnr_basicrSVD)
fprintf('\n PSNR for cSVD: %f \n',psnr_cSVD)
fprintf('\n PSNR for pcafast: %f \n',psnr_pcafast)
fprintf('\n PSNR for rSVDPI: %f \n',psnr_rSVDPI)
fprintf('\n PSNR for rSVDpack: %f \n',psnr_rSVDpack)