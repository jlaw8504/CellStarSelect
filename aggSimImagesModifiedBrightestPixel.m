function [allDataCell,KickedOut] = aggSimImagesModifiedBrightestPixel(name_struct)
%aggImagesModified Aggreated coordinate information and filtered image stacks into
%a single cell array
%   Function loops over all the MAT files contianing the spotStructArray
%   variable and uses that stored information to parse image stacks to
%   aggregate both the coordinate information and filtered image stacks
%   into the cell array imageCell.

%% determine proper cell array size
count = numel(name_struct)+1; % +1 is for label row

%% Create allDataCell array
allDataCell = cell([count, 6]); 
allDataCell(1,:) = {'Spot 1 Channel 1','Spot 2 Channel 1','Spot 1 Channel 2','Spot 2 Channel 2','Spot 1 Channel 3', 'Spot 2 Channel 3'};
allDataCell(1,7) = {'simStack1'};
allDataCell(1,8) = {'simStack2'};
allDataCell(1,9) = {'simStack3'};
%% Loop through all files again to place the data in allDataCell
%instantiate counter
cnt = 2; % to prevent label row overwrite
counter = 1;
%% Waitbar
f = waitbar(0, 'Parsing images now');
KickedOut = {};
for n = 1:numel(name_struct)
    spotStructArray = SpotDetectionModifiedBrightestPixel(name_struct(n).fieldone, name_struct(n).fieldtwo, name_struct(n).fieldthree);
    if size(spotStructArray.dataCell, 1)~= 2
        KickedOut{counter,1} = n; %#ok<AGROW>
        counter=counter+1;
        continue
    end
    %% Load in the GFP and RFP Stacks
    stack1 = readTiffStack(name_struct(n).fieldone);
    stack2 = readTiffStack(name_struct(n).fieldtwo);
    stack3 = readTiffStack(name_struct(n).fieldthree);
    for i = 1:6
        allDataCell{cnt,i} = spotStructArray.dataCell{2,i};
    end
    allDataCell{cnt,7} = stack1;
    allDataCell{cnt,8} = stack2;
    allDataCell{cnt,9} = stack3;
    cnt = cnt + 1;
    waitbar(n./numel(name_struct),f, 'Parsing images now');
end
%% Close waitbar
delete(f);
%% Remove empty cells
new = allDataCell(~cellfun('isempty',allDataCell));
allDataCell = reshape(new, [numel(new)/size(allDataCell,2), size(allDataCell,2)]);
end