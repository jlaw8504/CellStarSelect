function noisedPolygon = noisePolygon(filteredPolygon)
%%This function uses the mean and std of the image to noise the image where
%%the intensity value equals zero

nanPolygon = filteredPolygon;
nanPolygon(filteredPolygon == 0) = nan;
%threshold the image
thresh = multithresh(nanPolygon);
%parse the intensity values from nanPolygon
ints = nanPolygon(~isnan(nanPolygon));
%threshold ints
bg_ints = ints(ints < thresh);
bgMean = mean(bg_ints);
bgStd = std(bg_ints)/1.5;
noiseImage = floor(bgMean*0.8) +...
    floor(bgStd*randn(size(filteredPolygon)));
noiseMask = noiseImage .* isnan(nanPolygon);
noisedPolygon = noiseMask + filteredPolygon;