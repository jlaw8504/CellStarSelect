function needsPad = padCheck(img2dSize, imgSpots, halfRS)
%padCheck Determine if image needs to be padded based on pixel of interest
%   Function determines if any of the coordinates listed in imgSpots, where
%   each row is a spot and the columns are row (Y) then col (X).
%% Determine if the img needs to be padded
%if spots are close to edges
rowNum = img2dSize(1);
colNum = img2dSize(2);
smallCheck = imgSpots <= halfRS;
rowCheck = (imgSpots(:,1) + halfRS) > rowNum;
colCheck = (imgSpots(:,2) + halfRS) > colNum;
largeCheck = [rowCheck, colCheck];
totalCheck = smallCheck | largeCheck;
if logical(sum(totalCheck(:)))
    needsPad = true;
else
    needsPad = false;
end

