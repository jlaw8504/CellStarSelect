function fociIm = extractFoci(spotCoords, imStack, regionSize)
%%extractFoci Parses the foci out of the given image stack based on the
%%spotCoords variable array.

if mod(regionSize, 2) == 1
    hrs = (regionSize - 1)/2;
    padStack = padarray(imStack, [hrs, hrs], 'both');
    spotCoords(1:2) = spotCoords(1:2) + hrs;
    fociIm = padStack(spotCoords(1)-hrs:spotCoords(1)+hrs,...
                     spotCoords(2)-hrs:spotCoords(2)+hrs,...
                     spotCoords(3));
else
    error('The regionSize should be an odd number');
end