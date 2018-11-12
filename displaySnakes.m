function displaySnakes(snakes, im)
%%This function loops through all the segmenents in the structured array
%%snakes and displays the noisedPolygon images of each segement of the
%%image provided.

for n = 1:numel(snakes)
    inPolygon = snakes{n}.inPolygon;
    inPolygonXY = snakes{n}.inPolygonXY;
    paddedPolygon = padPolygon(inPolygon, inPolygonXY, size(im));
    filteredPolygon = filterPolygon(paddedPolygon, im);
    noisedPolygon = noisePolygon(filteredPolygon);
    ptSrcImg  = advPointSourceDetection(noisedPolygon, 2, 0);
    subplot(1,2,1);
    imshow(noisedPolygon, []);
    subplot(1,2,2);
    imshow(ptSrcImg);
    title(num2str(n));
    waitforbuttonpress;
    close all;
end