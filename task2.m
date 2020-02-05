video = VideoReader('targetVideo.MP4');
I_cover = imread('newcover.jpg'); 
framenum = 408;%10帧读一张的话有40张
I_last = read(video,15);
colors = ['r','g','b','y','k','w','c','m'];
x = [60 667 780 76]';
y =  [150 106 804 894]';
changecover(I_last, I_cover, x, y);
hold on;
color = 'g';
line(x,y,'color',color,'LineWidth',3);
line([x(1),x(4)],[y(1),y(4)],'color',color,'LineWidth',3);
for k = 2:40
    I_now = read(video,k*10);  
    [x,y] = surfImageRegistration(I_last,I_now,x,y);
    changecover(I_now, I_cover, x, y);
    hold on;
    color = colors(mod(k,8)+1);
    line(x,y,'color',color,'LineWidth',3);
    line([x(1),x(4)],[y(1),y(4)],'color',color,'LineWidth',3);
    I_last = I_now;
end

% SURF得到新的四个边界点
function [x_now,y_now]=surfImageRegistration(I_last,I_now,x_last,y_last) 
I_last = rgb2gray(I_last);
I_now = rgb2gray(I_now);
% 检测特征点并提取
P_last = detectSURFFeatures(I_last);
P_now = detectSURFFeatures(I_now);
[f_last,p_last] = extractFeatures(I_last, P_last);
[f_now,p_now] = extractFeatures(I_now, P_now);
matchpairs = matchFeatures(f_last,f_now);
%得到变化矩阵并作用上去
[tform,~,~]=estimateGeometricTransform( p_last(matchpairs(:,1),:), p_now(matchpairs(:,2),:),'projective'); 
[x_now,y_now] = transformPointsForward(tform,x_last,y_last);
end

%换封面，手用hsv的h来解决
function changecover(I,I_cover,x,y)
[m,n,~] = size(I_cover);
x_cover = [1 n n 1]';
y_cover = [1 1 m m]';
tform = fitgeotrans([x_cover y_cover],[x y],'projective');
src_registered = imwarp(I_cover,tform,'OutputView',imref2d(size(I)));
cover_mask = sum(src_registered,3)~=0;
I_af = I;
N = size(I,1)*size(I,2);
idx = find(cover_mask);
I_af(idx) = src_registered(idx);
I_af(idx + N) = src_registered(idx+N);
I_af(idx + 2 * N) = src_registered(idx + 2 * N);
% 已经换好封面，再给手弄回去,其实给绿书弄掉就行
I_hsv = rgb2hsv(I);
D1 = (I_hsv(:,:,1) - 1).^2;
mask1 = D1<0.05;
D2 = (I_hsv(:,:,1) - 0).^2;
mask2 = D2<0.05;
mask = mask1|mask2;
index = find(mask);
I_af(index) = I(index);
I_af(index + N) = I(index + N);
I_af(index + 2 * N) = I(index + 2 * N);
imshow(I_af);
end




