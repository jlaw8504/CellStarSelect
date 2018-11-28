function allDataCell = aggMats(matPattern)
%aggMats Aggregate dataCell variable from MAT files contianing the
%spotStructArray
%   Function uses MATLAB's recursive dir file search (2016b and newer) to
%   parse MAT files and aggregate the spotStructArray.dataCell cell array
%   into a single cell array.
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
%% Loop through all files again to place the data in allDataCell
%instantiate counter
cnt = 2; % to prevent label row overwrite
for n = 1:numel(matFiles)
    fullFilename = fullfile(matFiles(n).folder, matFiles(n).name);
    load(fullFilename, 'spotStructArray');
    for i = 1:(size(spotStructArray.dataCell,1)-1)
        allDataCell(cnt,:) = spotStructArray.dataCell(i+1,:);
        cnt = cnt +1;
    end
end