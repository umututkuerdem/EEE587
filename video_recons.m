function [im] = video_recons(titlex,U_est,S_est,V_est)
%video construction
data = im2uint8(U_est*S_est*V_est');
im=zeros(240,320,3);
R=data(:,1:320);
G=data(:,321:640);
B=data(:,641:960);
im(:,:,1) = R;
im(:,:,2) = G;
im(:,:,3) = B;
im=uint8(im); 
end