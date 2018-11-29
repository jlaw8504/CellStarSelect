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
    idx = 1; %index for snakes(binary masks) in single trans image
    for i = 1:(size(spotStructArray.dataCell,1)-1)
        allDataCell(cnt,1:4) = spotStructArray.dataCell(i+1,:);
        polyIdx = ceil(allDataCell{cnt,1}(3)/spotStructArray.zsteps);
        xyPolyList = spotStructArray.xyList{polyIdx};
        inPolyList = spotStructArray.polygonList{polyIdx};
        try %Catch an indexing error when polyIdx changes to reset idx to 1
            xyPoly = xyPolyList{idx}; %error since idx is automatically 2 to start, need to flip this around?
            inPoly = inPolyList{idx};
            idx = idx + 1;
        catch
            idx = 1;
            xyPoly = xyPolyList{idx};
            inPoly = inPolyList{idx};
        end
        %% Create 3D filter
        padPoly = padPolygon(inPoly, xyPoly, size(stack1(:,:,1)));
        stackPoly = repmat(padPoly, [1,1,spotStructArray.zsteps]);
        planes = ((polyIdx-1)*spotStructArray.zsteps)+1:...
            polyIdx*spotStructArray.zsteps;
        %% Filter and crop images
        zStack1 = stack1(:,:,planes) .* stackPoly;
        subStack1 = zStack1(xyPoly(1):xyPoly(1)+size(inPoly,1)-1,...
            xyPoly(2):xyPoly(2)+size(inPoly,2)-1,:);
        zStack2 = stack2(:,:,planes) .* stackPoly;
        subStack2 = zStack2(xyPoly(1):xyPoly(1)+size(inPoly,1)-1,...
            xyPoly(2):xyPoly(2)+size(inPoly,2)-1,:);
        subTrans = trans(:,:,polyIdx) .* padPoly;
        subTrans = subTrans(xyPoly(1):xyPoly(1)+size(inPoly,1)-1,...
            xyPoly(2):xyPoly(2)+size(inPoly,2)-1);
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
        h = waitbar(cnt-1/num);
    end
end
%% Close waitbar
close(h);
end
