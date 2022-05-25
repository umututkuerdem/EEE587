function [ssim_topk,ssim_ksvdFaster,psnr_topk, psnr_ksvdFaster]=image_in(image,k)
testImage = image;
Ireference = imread(testImage);
datax = im2double(Ireference);
datax=im2double(reshape(datax,size(datax,1),size(datax,2)*3));
n = size(datax,2);
eps = 0.1; %Adjustable parameter
q = ceil(log10(n/eps)); %Adjustable parameter (I used a formula suggested in paper)
[U_exact, S_exact, V_exact,t_exact]= Exactsvd(datax);
[U_topk, S_topk, V_topk] = svds(datax,k);
for i =1:k
    s = min([n,i/eps]); %Adjustable Parameter (suggested formula)
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)
    [U_ksvdFaster{i}, S_ksvdFaster{i}, V_ksvdFaster{i},t_ksvdFaster(i)]= ksvdFaster(datax,i,s,p1,p2);
end

t_exact_arr = ones(1,k)*t_exact;
fprintf('\n Time to calculate exact svd for image is %f',t_exact)
fprintf('\n Time to calculate kSVDFaster for image is %f ',t_ksvdFaster(k))
%Lets reconstruct images from different approaches (according to max k value)
im_original=image_recons2("Original Image for k=",size(datax,1),size(datax,2),k,U_exact,S_exact,V_exact);
im_topk=image_recons2("Truncated SVD for k=",size(datax,1),size(datax,2),k,U_topk,S_topk,V_topk);
im_ksvdFaster=image_recons2("Image by rSVD (Faster) for k=",size(datax,1),size(datax,2),k,U_ksvdFaster{k},S_ksvdFaster{k},V_ksvdFaster{k});

%% Find SSIM for different approaches using first image
ssim_topk=ssim(rgb2gray(im_topk),rgb2gray(im_original));
ssim_ksvdFaster=ssim(rgb2gray(im_ksvdFaster),rgb2gray(im_original));
%% Find PSNR for different approaches using first image in the montage
i_or=im2double(rgb2gray(im_original)); %Normalization
i_topk=im2double(rgb2gray(im_topk)); %Normalization
i_est=im2double(rgb2gray(im_ksvdFaster)); %Normalization
[psnr_topk, ~] = psnr(i_topk,i_or);
[psnr_ksvdFaster, ~] = psnr(i_est,i_or);
end