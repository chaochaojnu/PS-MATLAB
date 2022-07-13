function [sumup,procImg] = preprocess(inputImg,roi,thres,Ep)
%PREPROCESS cut ROI and define process areas with brinary 1
%
%Input:
%   inputImg--4 direction light images;
%   roi--ROI areas
%   thres--upper will be calculate
%   Ep--correct the light energy
%
%Output:
%   sumup--sum 4 dir light images
%   procImg--cutted and processed images

sumup=(inputImg(:,:,1)+inputImg(:,:,2)+inputImg(:,:,3)+inputImg(:,:,4))/4;
% Ia=allDirection_gray;
h=roi(2)-roi(1);
w=roi(4)-roi(3);
procImg=zeros(h,w, size(inputImg,3));
ROI_mask=im2bw(sumup/255,thres/255);
se=strel('square',21);
ROI_mask=imdilate(ROI_mask,se);
% ROI_mask = imfill(ROI_mask, 'holes');
sumup(ROI_mask==0)=0;
for i=1:size(procImg,3)
    temp=inputImg(:,:,i);
    temp(ROI_mask==0)=0;
    temp=double(temp)./Ep(:,:,i);
    temp(isnan(temp))=0;temp(isinf(temp))=0;
    temp=double(temp(roi(1):roi(2)-1,roi(3):roi(4)-1)); 
    procImg(:,:,i)=temp;
end
sumup=procImg(:,:,1)+procImg(:,:,2)+procImg(:,:,3)+procImg(:,:,4);
end

