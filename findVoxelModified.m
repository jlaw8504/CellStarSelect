function [Y,X,plane,peakIntensity] = findVoxelModified(spotYX, imgStack, regionSize)
%findVoxel Find the brightest voxel of region surrounding a given spot
%
%   Inputs :
%       spotYX : Array containing Y and X coordinate of spot
%
%       imgStack : A three-dimensional matrix composed of image planes
%
%       regionSize : An odd integer specifying the side length of the
%       square region to be used to search for the brightest voxel.
%
%   Outputs :
%       Y : Y coordinate (row)
%
%       X : X coordinate (column)
%
%       plane: Plane coordinate (3rd dimension)
%
%       peakIntensity: Intensity value of brightest voxel

%% Determine half size of region
if mod(regionSize,2) == 0
    error('Variable regionSize must be an odd integer');
else
    halfRS = (regionSize-1)/2;
end
%% check that indexed region will be within orignal image bounds
if spotYX(1) - halfRS < 1
    spotYX(1) = spotYX(1) + (1-spotYX(1) + halfRS);
end
if spotYX(2) - halfRS < 1
    spotYX(2) = spotYX(2) + (1-spotYX(2) + halfRS);
end
if spotYX(1) + halfRS < 1
    spotYX(1) = spotYX(1) - (spotYX(1) + halfRS - size(imgStack,1));
end
if spotYX(2) + halfRS < 1
    spotYX(2) = spotYX(2) - (spotYX(2) + halfRS - size(imgStack,2));
end
%Crop out a region surrounding the indicated pixel
cropStack = imgStack(spotYX(1)-halfRS:spotYX(1)+halfRS,... %first dimension
        spotYX(2)-halfRS:spotYX(2)+halfRS,... %second dimension
        :); %third dimension
[peakIntensity, idx] = max(cropStack(:));
[Ycrop, Xcrop, plane] = ind2sub(size(cropStack), idx);
%convert back to original image coordinates
Y = Ycrop + spotYX(1)-halfRS-1;
X = Xcrop + spotYX(2)-halfRS-1;
%validate crop correction
if cropStack(Ycrop, Xcrop, plane) ~= imgStack(Y,X,plane)
    error('Crop correction failed!')
end
end