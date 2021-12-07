function [filterCell, outlierCell] = filterPosition(dataCell, spbChannel, margin)
%%filterPosition Remove cells in dataCell array whose kinetochore foci are
%%not between the min/max X and Y dimensions of the spindle pole body foci.
%
%   inputs : 
%       dataCell : The cell array outputted by aggImages function.
%
%       spbChannel : 1 or 2. Specifies which fluorescent image channel
%       contains images of the spindle pole bodies.
%
%       margin : Integer specifying the number of pixels the foci can be
%       outside the min/max X and Y dimensions of the spindle pole body
%       foci.
%
%   outputs :
%       filteredCell : A cell array containing only cells whose kinetochore
%       foci are between the min/max X and Y dimensions of the 
%       spindle pole body foci.
%
%       outlierCell : A cell array containing only cells whose kinetochore
%       foci are NOT between the min/max X and Y dimensions of the 
%       spindle pole body foci.

%% Set spbCols and kCols indices using spbChannel index
if spbChannel == 1
    spbCols = [1,2];
    kCols = [3,4];
elseif spbChannel == 2
    spbCols = [3,4];
    kCols = [1,2];
else
    error('spbChannel variable value must be 1 or 2');
end

%% Pre-allocate logical arrays
%deliberately set the first column to one to catch the label row
posArray = true([1, size(dataCell,1)]);

%% Loop over dataCell array
for n=2:size(dataCell,1)
    spb = zeros([2,2]);
    kinet = zeros([2,2]);
    for i = 1:2 % create matrix of [minY, maxY, minX, maxX] for spb foci
        spb(i,1) = min([dataCell{n,spbCols(1)}(i),...
            dataCell{n,spbCols(2)}(i)]);
        kinet(i,1) = min([dataCell{n,kCols(1)}(i),...
            dataCell{n,kCols(2)}(i)]);
        if kinet(i,1) < (spb(i,1) - margin)
            posArray(n) = 0;
        end
        spb(i,2) = max([dataCell{n,spbCols(1)}(i),...
            dataCell{n,spbCols(2)}(i)]);
        kinet(i,2) = max([dataCell{n,kCols(1)}(i),...
            dataCell{n,kCols(2)}(i)]);
        if kinet(i,2) > (spb(i,2) + margin)
            posArray(n) = 0;
        end
    end
end
%% Filter dataCell to generate filterCell and outlierCell
filterCell = dataCell(posArray, :);
outArray = ~posArray;
outArray(1) = 1;
outlierCell = dataCell(outArray,:);

    