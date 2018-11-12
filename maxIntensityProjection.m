function maxIntMatrix = maxIntensityProjection(filename)
%%Create a 3D matrix of maximum intensity projections

imCell = bfopen(filename);
maxIntMatrix = zeros([size(imCell{1,1}{1,1}), size(imCell,1)]);
for n = 1:size(imCell, 1)
    maxIntMatrix(:,:,n) = max(cat(3, imCell{n,1}{:,1}), [], 3);
end
    