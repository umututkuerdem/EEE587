function image_recons(titlex,k,U_est,S_est,V_est)
%image construction
    data = im2uint8(U_est*S_est*V_est');
im=zeros(32,32,3);
for cpt=1:100
    R=data(cpt,1:1024);
    G=data(cpt,1025:2048);
    B=data(cpt,2049:3072);
    k=1;
    for x=1:32
        for i=1:32
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