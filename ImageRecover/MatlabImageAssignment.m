clc; clear all;
%First part
%reading img1, saving as im1 variable
im1 = imread('img1.jpg');
%for boundary it's a must to convert to gray
im1 = rgb2gray(im1);
subplot(331), imshow(im1), title('Img1 convert to gray');
% as a mask all colors will be white or black
mask = im1 < 255;
subplot(332), imshow(mask), title('Apply a mask');
%invert colors, otherwise the boundary sees nearly
%the whole image, need to swap colors
mask = imcomplement(mask);
subplot(333), imshow(mask), title('Invert colors');
%gives location x y coordinates where is the first area, 
%it starts there too
%if don't have ; at the end, it shows the dimensions of 
%the image
dim = size(mask)
col = round(dim(2)/2)-90;
row = min(find(mask(:,col)))

%an interesting drawback, if I would fill the "holes"
%with erode function which is better then imfill, the
%program can't see any of the boundaries, hence in the
%for loop I had to use 180 rounds, otherwise can't see
%the big parts.
%erode image
% se = strel('line',10, 90);
% boundaries = imerode(mask,se);
% imshow(boundaries);

%use bwtraceboundary function to find the boundary from
%the above declared point.
%it needs a binary image, row and col coordinates for start
%and direction, W for west so left.
boundary = bwtraceboundary(mask,[row, col],'W');
subplot(334), imshow(im1), title('Boundaries');
hold on;
plot(boundary(:,2),boundary(:,2),'g','LineWidth',4);
%the imfill fills the smaller objects. However, as I 
%mentioned above the erode function does better job.
%Unfortunately, with that result the for loop cannot
%find any boundaries, despite the imshow(mask)black&white
%image looks better.
BW_filled = imfill(mask,'holes');
boundaries = bwboundaries(BW_filled);
%shows the border of all white part, with the imfill
%function the for loop must iterate 180 times, hilarious.
%Under 180 it doesn't find the last top right big white
%object.
for k=1:180
   b = boundaries{k};
   plot(b(:,2),b(:,1),'g','LineWidth',4);
end

%Second part
%denoise test; averaging or median filter
im2 = imread('img2.jpg');
im2 = imresize(im2, [768, 1024]);
rgbImage = im2;
subplot(335), imshow(rgbImage), title('Resized but noisy Img2');
%averaging filter
mat = ones(5,5)/25;
averagingFilter_im2 = imfilter(rgbImage, mat);
subplot(336), imshow(averagingFilter_im2), title('Img2 averaging filter');

%median filter
for k=1:3
medianFilter_im2(:,:,k)=medfilt2(rgbImage(:,:,k),[3,3]);
end
subplot(337), imshow(medianFilter_im2), title('Img2 median filter');

%Third part
im1 = imread('img1.jpg');
recoveredImage = im1;
recoveredImageMedianFilter = im1;

zero = recoveredImage == 255;
recoveredImage(zero) = averagingFilter_im2(zero);

zero1 = recoveredImageMedianFilter == 255;
recoveredImage(zero1) = averagingFilter_im2(zero1);
recoveredImageMedianFilter(zero1) = medianFilter_im2(zero);

subplot(338), imshow(recoveredImage), title('Recovered image with averaging filter');
subplot(339), imshow(recoveredImageMedianFilter), title('Recovered image with median filter');
%Compare recoveredImage and originalImage
originalImage = imread('Penguins.jpg');
%Writes out in command window
meanRecoveredIm = mean(recoveredImage(:))
meanOriginalIm = mean(originalImage(:))
%It coutns the Structural Similarity Index (SSIM) value
%for original and recovered image.
ssimValue = ssim(originalImage, recoveredImage)
%It counts the Peak Signal to Noise Ratio value
%for original and recovered image. They must be the same
%class and size as well.
peaks2NoiseRatio = psnr(originalImage, recoveredImage)
%It counts the Mean Squared Error (MSE) between arrays
%of the 2 declared variable, currently the original and the recovered image.
meanSquaredErr = immse(originalImage, recoveredImage)

%write out image as a file
imwrite(recoveredImage, 'recoveverdImage.jpg');


