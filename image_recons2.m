function [image] = image_recons2(titlex,m,n,k,U_est,S_est,V_est)
%image construction for 
data = im2uint8(U_est*S_est*V_est');
im=reshape(data,m,n/3,3);
image=uint8(im);  
figure
imshow(image)
str = strcat(titlex, num2str(k));
title(str)
end