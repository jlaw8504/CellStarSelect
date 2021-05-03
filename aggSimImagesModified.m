function allDataCell = aggSimImagesModified(mat_pattern)
%aggImagesModified Aggreated coordinate information and filtered image stacks into
%a single cell array
%   Function loops over all the MAT files contianing the spotStructArray
%   variable and uses that stored information to parse image stacks to
%   aggregate both the coordinate information and filtered image stacks
%   into the cell array imageCell.

%% determine proper cell array size
files = dir(mat_pattern);
%% Create allDataCell array
allDataCell(1,:) = {'Spot 1 Channel 1','Spot 2 Channel 1','Spot 1 channel 2','Spot 2 Channel 2'};
allDataCell(1,5) = {'simStack1'};
allDataCell(1,6) = {'simStack2'};
%% Loop through all files again to place the data in allDataCell
%instantiate counter
cnt = 2; % to prevent label row overwrite
%% Waitbar
f = waitbar(0, 'Parsing images now');
for n = 1:numel(files)
    load(fullfile(files(n).folder, files(n).name));
    if size(spotStructArray.dataCell, 1)~= 2
        continue
    end
    %% Load in the GFP and RFP Stacks
    stack1 = readTiffStack(spotStructArray.stack1Filename);
    stack2 = readTiffStack(spotStructArray.stack2Filename);
    for i = 1:4
        allDataCell{cnt,i} = spotStructArray.dataCell{2,i};
    end
    allDataCell{cnt,5} = stack1;
    allDataCell{cnt,6} = stack2;
    cnt = cnt + 1;
    waitbar(n./numel(files),f, 'Parsing images now');
end
%% Close waitbar
close(f);
end