function filterCell = filterFuzz(dataCell, spbChannel)
%filterFuzz Filter out images of SPB foci with high levels of background

%Given spindle pole body foci size should be, at most, 9x9 each, 
%anything with a binary image greater than 165 is filtered out
%% Pre-allocate logical array
keepArray = ones([size(dataCell,1), 1]);
%% Set column index based on spbChannel variable
if spbChannel == 1
    cIdx = 5;
elseif spbChannel == 2
    cIdx = 6;
else
    error('spbChannel should be either 1 or 2');
end
%% Loop over dataCell array
for n = 2:size(dataCell,1)
    imMat = dataCell{n, cIdx};
    mip = max(imMat, [], 3);
    bin = mip > multithresh(mip);
    area = sum(bin(:));
    binStruct = bwconncomp(bin);
    if area > 165 || binStruct.NumObjects ~= 2
        keepArray(n) = 0;
    end
end
filterCell = dataCell(boolean(keepArray),:);