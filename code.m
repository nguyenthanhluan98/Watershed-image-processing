%STEP 1: Insert the original image as input.
img = dicomread('img0001.dcm');
figure, imshow(img, []), title('Original image');

%STEP 2: Convert the image into gray scale.
if  size(img, 3) == 1
    disp('grayscale image');
else
    disp('this is a grayscal image');
end
%STEP 3: Find out the gradient magnitude.
[Gx, Gy] = imgradientxy(img, 'prewitt');
[Gmag, Gdir] = imgradient(Gx, Gy);

%imshowpair(Gmag, Gdir, 'montage');
%figure, imshow(Gmag, []), title('Gmag')

L = watershed(Gmag);
Lrgb = label2rgb(L);
%watershed thu?t toán tìm catchment basins, ridge lines, tách ??i t??ng
%kh?i background
%figure, imshow(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)')
%STEP 4: Mark the foreground objects.

se = strel('disk', 15);
Io = imopen(img, se);
%figure
%imshow(Io, []), title('Opening (Io)')

Ie = imerode(img, se);
Iobr = imreconstruct(Ie, img);
%figure
%imshow(Iobr, []), title('Opening-by-reconstruction (Iobr)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr); 
figure
imshow(Iobrcbr, []), title('Opening-closing by reconstruction (Iobrcbr)')

level = graythresh(Iobrcbr);
disp('level 1: ');
disp(level);

fgm = imregionalmax(Iobrd); % find the regional maxima: tìm vùng c?c ??i, bi?n ??i các vùng xung quanh --> lower pixel
%figure
%imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')


se2 = strel(ones(5, 5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
fgm4 = bwareaopen(fgm3, 0); % remove all pixel 0
I3 = img;
I3(fgm4) = 255;
%figure
%imshow(I3, [])     
%title('Modified regional maxima superimposed on original image (fgm4)')


%STEP 5: Mark the background objects.
bw = imbinarize(I3, 0.50100000000000000000000001);
%0.50022222211111
figure, imshow(bw), title('Thresholded Opening-Closing by Reconstruction');


D = bwdist(bw);
DL = watershed(D);
DL(~bw) = 0;
bgm = DL == 0;
figure, imshow(bgm), title('Watershed Ridge Lines)');

%STEP 6: Estimate the watershed transform


labels = imdilate(L == 0,ones(3,3)) + 2*bgm + 3*fgm4;
I4 = labeloverlay(img,labels);
figure, imshow(I4), title('Markers and Object Boundaries Superimposed on Original Image');

Lrgb = label2rgb(L);
%figure, imshow(Lrgb, []), title('Colored Watershed Label Matrix')


figure
imshow(img)
hold on
himage = imshow(Lrgb, []);
himage.AlphaData = 0.3;
title('Colored Labels Superimposed Transparently on Original Image')

