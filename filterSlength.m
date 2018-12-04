function filteredCell = filterSlength(dataCell, spbChannel, spindleBounds, zTilt, pixelSize)
%filterSlength Filter a cell array produced by CellStarSelect pipeline
%based on spindle length
%   Inputs :
%       dataCell : The cell array outputted by aggImages function
%
%       spbChannel : Integer specifying which chanell in the dataCell
%       variable contains images of the spindle pole bodies (SPBs).
%
%       spindleBounds : Vector containing the [min max] spindle lengths you
%       wish to collect. Note spindle length is calculated using X and Y
%       dimensions only.
%
%       zTilt : Integer specifying how many zPlanes the SPBs can be
%       separated by.
%
%       pixelSize : The size of a pixel in nanometers.
%
%   Outputs :
%       filteredCell : A cell array filtered by the input criteria.

%% Calculate the 2D spindle lengths
%set columns to parse from spbChannel
if spbChannel == 1
    cols = [1,2];
elseif spbChannel == 2
    cols = [3,4];
else
    error('spbChannel variable value must be 1 or 2');
end
%pre-allocate logical arrays, deliberately set the first column to one to
%catch the labels row
tiltArray = ones([1, size(dataCell,1)]);
distArray = ones([1, size(dataCell,1)]);
for n=2:size(dataCell,1)
    subArray = dataCell{n,cols(1)} - dataCell{n, cols(2)};
    tiltArray(n-1) = subArray(3) <= zTilt;
    distance = norm(subArray(1:2)) * pixelSize;
    distArray(n-1) = distance >= spindleBounds(1) & distance <= spindleBounds(2);
end
filterArray = tiltArray & distArray;
filteredCell = dataCell(filterArray,:);