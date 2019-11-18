function allDataCell = aggSimImages(matPattern)
%aggImages Aggreated coordinate information and filtered image stacks into
%a single cell array
%   Function loops over all the MAT files contianing the spotStructArray
%   variable and uses that stored information to parse image stacks to
%   aggregate both the coordinate information and filtered image stacks
%   into the cell array imageCell.

%% Use matPattern in to identify MAT file of interest
%% Loop through matFiles to determine proper cell array size
matFiles = dir(matPattern);
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
    for i = 1:4
        allDataCell{cnt,i} = spotStructArray.dataCell{2,i};
    end
    allDataCell{cnt,5} = stack1;
    allDataCell{cnt,6} = stack2;
    cnt = cnt + 1;
end
%% Close waitbar
close(h);
end
