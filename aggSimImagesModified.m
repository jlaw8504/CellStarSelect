function allDataCell = aggSimImagesModified(name_struct)
%aggImagesModified Aggreated coordinate information and filtered image stacks into
%a single cell array
%   Function loops over all the MAT files contianing the spotStructArray
%   variable and uses that stored information to parse image stacks to
%   aggregate both the coordinate information and filtered image stacks
%   into the cell array imageCell.

%% determine proper cell array size
count = numel(name_struct)+1; % +1 is for label row

%% Create allDataCell array
allDataCell = cell([count, 4]); 
allDataCell(1,:) = {'Spot 1 Channel 1','Spot 2 Channel 1','Spot 1 channel 2','Spot 2 Channel 2'};
allDataCell(1,5) = {'simStack1'};
allDataCell(1,6) = {'simStack2'};
%% Loop through all files again to place the data in allDataCell
%instantiate counter
cnt = 2; % to prevent label row overwrite
%% Waitbar
f = waitbar(0, 'Parsing images now');
for n = 1:numel(name_struct)
    spotStructArray = SpotDetectionModified(name_struct(n).fieldone, name_struct(n).fieldtwo);
    if size(spotStructArray.dataCell, 1)~= 2
        continue
    end
    %% Load in the GFP and RFP Stacks
    stack1 = readTiffStack(name_struct(n).fieldone);
    stack2 = readTiffStack(name_struct(n).fieldtwo);
    for i = 1:4
        allDataCell{cnt,i} = spotStructArray.dataCell{2,i};
    end
    allDataCell{cnt,5} = stack1;
    allDataCell{cnt,6} = stack2;
    cnt = cnt + 1;
    waitbar(n./numel(name_struct),f, 'Parsing images now');
end
%% Close waitbar
delete(f);
%% Remove empty cells
new = allDataCell(~cellfun('isempty',allDataCell));
allDataCell = reshape(new, [numel(new)/size(allDataCell,2), size(allDataCell,2)]);
end