function displaySnakesWithTwo(snakes, im1, im2)
%%This function loops through all the segmenents in the structured array
%%snakes and displays the noisedPolygon images of each segement of the
%%image provided.

for n = 1:numel(snakes)
    inPolygon = snakes{n}.inPolygon;
    inPolygonXY = snakes{n}.inPolygonXY;
    paddedPolygon = padPolygon(inPolygon, inPolygonXY, size(im1));
%     filteredPolygon1 = filterPolygon(paddedPolygon, im1);
%     filteredPolygon2 = filterPolygon(paddedPolygon, im2);
%     noisedPolygon1 = noisePolygon(filteredPolygon1);
%     noisedPolygon2 = noisePolygon(filteredPolygon2);
    noisedPolygon1 = cropImage(paddedPolygon, im1);
    noisedPolygon2 = cropImage(paddedPolygon, im2);
    ptSrcImg1  = advPointSourceDetection(noisedPolygon1, 2, 0);
    ptSrcImg2 = advPointSourceDetection(noisedPolygon2, 2, 0);
    if sum(ptSrcImg1(:)) == 2 && sum(ptSrcImg2(:)) == 2
        subplot(2,2,1);
        imshow(noisedPolygon1, []);
        title('GFP Image')
        subplot(2,2,2);
        imshow(noisedPolygon2, []);
        title('RFP Image')
        subplot(2,2,3);
        imshow(ptSrcImg1);
        title('GFP Spot Detection');
        subplot(2,2,4);        
        imshow(ptSrcImg2);
        title('RFP Spot Detection');
        waitforbuttonpress;
        close all;
    end
end