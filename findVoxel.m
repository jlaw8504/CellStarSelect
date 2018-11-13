function [Y,X,plane,peakIntensity] = findVoxel(spotYX, imgStack, regionSize)
%findVoxel Find the brightest voxel of region surrounding a given spot
%
%   Inputs : 
%       spotYX : Array containing Y and X coordinate of spot
%
%       imgStack : A three-dimensional matrix composed of image planes
%
%       regionSize : An integer specifying the size of the square region
%       that will be used to search for the brightest voxel.
%
%   Outputs :
%       Y : Y coordinate (row)
%
%       X : X coordinate (column)
%
%       plane: Plane coordinate (3rd dimension)
%
%       peakIntensity: Intensity value of brightest voxel

%% Create binary image to wipe out all other regions of image
binaryStack = zeros(size(imgStack));
halfRS = (regionSize-1)/2;
binaryStack(spotYX(1)-halfRS:spotYX(1)+halfRS,... %first dimension
          spotYX(2)-halfRS:spotYX(2)+halfRS,... %second dimension
          :)... %third dimension
          = 1;
filterStack = binaryStack .* imgStack;

end