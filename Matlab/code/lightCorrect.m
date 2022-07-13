function [Ep,angleMap] = lightCorrect(base_imarray,lightCircle,lightHeight,cameraHeight,lightshape,num,lightsize)
%LIGHTCORRECT calculate the light engry and light direction
%   
%Input:
%   base_imarray1 --Standard diffuse panel images
%   lightCircle --radius of the light
%   lightHeight --height of light
%   cameraHeight --height of camera
%   lightshape --shape of light('point','circle','square')
%   num --odd number(>=3) to iter sum for each area of the light, the more the accurate but more slow
%   lightsize --the angle/length of each light source area, when lightshape is 'circle'/'square'
%
%Output:
%   Ep --light energy
%   lightAngleMap --light angle of each pixel



%% find max/min value of images(找出最大亮度值与坐标点)
h = size(base_imarray,1);w = size(base_imarray,2);
total_images=size(base_imarray,3);
base_maxmin_point=zeros(4,5);% [maxPointX,maxPointY,maxValue,minValue, mainLightIntensity]
for j = 1 : total_images
    temp=base_imarray(:,:,j);
    %temp=medfilt2(base_imarray(:,:,j),[25 25]);
    % max/min value of images
    maxValue=max(temp(:));
    minValue=min(temp(:));
    base_maxmin_point(j,3)=maxValue;
    base_maxmin_point(j,4)=minValue;
    % max/min value position of images
    masks=im2bw(temp/255,(maxValue-25)/255);
    [maxPointY,maxPointX]=find(masks==1);
    base_maxmin_point(j,1)=mean(maxPointX(:));
    base_maxmin_point(j,2)=mean(maxPointY(:));
end
lightCenter=sum(base_maxmin_point)/4;


