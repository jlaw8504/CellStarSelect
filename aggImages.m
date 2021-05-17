function allDataCell = aggImages(matPattern)
%aggImages Aggreated coordinate information and filtered image stacks into
%a single cell array
%   Function loops over all the MAT files contianing the spotStructArray
%   variable and uses that stored information to parse image stacks to
%   aggregate both the coordinate information and filtered image stacks
%   into the cell array imageCell.

%% Use matPattern in to identify MAT file of interest
matFiles = dir(matPattern);
%% Loop through matFiles to determine proper cell array size
num = 0;
for n = 1:numel(matFiles)
    fullFilename = fullfile(matFiles(n).folder, matFiles(n).name);
    load(fullFilename, 'spotStructArray');
    dataCell = spotStructArray.dataCell;
    dataNum = size(dataCell,1) - 1;
    num = num + dataNum;
end
%% Create allDataCell array
allDataCell = cell([num + 1, size(spotStructArray.dataCell,2)]); % +1 is for label row
allDataCell(1,:) = spotStructArray.dataCell(1,:);
allDataCell(1,5) = {'subStack1'};
allDataCell(1,6) = {'subStack2'};
allDataCell(1,7) = {'subTrans'};
%% Loop through all files again to place the data in allDataCell
%instantiate counter
cnt = 2; % to prevent label row overwrite
%% Waitbar
h = waitbar(0, 'Parsing MAT files and images now');
for n = 1:numel(matFiles)
    fullFilename = fullfile(matFiles(n).folder, matFiles(n).name);
    load(fullFilename, 'spotStructArray');
    %% Load in the GFP, RFP and Trans Stacks
    stack1 = readTiffStack(fullfile(spotStructArray.rootDir, spotStructArray.stack1Filename));
    stack2 = readTiffStack(fullfile(spotStructArray.rootDir, spotStructArray.stack2Filename));
    trans = readTiffStack(fullfile(spotStructArray.rootDir, spotStructArray.transFilename));
    for i = 1:(size(spotStructArray.dataCell,1)-1)
        allDataCell(cnt,1:4) = spotStructArray.dataCell(i+1,:);
        %Trans image plan index, AKA zstack index
        polyIdx = ceil(allDataCell{cnt,1}(3)/spotStructArray.zsteps);
        %Pull out all xyPolys and inPolys for that zstack index
        xyPoly = spotStructArray.xyList{i};
        inPoly = spotStructArray.polygonList{i};
        %% Create 3D filter
        %padPoly = padPolygon(inPoly, xyPoly, size(stack1(:,:,1)));
        %stackPoly = repmat(padPoly, [1,1,spotStructArray.zsteps]);
        planes = ((polyIdx-1)*spotStructArray.zsteps)+1:...
            polyIdx*spotStructArray.zsteps;
        %% Crop images
        %zStack1 = stack1(:,:,planes) .* stackPoly;
        subStack1 = stack1(xyPoly(1):xyPoly(1)+size(inPoly,1)-1,...
            xyPoly(2):xyPoly(2)+size(inPoly,2)-1,planes);
        %zStack2 = stack2(:,:,planes) .* stackPoly;
        subStack2 = stack2(xyPoly(1):xyPoly(1)+size(inPoly,1)-1,...
            xyPoly(2):xyPoly(2)+size(inPoly,2)-1,planes);
        %subTrans = trans(:,:,polyIdx) .* padPoly;
        subTrans = trans(xyPoly(1):xyPoly(1)+size(inPoly,1)-1,...
            xyPoly(2):xyPoly(2)+size(inPoly,2)-1, polyIdx);
        %% Correct addDataCell Coordinates
        for j = 1:4
            newCoords = allDataCell{cnt,j} - ...
                [xyPoly(1)-1, ...
                xyPoly(2)-1, ...
                ((polyIdx -1 ) * spotStructArray.zsteps),...
                0];
            allDataCell(cnt,j) = {newCoords};
        end
        allDataCell{cnt,5} = subStack1;
        allDataCell{cnt,6} = subStack2;
        allDataCell{cnt,7} = subTrans;
        cnt = cnt +1;
        waitbar(cnt/num);
    end
end
%% Close waitbar
close(h);
end
