function [rotCellArray,allYs] =  rotateAllCoords(cellArray, spbChannel)
%%rotCellArray Rotates coordinates in cellArray by setting the spindle pole
%%bodies to the X-axis with the first SPB coordinate set at the origin.
%
%   inputs :
%       cellArray : A cell array containing the foci coordinates to rotate
%       in the first four columns, i.e.{foci 1 channel 1, foci 2 channel 1,
%       foci 1 channel 2, foci 2 channel 2}. This cell array is typically
%       generated by CellStarSelect or a filtered version of that array.
%
%       spbChannel : Integer, 1 or 2, specifying which chanel in the cell
%       array contains images of the spindle pole bodies (SPBs).
%
%   output :
%       rotCellArray : A cell array contianing the rotate foci coordiantes
%       in the first four columns, i.e.{rotated spb1(origin), rotated spb2,
%       rotated foci1, rotated foci2}. All other columns of orginal
%       cell array are NOT returned. Each cell contains [Y,X] in pixels.

%% Instantiate rotCellArray and rot matrix
rotCellArray = cell([size(cellArray,1),4]);
rotCellArray(1,:) = {'Rotated Image1 Spot1',...
    'Rotated Image1 Spot2',...
    'Rotated Image2 Spot1',...
    'Rotated Image2 Spot2'...
    };
rot = zeros([4,2]);
allYs = zeros((size(cellArray,1)-1)*2, 1);
%% Loop through each row of cellArray, except first/labeling row
for n = 2:size(cellArray,1)
    %grab the Y and X and put into matrix, columns are Y X
    %rows are spb1, spb2, coord1, coord2
    if spbChannel == 1
        coords(1,:) = cellArray{n,1}(1:2);
        coords(2,:) = cellArray{n,2}(1:2);
        coords(3,:) = cellArray{n,3}(1:2);
        coords(4,:) = cellArray{n,4}(1:2);
    elseif spbChannel == 2
        coords(3,:) = cellArray{n,1}(1:2);
        coords(4,:) = cellArray{n,2}(1:2);
        coords(1,:) = cellArray{n,3}(1:2);
        coords(2,:) = cellArray{n,4}(1:2);
    else
        error('spbChannel must be either 1 or 2');
    end
    %% Set spbCoord1 at origin, by subtraction
    coords = coords - coords(1,:);
    %% Rotate coordinates
    theta = atan2(coords(2,1), coords(2,2));
    rotMat = [cos(-theta), -sin(-theta); sin(-theta), cos(-theta)];
    for i = 1:4
        rot(i,:) = coords(i,:)*rotMat;
    end
    rot(2,1) = round(rot(2,1));
    if rot(1,1) ~= 0 || rot(1,2) ~=0 || rot(2,1) ~= 0
        error('Rotation error detected!')
    end
    rotCellArray{n,1} = rot(1,:);
    rotCellArray{n,2} = rot(2,:);
    rotCellArray{n,3} = rot(3,:);
    rotCellArray{n,4} = rot(4,:);
    %% Put origin proximal foci in col 3 and distal in col 4
    distf1=norm(rotCellArray{n,3});
    distf2=norm(rotCellArray{n,4});
    if distf1<=distf2
       rotCellArray{n,3}=rot(3,:);
       rotCellArray{n,4}=rot(4,:);
    elseif distf1>distf2 
         rotCellArray{n,4}=rot(3,:);
         rotCellArray{n,3}=rot(4,:);         
    end
    %% collect all y's
    allYs(n+(n-3)) = rotCellArray{n,3}(1);
    allYs(n+(n-2)) = rotCellArray{n,4}(1);
%     %% Visualize rotations
%     if n == 2
%         figure;
%         scatter(rotCellArray{n,1}(1), rotCellArray{n,1}(2), 'rx');
%         scatter(rotCellArray{n,4}(1), rotCellArray{n,4}(2), 'go');
%         hold on;
%     elseif n == size(cellArray,1)
%         scatter(rotCellArray{n,1}(1), rotCellArray{n,1}(2), 'rx');
%         scatter(rotCellArray{n,4}(1), rotCellArray{n,4}(2), 'go');
%         hold off;
%     else
%         scatter(rotCellArray{n,1}(1), rotCellArray{n,1}(2), 'rx');
%         scatter(rotCellArray{n,4}(1), rotCellArray{n,4}(2), 'go');
%     end
end