%%
switch lightshape
    case 'point'
       %% calculate the position of the light source
        lightPosition=zeros(4,2);
        for j = 1 : total_images
            vecX=base_maxmin_point(j,1)-lightCenter(1);
            vecY=base_maxmin_point(j,2)-lightCenter(2);
            lightPosition(j,1)=lightCenter(1)+vecX*lightCircle/sqrt(vecX^2+vecY^2);
            lightPosition(j,2)=lightCenter(2)+vecY*lightCircle/sqrt(vecX^2+vecY^2); 
        end
       %% calculate light energy and light angle of each pixel with a bigger image
        angleMap=zeros(h,w,total_images*2); % angle of incidece(入射角)
        lightAngleMap=zeros(h,w,total_images); % main optical axis Angle(主光源角)
        lightdistanceMap=zeros(h,w,total_images); % distance to the light(到光源的距离)
        for j = 1 : total_images
            temp_f=(base_maxmin_point(j,2)-lightPosition(j,2))^2+(base_maxmin_point(j,1)-lightPosition(j,1))^2;
            length_f=sqrt(temp_f+lightHeight^2);   
            for k=1:h
                for p=1:w
                    temp_l=(k-lightPosition(j,2))^2+(p-lightPosition(j,1))^2;
                    temp_distance=(k-base_maxmin_point(j,2))^2+(p-base_maxmin_point(j,1))^2;
                    short=sqrt(temp_l);
                    length=sqrt(temp_l+lightHeight^2);
                    angleMap(k,p,(j-1)*2+1)=short/length;       %sin map
                    angleMap(k,p,(j-1)*2+2)=lightHeight/length;    %cos map       
                    lightdistanceMap(k,p,j)=length^2;
                    lightAngleMap(k,p,j)=(length^2+length_f^2-temp_distance)/(2*length*length_f);
                end
            end  
            base_maxmin_point(j,5)=base_maxmin_point(j,3)*length_f^2;
        end
        Ep=zeros(h,w,total_images);
        for j = 1 : total_images
            Ep(:,:,j)=base_maxmin_point(j,5)*((lightAngleMap(:,:,j)).^10)./lightdistanceMap(:,:,j);
        end
        display=(base_imarray(:,:,1)+base_imarray(:,:,2)+base_imarray(:,:,3)+base_imarray(:,:,4))/4;
        figure;imshow(rescale(display), []);
        line([lightPosition(1,1),lightCenter(1)],[lightPosition(1,2),lightCenter(2)]);
        line([lightPosition(2,1),lightCenter(1)],[lightPosition(2,2),lightCenter(2)]);
        line([lightPosition(3,1),lightCenter(1)],[lightPosition(3,2),lightCenter(2)]);
        line([lightPosition(4,1),lightCenter(1)],[lightPosition(4,2),lightCenter(2)]);
    case 'circle'
        if num<3||mod(num,2)~=1
            error('num must be odd and >=3.\n');
        end        
       %% calculate the edge size
        if round(lightCenter(1))>=w/2
            bigImgHW=round(lightCenter(1));
            offsetX=0; 
        else
            bigImgHW=w-round(lightCenter(1));
            offsetX=bigImgHW-round(lightCenter(1));

        end
        if round(lightCenter(2))>=h/2
            bigImgHH=round(lightCenter(2));
            offsetY=0;
        else
            bigImgHH=h-round(lightCenter(2));
            offsetY=bigImgHH-round(lightCenter(2));
        end
        minR=ceil(sqrt(bigImgHW^2+bigImgHH^2));
        offsetX=offsetX+minR-bigImgHW;
        offsetY=offsetY+minR-bigImgHH;
        base_maxmin_point(:,1)=base_maxmin_point(:,1)+offsetX;
        base_maxmin_point(:,2)=base_maxmin_point(:,2)+offsetY;
        lightCenter(1)=lightCenter(1)+offsetX;
        lightCenter(2)=lightCenter(2)+offsetY;
        cut_rect=[offsetY+1,offsetY+h,offsetX+1,offsetX+w];
       %% calculate the position of the light source
        lightPosition=zeros(4,2);
        for j = 1 : total_images
            vecX=base_maxmin_point(j,1)-lightCenter(1);
            vecY=base_maxmin_point(j,2)-lightCenter(2);
            lightPosition(j,1)=lightCenter(1)+vecX*lightCircle/sqrt(vecX^2+vecY^2);
            lightPosition(j,2)=lightCenter(2)+vecY*lightCircle/sqrt(vecX^2+vecY^2); 
        end
       %% calculate light energy and light angle of each pixel with a bigger image
        angleMap_B=zeros(minR*2,minR*2,total_images*2); % angle of incidece(入射角)
        lightAngleMap=zeros(minR*2,minR*2,total_images); % main optical axis Angle(主光源角)
        lightdistanceMap=zeros(minR*2,minR*2,total_images); % distance to the light(到光源的距离)
        for j = 1 : total_images
            temp_f=(base_maxmin_point(j,2)-lightPosition(j,2))^2+(base_maxmin_point(j,1)-lightPosition(j,1))^2;
            length_f=sqrt(temp_f+lightHeight^2);
            for k=1:size(angleMap_B,1)
                for p=1:size(angleMap_B,2)
                    temp_l=(k-lightPosition(j,2))^2+(p-lightPosition(j,1))^2;
                    temp_distance=(k-base_maxmin_point(j,2))^2+(p-base_maxmin_point(j,1))^2;
                    short=sqrt(temp_l);
                    length=sqrt(temp_l+lightHeight^2);
                    angleMap_B(k,p,(j-1)*2+1)=short/length;       %sin map
                    angleMap_B(k,p,(j-1)*2+2)=lightHeight/length;    %cos map       
                    lightdistanceMap(k,p,j)=length^2;
                    lightAngleMap(k,p,j)=(length^2+length_f^2-temp_distance)/(2*length*length_f);
                end
            end  
            base_maxmin_point(j,5)=base_maxmin_point(j,3)*length_f^2;
        end
        Ep_B=zeros(minR*2,minR*2,total_images);
        for j = 1 : total_images
            Ep_B(:,:,j)=base_maxmin_point(j,5)*((lightAngleMap(:,:,j)).^10)./lightdistanceMap(:,:,j);
        end 
       %% rotate to simulate the circular distribution of point light sources
        angleMap=zeros(h,w,total_images*2); % angle of incidece(入射角)
        Ep=zeros(h,w,total_images);
        inc_theta=lightsize/(num-1);
        for j=1:total_images
            middle_img(:,:,1)=Ep_B(:,:,j);
            middle_img(:,:,2)=angleMap_B(:,:,j*2-1);
            middle_img(:,:,3)=angleMap_B(:,:,j*2);
            rotated_EpB(:,:,1)= middle_img(:,:,1);
            rotated_sin(:,:,1)= middle_img(:,:,2);
            rotated_cos(:,:,1)= middle_img(:,:,3);
            for i = 2 : num
                angle2rot=inc_theta*floor(i/2)*((-1)^i);
                rotated_img=imrotate(middle_img,angle2rot,'nearest','crop');  
                rotated_EpB(:,:,i)=rotated_img(:,:,1);
                rotated_sin(:,:,i)=rotated_img(:,:,2);
                rotated_cos(:,:,i)=rotated_img(:,:,3);
            end
            mult_EpB=mean(rotated_EpB,3,'omitnan');
            mult_sin=min(rotated_sin,[],3,'omitnan');
            mult_cos=max(rotated_cos,[],3,'omitnan');
            Ep(:,:,j)=mult_EpB(cut_rect(1):cut_rect(2),cut_rect(3):cut_rect(4));
            angleMap(:,:,j*2-1)=mult_sin(cut_rect(1):cut_rect(2),cut_rect(3):cut_rect(4));
            angleMap(:,:,j*2)=mult_cos(cut_rect(1):cut_rect(2),cut_rect(3):cut_rect(4));
        end
        
    case 'square'
        

end

end


% h = size(base_imarray,1);w = size(base_imarray,2);
% 
