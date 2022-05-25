
xx = [10 30 50];
for k=xx
    k
    [ssim_topk_sherlock, ssim_faster_sherlock,psnr_topk_sherlock, psnr_faster_sherlock] = image_in("sherlock.jpg",k);
    fprintf('\n (Sherlock) SSIM for truncated SVD when k= %f  %f',k,ssim_topk_sherlock)
    fprintf('\n (Sherlock) SSIM for rSVD when k= %f  %f',k,ssim_faster_sherlock)
    fprintf('\n (Sherlock) PSNR for truncated SVD when k= %f  %f',k,psnr_topk_sherlock)
    fprintf('\n (Sherlock) PSNR for rSVD when k= %f  %f\n\n',k,psnr_faster_sherlock)
end
%%
xx = [10 30 50];
for k=xx
    k
    [ssim_topk_coffee, ssim_faster_coffee,psnr_topk_coffee, psnr_faster_coffee] = image_in("coffeeMachine.jpg",k);
    fprintf('\n (coffee) SSIM for truncated SVD when k= %f  %f',k,ssim_topk_coffee)
    fprintf('\n (coffee) SSIM for rSVD when k= %f  %f',k,ssim_faster_coffee)
    fprintf('\n (coffee) PSNR for truncated SVD when k= %f  %f',k,psnr_topk_coffee)
    fprintf('\n (coffee) PSNR for rSVD when k= %f  %f\n\n',k,psnr_faster_coffee)
end

%%
xx = [10 30 50];
for k=xx
    k
    [ssim_topk_license, ssim_faster_license,psnr_topk_license, psnr_faster_license] = image_in("licensePlates.jpg",k);
    fprintf('\n (license) SSIM for truncated SVD when k= %f  %f',k,ssim_topk_license)
    fprintf('\n (license) SSIM for rSVD when k= %f  %f',k,ssim_faster_license)
    fprintf('\n (license) PSNR for truncated SVD when k= %f  %f',k,psnr_topk_license)
    fprintf('\n (license) PSNR for rSVD when k= %f  %f\n\n',k,psnr_faster_license)
end
%%
xx = [10 30 50];
for k=xx
    k
    [ssim_topk_scene, ssim_faster_scene,psnr_topk_scene, psnr_faster_scene] = image_in("sceneReconstructionLeft.jpg",k);
    fprintf('\n (scene) SSIM for truncated SVD when k= %f  %f',k,ssim_topk_scene)
    fprintf('\n (scene) SSIM for rSVD when k= %f  %f',k,ssim_faster_scene)
    fprintf('\n (scene) PSNR for truncated SVD when k= %f  %f',k,psnr_topk_scene)
    fprintf('\n (scene) PSNR for rSVD when k= %f  %f\n\n',k,psnr_faster_scene)
end
%%
xx = [10 30 50];
for k=xx
    k
    [ssim_topk_visionteam, ssim_faster_visionteam,psnr_topk_visionteam, psnr_faster_visionteam] = image_in("visionteam.jpg",k);
    fprintf('\n (visionteam) SSIM for truncated SVD when k= %f  %f',k,ssim_topk_visionteam)
    fprintf('\n (visionteam) SSIM for rSVD when k= %f  %f',k,ssim_faster_visionteam)
    fprintf('\n (visionteam) PSNR for truncated SVD when k= %f  %f',k,psnr_topk_visionteam)
    fprintf('\n (visionteam) PSNR for rSVD when k= %f  %f\n\n',k,psnr_faster_visionteam)
end

%%
%% Video reconstruction example
k=30;
v = VideoReader('xylophone.mp4');
i = 0;
while hasFrame(v)
    i=i+1;
    frame = readFrame(v);
    x{i} = im2double(reshape(frame,size(frame,1),size(frame,2)*3));
end
n = size(frame,2)*3;
eps = 0.1; %Adjustable parameter
for m=1:size(x,2)    
    [Uv_exact{m}, Sv_exact{m}, Vv_exact{m},tv_exact{m}]= Exactsvd(x{m});
    s = min([n,k/eps]); %Adjustable Parameter (suggested formula)
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)
    [Uv_ksvdFaster{m}, Sv_ksvdFaster{m}, Vv_ksvdFaster{m},tv_ksvdFaster(m)]= ksvdFaster(x{m},k,s,p1,p2);
end
for i=1:size(x,2)    
    vid1{i} = video_recons("original",Uv_exact{i},Sv_exact{i},Vv_exact{i});
    vid3{i} = video_recons("ksvdFaster",Uv_ksvdFaster{i},Sv_ksvdFaster{i},Vv_ksvdFaster{i});
end

video1 = VideoWriter("vid_original_30.avi");
video3 = VideoWriter("vid_rSVD_30.avi");
open(video1); open(video3);
for i=1:size(x,2) 
    writeVideo( video1,vid1{i} ); writeVideo( video3,vid3{i} );
end
close(video1); close(video3);