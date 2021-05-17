function displayFilteredSnakes(snakes, im1, im2)
%%This function loops through all the segmenents in the structured array
%%snakes and displays the noisedPolygon images of each segement of the
%%image provided after removing images without two spots.

for n = 1:numel(snakes)
    inPolygon = snakes{n}.inPolygon;
    inPolygonXY = snakes{n}.inPolygonXY;
    paddedPolygon = padPolygon(inPolygon, inPolygonXY, size(im1));
    [noisedPolygon1, ~] = cropImage(paddedPolygon, im1);
    [noisedPolygon2, ~] = cropImage(paddedPolygon, im2);
    ptSrcImg1  = advPointSourceDetection(noisedPolygon1, 2, 0);
    ptSrcImg2 = advPointSourceDetection(noisedPolygon2, 2, 0);
    if sum(ptSrcImg1(:)) == 2 && sum(ptSrcImg2(:)) == 2
        %pad the ptSrcImag1 back to the original image size
        idxsImg1 = find(ptSrcImg1);
        [img1Rows, img1Cols] = ind2sub(size(ptSrcImg1), idxsImg1);
        idxsImg2 = find(ptSrcImg2);
        [img2Rows, img2Cols] = ind2sub(size(ptSrcImg2), idxsImg2);
        subplot(1,2,1);
        imshow(noisedPolygon1, []);
        hold on;
        scatter(img1Cols, img1Rows, 'go');
        hold off;
        title('GFP Image')
        subplot(1,2,2);
        imshow(noisedPolygon2, []);
        hold on;
        scatter(img2Cols, img2Rows, 'rx');
        hold off;
        title('RFP Image')
        waitforbuttonpress;
        close all;
    end
end