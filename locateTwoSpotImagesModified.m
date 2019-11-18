function [img1Spots, img2Spots, xyList, polygonList] = locateTwoSpotImagesModified(snakes, im1, im2)
%%Find the X and Y positions of each detected foci
%
%  Inputs : 
%           snakes : Segmentation information generated by CellStar
%           im1 : Single plane image. Usually maximum intensity projection.
%           im2 : Single plane image. Usually maximum intensity projection.
%
%   Outputs :
%           img1Spots : Matrix of spot positions of im1. Rows correspond to
%           spot while columns are Y (row) and X (column).
%
%           img2Spots: Matrix of spot positions of im2. Rows correspond to
%           spot while columns are Y (row) and X (column).
 %Instantiate img1Spots and img2Spots matrices
 img1Spots = [];
 img2Spots = [];
 xyList = {};
 polygonList = {};
 cnt = 1;
for n = 1:numel(snakes)
    inPolygon = snakes{n}.inPolygon;
    inPolygonXY = snakes{n}.inPolygonXY;
    %paddedPolygon = padPolygon(inPolygon, inPolygonXY, size(im1));
    %[noisedPolygon1, boundBox1] = cropImage(paddedPolygon, im1);
    %[noisedPolygon2, boundBox2] = cropImage(paddedPolygon, im2);
    ptSrcImg1  = advPointSourceDetection(im1, 2, 0);
    ptSrcImg2 = advPointSourceDetection(im2, 2, 0);
    if sum(ptSrcImg1(:)) == 2 && sum(ptSrcImg2(:)) == 2
        %store the inPolygonXY and inPolygon variables
        xyList{cnt} = inPolygonXY;
        polygonList{cnt} = inPolygon;
        cnt = cnt + 1;
        %pad the ptSrcImag1 back to the original image size
        %crop1XY = [ceil(boundBox1(2)), ceil(boundBox1(1))];
        %padPtImg1 = padPolygon(ptSrcImg1, crop1XY, size(im1));
        idxsImg1 = find(ptSrcImg1);
        [img1Rows, img1Cols] = ind2sub(size(ptSrcImg1), idxsImg1);
        img1SpotsInSeg = [img1Rows, img1Cols];
        img1Spots = [img1Spots; img1SpotsInSeg];
        %crop2XY = [ceil(boundBox2(2)), ceil(boundBox2(1))];
        %padPtImg2 = padPolygon(ptSrcImg2, crop2XY, size(im2));
        idxsImg2 = find(ptSrcImg2);
        [img2Rows, img2Cols] = ind2sub(size(ptSrcImg2), idxsImg2);
        img2SpotsInSeg = [img2Rows, img2Cols];
        img2Spots = [img2Spots; img2SpotsInSeg];
    end
end
