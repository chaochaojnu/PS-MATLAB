%% assume that:
% the light source is parallel light and orthogonal acquisition
% The object has a Lambert surface
% but:
% the light is definitly not parallel, we will try to correct it here
% the suface could be affected by mirror surface

close all;
clear all;
%% vatiables need to be changed
%images informatiion
dataDir     = fullfile('..','data/'); % Path to your data directory
subjectName = '3'; %the name of folder
detectArea=[1,3684,800,4500]; % row and col range to detect[1,3684,800,4500][700,1100,4200,4500]
numImages   = 4; % Total images for each surface
imageDir    = fullfile(dataDir, subjectName);
integrationMethod = 'solve2'; % ways to calculate
%light source information
resolution = 0.0175; % the resolution of the camera
lightCircle = 77; % radius of the light
lightHeight = 53; % height of light
cameraHeight = 230; % height of camera
%trainsform unit mm->pixel
lightCircle=lightCircle/resolution;
lightHeight=lightHeight/resolution;
cameraHeight=cameraHeight/resolution;

%% standard images light from single direction
base_imarray=getImages(dataDir,'base_1*.jpg','standard',numImages);

%% correct light sorce
[Ep,angleMap] = lightCorrect(base_imarray,lightCircle,lightHeight,cameraHeight,'point',7,90);

%% detection images light from single direction
% Ori_imarray=zeros(h, w, numImages);
Ori_imarray=getImages(imageDir,'_Dir*.jpg','4dir',numImages);

%% ROI and per-process
[Ia,imarray] = preprocess(Ori_imarray,detectArea,30,Ep);

%% calculate the normal-vector and reflect rate of surface
for i=1:size(angleMap,3)
    temp=angleMap(:,:,i);
    temp=temp(detectArea(1):detectArea(2)-1,detectArea(3):detectArea(4)-1);
    lightCor(:,:,i)=temp;
end
[albedoImage,surfaceNormals] = getNormalVec(imarray,Ia,lightCor,'divide');

%% display curvature 
[G,h1,P1,P2] = surfcurvature2(surfaceNormals(:,:,2), surfaceNormals(:,:,1), surfaceNormals(:,:,3));
figure;subplot(2,2,1);imshow(P1, []); title('Max');
subplot(2,2,2);imshow(P2, []); title('Min');
subplot(2,2,3);imshow(h1, []); title('Average');
subplot(2,2,4);imshow(G, []); title('Gauss');

%% Compute height from normals by integration along paths
heightMap = getSurface(surfaceNormals, integrationMethod);

%% Display the output
displayOutput(albedoImage, heightMap);
plotSurfaceNormals(surfaceNormals);


