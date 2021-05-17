function mipArray = mipCrop(dataCell, spbChannel)
%%mipCrop Create and crop a max intensity projection from an existing cell
%%array
%
%   inputs :
%       dataCell : The cell array outputted by aggImages function
%
%       spbChannel : Integer specifying which chanell in the dataCell
%       variable contains images of the spindle pole bodies (SPBs).
%
%   ouput :
%       outputArray : A cell array containing the maximum intensity
%       projections created from stacks in dataCell array

%% specifiy correct column to parse from dataCell array
if spbChannel == 1
    coordCol1 = 3;
    coordCol2 = 4;
    stackCol = 6; %the NOT spbChannel stack
elseif spbChannel == 2
    coordCol1 = 1;
    coordCol2 = 2;
    stackCol = 5; %the NOT spbChannel stack
else
    error('spbChannel must be 1 or 2');
end
%% Iterate over the dataCell array
mipArray = cell([(size(dataCell,1)-1),1]);
for n = 2:size(dataCell, 1)
mip = max(dataCell{n,stackCol},[], 3);
padMip = padarray(mip,[24 24], 'replicate', 'both');
midCoords = floor((...
    dataCell{n,coordCol1}(1:2)...
    + dataCell{n, coordCol2}(1:2))...
    /2 ...
    );
midCoords = midCoords + 24;
mipArray{n-1,1} = padMip(midCoords(1)-24:midCoords(1)+24, ...
    midCoords(2)-24 : midCoords(2) + 24);
end