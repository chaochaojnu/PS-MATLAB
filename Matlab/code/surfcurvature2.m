%% calculate direct from surface normalization
function   [K,H,Pmax,Pmin] = surfcurvature2(dx,dy,dz)
% K AND H ARE THE GAUSSIAN AND MEAN CURVATURES, RESPECTIVELY.
% Pmax AND Pmin ARE THE MINIMUM AND MAXIMUM CURVATURES AT EACH POINT, RESPECTIVELY.
% d1,d2 ARE THE MAIN DIRECTIONS

[hgt, wid] = size(dz);
[X,Y] = meshgrid(1:wid, 1:hgt);
% First Derivatives
[Xu,Xv] = gradient(X);
[Yu,Yv] = gradient(Y);
Zu = -dx./dz;
Zv = -dy./dz;
Zu(isnan(Zu))=0;Zu(isinf(Zu))=0;
Zv(isnan(Zv))=0;Zv(isinf(Zv))=0;
% zero_h=zeros(1,wid);
% zero_w=zeros(hgt,1);
% added_h_y=[zero_h;dy];
% added_h_z=[zero_h;dz];
% added_w_x=[zero_w dx];
% added_w_z=[zero_w dz];
% cutted_x=added_w_x(1:hgt,1:wid);
% cutted_y=added_h_y(1:hgt,1:wid);
% cutted_h_z=added_h_z(1:hgt,1:wid);
% cutted_w_z=added_w_z(1:hgt,1:wid);
% Zu = (dx./dz+cutted_x./cutted_w_z);
% Zv = (dy./dz+cutted_y./cutted_h_z);

% Second Derivatives
[Xuu,Xuv] = gradient(Xu);
[Yuu,Yuv] = gradient(Yu);
[Zuu,Zuv] = gradient(Zu);

[Xuv,Xvv] = gradient(Xv);
[Yuv,Yvv] = gradient(Yv);
[Zuv,Zvv] = gradient(Zv);

% Reshape 2D Arrays into Vectors
Xu = Xu(:);   Yu = Yu(:);   Zu = Zu(:); 
Xv = Xv(:);   Yv = Yv(:);   Zv = Zv(:); 
Xuu = Xuu(:); Yuu = Yuu(:); Zuu = Zuu(:); 
Xuv = Xuv(:); Yuv = Yuv(:); Zuv = Zuv(:); 
Xvv = Xvv(:); Yvv = Yvv(:); Zvv = Zvv(:); 

Xu          =   [Xu Yu Zu];
Xv          =   [Xv Yv Zv];
Xuu         =   [Xuu Yuu Zuu];
Xuv         =   [Xuv Yuv Zuv];
Xvv         =   [Xvv Yvv Zvv];

% First fundamental Coeffecients of the surface (E,F,G)
E           =   dot(Xu,Xu,2);
F           =   dot(Xu,Xv,2);
G           =   dot(Xv,Xv,2);

m           =   cross(Xu,Xv,2);
p           =   sqrt(dot(m,m,2));
n           =   m./[p p p]; 

[s,t] = size(dz);

% [nu,nv] = gradient(reshape(n,s,t,3));
% Nu = reshape(nu,[],3);
% Nv = reshape(nv,[],3);

% Second fundamental Coeffecients of the surface (L,M,N)
L           =   dot(Xuu,n,2);
M           =   dot(Xuv,n,2);
N           =   dot(Xvv,n,2);

% Gaussian Curvature
K = (L.*N - M.^2)./(E.*G - F.^2);
K = reshape(K,s,t);

% Mean Curvature
H = (E.*N + G.*L - 2.*F.*M)./(2*(E.*G - F.^2));
H = reshape(H,s,t);

% Principal Curvatures
Pmax = H + sqrt(H.^2 - K);
Pmin = H - sqrt(H.^2 - K);
end
