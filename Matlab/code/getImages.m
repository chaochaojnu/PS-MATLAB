function images = getImages(path,suffix,getflag,imgnum)
%GETIMAGES read in images from given folder
%
% Input:
%   path--the path of images
%   suffix--image names
%   getflag--read in 'full' or '4dir' or 'standard' image(s)
%   imgnum--number of the image you want to get(supposed 4)
%
% Output:
%   h--the height of images('full' only)
%   w--the width of images('full' only)
%   images--images read in

filename = fullfile(path, suffix);
d = dir(filename);
filenames = {d(:).name};
total_images = numel(filenames);
if total_images ~= imgnum
    error('Total available images is not specified.\n wanted %d but get %d images.\n', imgnum,total_images)
end
switch getflag
    case 'full'
        %light from all direction
        allDirection=imread(fullfile(path,filenames{1}));
        image_size=size(allDirection);
        dimension=numel(image_size);
        if dimension==2
            gray=allDirection;
        elseif dimension==3
            gray=rgb2gray(allDirection);
        else
            error('%s','unkonwn image format');
        end
        images=double(gray);
%         [h, w] = size(images);
    
    case '4dir'
        %light from one single direction of 4
        for j = 1 : total_images
            m = findstr(filenames{j},'Dir')+3;
            Ang = str2num(filenames{j}(m:(m+3)));
            singleDirection=imread(fullfile(path,filenames{j}));
            image_size=size(singleDirection);
            dimension=numel(image_size);
            if dimension==2
                singleDirection_gray=singleDirection;
            elseif dimension==3
                singleDirection_gray=rgb2gray(singleDirection);
            else
                error('%s','unkonwn image format');
            end
            images(:,:,(Ang/90+1)) = double(singleDirection_gray);
        end
%         [h, w,~] = size(images);
        
     case 'standard'
       % standard images, light from single direction    
        for j = 1 : total_images
        	m = findstr(filenames{j},'_1_')+3;
        	Ang = str2num(filenames{j}(m:(m+3)));
        	singleDirection=imread(fullfile(path,filenames{j}));
            image_size=size(singleDirection);
            dimension=numel(image_size);
            if dimension==2
                singleDirection_gray=singleDirection;
            elseif dimension==3
                singleDirection_gray=rgb2gray(singleDirection);
            else
                error('%s','unkonwn image format');
            end
        	images(:,:,(Ang/90+1)) = double(singleDirection_gray);
        end
%         [h, w,~] = size(images);
end


end

