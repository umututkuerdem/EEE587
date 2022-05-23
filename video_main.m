clear all
clc
v = VideoReader('xylophone.mp4');
i = 0;
while hasFrame(v)
    i=i+1;
    frame = readFrame(v);
    x{i} = im2double(reshape(frame,240,960));
end


%%
k=50;
n = 960;
eps = 0.1; %Adjustable parameter
q = ceil(log10(n/eps)); %Adjustable parameter (I used a formula suggested in paper)
for m=1:141    
    [U_exact{m}, S_exact{m}, V_exact{m},t_exact{m}]= Exactsvd(x{m});
    s = min([3072,k/eps]); %Adjustable Parameter (suggested formula)
    p1 = min(n,ceil(s^2*(log10(s/eps))^6+s/eps)); %Adjustable parameter (suggested formula)
    p2 = min(n,ceil(s/eps*log10(s/eps))); %Adjustable parameter (suggested formula)
    [U_BlockLanczos{m}, S_BlockLanczos{m}, V_BlockLanczos{m},t_BlockLanczos(m)]= BlockLanczos(x{m},k,q);
    [U_ksvdFaster{m}, S_ksvdFaster{m}, V_ksvdFaster{m},t_ksvdFaster(m)]= ksvdFaster(x{m},k,s,p1,p2);
    [U_ksvdPrototype{m}, S_ksvdPrototype{m}, V_ksvdPrototype{m},t_ksvdPrototype(m)]= ksvdPrototype(x{m},k,s);
end
%%
%Lets reconstruct images from different Approaches (according to max k value)
for i=1:141    
    vid1{i} = video_recons("original",U_exact{i},S_exact{i},V_exact{i});
    vid2{i} = video_recons("BlockLanczos",U_BlockLanczos{i},S_BlockLanczos{i},V_BlockLanczos{i});
    vid3{i} = video_recons("ksvdFaster",U_ksvdFaster{i},S_ksvdFaster{i},V_ksvdFaster{i});
    vid4{i} = video_recons("ksvdPrototype",U_ksvdPrototype{i},S_ksvdPrototype{i},V_ksvdPrototype{i});
end
%%
video1 = VideoWriter("vid1.avi");
video2 = VideoWriter("vid2.avi");
video3 = VideoWriter("vid3.avi");
video4 = VideoWriter("vid4.avi");
open(video1); open(video2); open(video3); open(video4);
for i=1:141
    writeVideo( video1,vid1{i} ); writeVideo( video2,vid2{i} ); writeVideo( video3,vid3{i} ); writeVideo( video4,vid4{i} );
end
close(video1); close(video2); close(video3); close(video4);