function [imagelist] = image_recons(titlex,montagenumber,n,k,U_est,S_est,V_est)
%image construction for 
    data = im2uint8(U_est*S_est*V_est');
im=zeros(sqrt(n/3),sqrt(n/3),3);
for cpt=1:montagenumber %Number of images in a montage 
    R=data(cpt,1:n/3);
    G=data(cpt,n/3+1:2*n/3);
    B=data(cpt,2*n/3+1:n);
    k=1;
    for x=1:sqrt(n/3)
        for i=1:sqrt(n/3)
            im(x,i,1)=R(k);
            im(x,i,2)=G(k);
            im(x,i,3)=B(k);
            k=k+1;
        end
    end  
 imagelist{cpt}=uint8(im);  
end
figure
montage(imagelist)
title(titlex)
end