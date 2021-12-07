function all_data_cell = agg_mats(matPattern)
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
    load(fullFilename, 'spot_struct_array');
    dataCell = spot_struct_array.data_cell;
    dataNum = size(dataCell,1) - 1;
    num = num + dataNum;
end
%% Create allDataCell array
all_data_cell = cell([num + 1, size(spot_struct_array.data_cell,2)]); % +1 is for label row
all_data_cell(1,:) = spot_struct_array.data_cell(1,:);
%% Loop through all files again to place the data in allDataCell
%instantiate counter
cnt = 2; % to prevent label row overwrite
for n = 1:numel(matFiles)
    fullFilename = fullfile(matFiles(n).folder, matFiles(n).name);
    load(fullFilename, 'spot_struct_array');
    for i = 1:(size(spot_struct_array.data_cell,1)-1)
        all_data_cell(cnt,:) = spot_struct_array.data_cell(i+1,:);
        cnt = cnt +1;
    end
end