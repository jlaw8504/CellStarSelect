function count = countTwoSpotImages(snakes, im1, im2)
%%This function loops through all the segmenents in the structured array
%%snakes and displays the noisedPolygon images of each segement of the
%%image provided.

%Instantiate count
count = 0;

for n = 1:numel(snakes)
    inPolygon = snakes{n}.inPolygon;
    inPolygonXY = snakes{n}.inPolygonXY;
    paddedPolygon = padPolygon(inPolygon, inPolygonXY, size(im1));
    noisedPolygon1 = cropImage(paddedPolygon, im1);
    noisedPolygon2 = cropImage(paddedPolygon, im2);
    ptSrcImg1  = advPointSourceDetection(noisedPolygon1, 2, 0);
    ptSrcImg2 = advPointSourceDetection(noisedPolygon2, 2, 0);
    if sum(ptSrcImg1(:)) == 2 && sum(ptSrcImg2(:)) == 2
        count = count + 1;
    end
end
