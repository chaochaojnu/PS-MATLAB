function displayOutput(albedo, height)
% some cosmetic transformations to display&make 3D model look better
%   % NOTE: h x w is the size of the input images
% albedo: h x w matrix of albedo 
% height: h x w matrix of surface heights



[hgt, wid] = size(height);
[X,Y] = meshgrid(1:wid, 1:hgt);
% H = flipud(fliplr(height));
% A = flipud(fliplr(albedo));

figure;
subplot(1,2,1);imshow(albedo,[]);title('Albedo');
subplot(1,2,2);imshow(height,[]);title('Height Map');

figure;
% H=rescale(H,0,1000);
% mesh(H, X, Y, A);
mesh(height);
axis equal;
xlabel('X')%xlabel('Z')
ylabel('Y')%ylabel('X')
zlabel('Z')%zlabel('Y')
title('Height Map')

% Set viewing direction
% view(-60,20)
% colormap(gray)
set(gca, 'XDir', 'reverse')
set(gca, 'XTick', []);
set(gca, 'YTick', []);
set(gca, 'ZTick', []);

% Calculate the surface DIRECTIONS
[k,h1,P1,P2,D1,D2] = surfcurvature(X, Y, height);
figure;
subplot(2,2,1);imshow(P1, []); title('Max');
subplot(2,2,2);imshow(P2, []); title('Min');
subplot(2,2,3);imshow(h1, []); title('Average');
subplot(2,2,4);imshow(k, []); title('Gauss');
end
