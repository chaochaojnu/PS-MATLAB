function [albedoImage,surfaceNormals] = getNormalVec(imarray,Ia,lightCorr,ways)
%GETNORMALVEC calculate surface normal vector and reflect rate
%   
%Input:
%   imarray--pre-processed images
%   lightCorrect--correct the light, cause of unqualified light direction
%   ways--ways of calculate('minus','divide','iter')
%
%Output:
%   albedoImage--normal vector of the surface
%   surfaceNormals--reflection rate of the surface

%% calculate the normal-vector of the surface
[h, w, ~] = size(imarray);
surfaceNormals=zeros(h,w,3); 
albedoImage=zeros(h,w); 
switch ways
    case 'minus'
        Ip=(double(imarray(:,:,1))-double(imarray(:,:,3)))./double(Ia);
        Iq=(double(imarray(:,:,2))-double(imarray(:,:,4)))./double(Ia);
        Ip(isnan(Ip))=0;Ip(isinf(Ip))=0;
        Iq(isnan(Iq))=0;Iq(isinf(Iq))=0;
        surfaceNormals(:,:,1)=(2*Ip)/lightCorr;
        surfaceNormals(:,:,2)=(2*Iq)/lightCorr;
        surfaceNormals(:,:,3)=ones(h,w);
        
    case 'divide'
        Ip=imarray(:,:,1)./imarray(:,:,3);
        Iq=imarray(:,:,2)./imarray(:,:,4);
        surfaceNormals=zeros(h,w,3);
        surfaceNormals(:,:,1)=(-Ip.*lightCorr(:,:,6)+lightCorr(:,:,2)...
                                )./(Ip.*lightCorr(:,:,5)+lightCorr(:,:,1));
        surfaceNormals(:,:,2)=(-Iq.*lightCorr(:,:,8)+lightCorr(:,:,4)...
                                )./(Iq.*lightCorr(:,:,7)+lightCorr(:,:,3));
        surfaceNormals(:,:,3)=-ones(h,w);
        
    case 'iter'
        error('not write yet\n');
        
end



%% calculate the reflect rate of the surface
for i = 1:h
    for j = 1:w
        reflect_rate=sqrt(surfaceNormals(i,j,1)^2 + surfaceNormals(i,j,2)^2 + surfaceNormals(i,j,3)^2); 
        albedoImage(i,j)=reflect_rate;
    end
end
surfaceNormals(:,:,1)=surfaceNormals(:,:,1)./albedoImage;
surfaceNormals(:,:,2)=surfaceNormals(:,:,2)./albedoImage;
surfaceNormals(:,:,3)=surfaceNormals(:,:,3)./albedoImage;
end

