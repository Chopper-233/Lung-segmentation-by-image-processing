% Chest Xray 肺部分割代码 ---李文峤，王新元
clear; close all; clc
img = imread('D:\Chopper\DIP\dataset\images\CHNCXR_0001_0.png');%读取图片灰度图像 
mask = imread('D:\Chopper\DIP\dataset\masks\CHNCXR_0001_0_mask.png');%读取label
imset=img;
%load imset % 数据集
showflag = 1; % 是否显示中间图像
imidx = 1; % 测试图像序号
 
im = im2double(imset);
mask = im2double(mask);
 
%% 1.阈值分割
% 全局分割
imbi0 = imbinarize(im);
% 基于轮廓像素分割
%Img_Edge = imgaussfilt(im,1);%高斯平滑去除噪声
%imshow(Img_Edge);
% Img_Edge1 = edge(Img_Edge,'log'); % 拉普拉斯获取边缘
Img_Edge2 = edge(im,'canny');%canny获取边缘
% Img_Edge3 = edge(Img_Edge,'prewitt');%Prewitt获取边缘
% figure
%   subplot(131),imshow(Img_Edge1);
%   subplot(132),imshow(Img_Edge2);
%   subplot(133),imshow(Img_Edge3);
E1 = im(Img_Edge2); % 获取边缘像素
E1 = E1(E1>0);%提取直方图向量
 
imbi1 = imbinarize(im,graythresh(E1));%otsu二值化

% 基于有效像素分割
E2 = im(im>0.02); % 获取非0像素
imbi2 = imbinarize(im,graythresh(E2));
 
if showflag
    figure
    subplot(221),imshow(im),title('\fontsize{16}原图')
    subplot(222),imshow(imbi0),title('\fontsize{16}全局分割')
    subplot(223),imshow(imbi1),title('\fontsize{16}基于轮廓像素分割')
    subplot(224),imshow(imbi2),title('\fontsize{16}基于有效像素分割')
end
 
 


%% 2.闭运算处理
component1=strel('disk',5);%半径为5的结构元
component2=strel('disk',10);
component3=strel('disk',14);
component11=strel('disk',10);
component12=strel('disk',15);
close1 = imclose(imbi1,component1);
close2 = imclose(imbi1,component2);
close3 = imclose(imbi1,component3);
%close = convhull(close3);
open1 = imopen(imbi1,component11);
open2 =imopen(imbi2,component12);
if showflag
   figure 
   subplot(231),imshow(imbi1)
   subplot(232),imshow(open1)
   subplot(233),imshow(open2)
   subplot(234),imshow(close1)
   subplot(235),imshow(close2)
   subplot(236),imshow(close3)
end

%% 3.提取人体部分
% 计算连通分量
[label,num] = bwlabel(close3);
Flags =zeros(num,num); 
% 剔除边缘连通分量
img_convhull = regionprops(label,'Area','FilledImage','ConvexHull','PixelIdxlist','PixelList');
areas = [img_convhull.Area];
fills = img_convhull.FilledImage;
polygons = img_convhull.ConvexHull;
%寻找最大的6个连通分量,剔除边缘连通分量
[S1,max1_id]=max(areas);
areas(max1_id) = 0;
[S2,max2_id]=max(areas);
areas(max2_id) = 0;
[S3,max3_id]=max(areas);
areas(max3_id) = 0;
[S4,max4_id]=max(areas);
areas(max4_id) = 0;
[S5,max5_id]=max(areas);
areas(max5_id) = 0;
[S6,max6_id]=max(areas);
areas(max6_id) = 0;
max_id=[max1_id,max2_id,max3_id,max4_id,max5_id,max6_id];
for i = 1:num
    if find(max_id==i)
        temp = zeros(3000);
        temp = img_convhull(i).PixelList(:,1);
        a = min(temp);
        b = max(temp);
        if (a<100||b>2900)
            j = find(max_id==i)
            max_id(j)=[];
        end
    end
end
%左肺和右肺的连通分量
M1 = max_id(1);
% lung_left_x = img_convhull(M1).ConvexHull(:,1);
% lung_left_y = img_convhull(M1).ConvexHull(:,2);
lung_left = label == M1;
M2 = max_id(2);
% lung_right_x = img_convhull(M2).ConvexHull(:,1);
% lung_right_y = img_convhull(M2).ConvexHull(:,2);
lung_right = label == M2;
%凸缺陷拟合
% lung_left_x = round(lung_left_x);
% lung_left_y = round(lung_left_y);
% lung_right_x = round(lung_right_x);
% lung_right_y = round(lung_right_y);
% lung_left = roifill(lung_left_y,lung_left_x,lung_left_temp);
% lung_right = roifill(lung_right_x,lung_right_y,lung_right_temp);
%左肺右肺填充
%lung_left = imfill(lung_left_temp,lung_leftour);
%lung_right = imfill(lung_right_temp,lung_rightour);
lung = lung_left+lung_right;
if showflag
    figure
    subplot(221),imshow(close3),title('OriImg')
    subplot(222),imshow(lung),title('ConnectAll')
    subplot(223),imshow(lung_left),title('ConnectLeft')
    subplot(224),imshow(lung_right),title('ConnectRight')
end

%剔除背景连通分量
% 计算最大连通分量
% MAX = 0;
% for k = 1:num
%     maxtmp = sum(find(label==k));
%     if maxtmp>MAX
%         IDX = k;
%         MAX = maxtmp;
%     end
% end
% imbi = label==IDX;
%  
% if showflag
%     figure
%     subplot(121),imshow(imbi1),title('\fontsize{16}二值图')
%     subplot(122),imshow(imbi),title('\fontsize{16}胸腔')
% end
 
 
%% 4.剔除空洞
% imbiFull = imfill(lung,'hole'); % 填充
% if showflag
%     figure
%     imshow(imbiFull)
% end
hole_remove1 = strel('disk',30);
hole_remove2 = strel('disk',60);
hole_remove3 = strel('disk',120);
Lung1 = imclose(lung,hole_remove1);
Lung2 = imclose(lung,hole_remove2);
Lung3 = imclose(lung,hole_remove3);
if showflag
    figure
    subplot(221),imshow(lung)
    subplot(222),imshow(Lung1)
    subplot(223),imshow(Lung2)
    subplot(224),imshow(Lung3)
end
 
%% 5.计算单张图片指标
% P = 2000;%设置连通域面积
% MASK = bwareaopen(objtmp,P,4);  % 删除面积小于P的连通分量
% if showflag
%     figure
%     subplot(131),imshow(objtmp),title('\fontsize{16}疑似肺质')
%     subplot(132),imshow(MASK),title('\fontsize{16}肺质MASK')
%     subplot(133),imshow(im),title('\fontsize{16}原图')
% end
Dice_result = dice (Lung3,mask);
output_contour = bwboundaries(Lung3);
contour_out = cat(1,output_contour);
mask_contour = bwboundaries(mask);
 
%% 5.最终结果输出
 
figure
subplot(221),imshow(im),title('\fontsize{16}原图')
subplot(222),imshow(imbi),title('\fontsize{16}胸腔')
subplot(223),imshow(objtmp),title('\fontsize{16}疑似肺质')
subplot(224),imshow(MASK),title('\fontsize{16}肺质MASK')
 

