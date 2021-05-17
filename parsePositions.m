function [X, Y] = parsePositions(dataCell, pixelSize, spbChannel)
%parsePositions Parese the X and Y coordinates of kinetochore spots
%relative to the spindle axis.
%   Input :
%       dataCell : The cell array outputted by aggImages function
%
%       pixelSize : The size of a pixel in nanometers.
%
%       spbChannel : Integer specifying which chanell in the dataCell
%       variable contains images of the spindle pole bodies (SPBs).
%
%   Output :
%       X : Array of X positions relative to spindle axis in nanometers.
%
%       Y : Array of Y posiitons relatvie to spindle axis in nanometers

%% Loop over data in dataCell
%pre-allocate sub1 and sub2 matrices
sub1 = zeros([size(dataCell,1)-1,2]);
sub2 = sub1;
for n = 2:size(dataCell,1)
    %% Perform a distance check to ensure spots are paired properly
    ch1spt1 = dataCell{n,1};
    ch1spt2 = dataCell{n,2};
    ch2spt1 = dataCell{n,3};
    ch2spt2 = dataCell{n,4};
    distSpt1 = norm(ch1spt1(1:2) - ch2spt1(1:2));
    altDistSpt1 = norm(ch1spt1(1:2) - ch2spt2(1:2));
    distSpt2 = norm(ch1spt2(1:2) - ch2spt2(1:2));
    altDistSpt2 = norm(ch1spt2(1:2) - ch2spt1(1:2));
    if distSpt1 > altDistSpt1 && distSpt2 > altDistSpt2
        ch2spt1 = dataCell{n,4};
        ch2spt2 = dataCell{n,3};
    end
    %% Assign spots to kinet or spb variables
    if spbChannel == 1
        spb1 = ch1spt1(1:2);
        spb2 = ch1spt2(1:2);
        kinet1 = ch2spt1(1:2);
        kinet2 = ch2spt2(1:2);
    elseif spbChannel == 2
        spb1 = ch2spt1(1:2);
        spb2 = ch2spt2(1:2);
        kinet1 = ch1spt1(1:2);
        kinet2 = ch1spt2(1:2);
    else
        error('Variable spbChannel must be either 1 or 2');
    end
    %% Try distance to spindle axis method
    %[newKinet1(n-1,:), newKinet2(n-1,:)] = sAxisYX(spb1,spb2, kinet1, kinet2);
    % This method does appear to give same distance as rotation method
    % But you lose out on directional information
    %% Determine left-most spb spot
    if spb1(2) < spb2(2)
        subSpot = spb1;
    else
        subSpot = spb2;
    end
    %% Register the coordinates by the left-most spb spot
    subSpb1 = spb1 - subSpot;
    subSpb2 = spb2 - subSpot;
    subKinet1 = kinet1 - subSpot;
    subKinet2 = kinet2 - subSpot;
    %% Rotate the coordinates
    %calc the angle
    if sum(subSpb1 == [0, 0]) == 2
        theta = atan2(subSpb2(1), subSpb2(2));
    else
        theta = atan2(subSpb1(1), subSpb1(2));
    end
    R = [cos(theta), -sin(theta); sin(theta) cos(theta)];
    rotSpb1 = (R*subSpb1')';
    rotSpb2 = (R*subSpb2')';
    rotKinet1 = (R*subKinet1')';
    rotKinet2 = (R*subKinet2')';
    %% Calculate X distances and Y distances
    sub1(n-1,:) = (rotKinet1 - rotSpb1) * pixelSize;
    sub2(n-1,:) = (rotKinet2 - rotSpb2) * pixelSize;
    %% Plot the results
%     h = figure;
%     subplot(2,1,1);
%     scatter(rotSpb1(2), rotSpb1(1), 'ro');
%     axis([-50 50 -50 50])
%     hold on;
%     scatter(rotSpb2(2), rotSpb2(1), 'rx');
%     scatter(rotKinet1(2), rotKinet1(1), 'go');
%     scatter(rotKinet2(2), rotKinet2(1), 'gx');
%     hold off;
%     subplot(2,1,2);
%     scatter(subSpb1(2), subSpb1(1), 'ro');
%     axis([0 100 -50 50])
%     hold on;
%     scatter(subSpb2(2), subSpb2(1), 'rx');
%     scatter(subKinet1(2), subKinet1(1), 'go');
%     scatter(subKinet2(2), subKinet2(1), 'gx');
%     hold off;
%     waitforbuttonpress;
%     close(h);
end
%% Create gridspace for heatmap
xDim = -1.5*pixelSize:pixelSize:8.5*pixelSize;
yDim = -0.5*pixelSize:pixelSize:4.5*pixelSize;
h = zeros(length(yDim),length(xDim));
%% Filter the subAll variable of outliers using deafult MAD criterion
subAll = [sub1; sub2];
absAll = abs(subAll);
outliers = isoutlier(absAll);
allOut = outliers(:,1) & outliers(:,2);
while sum(allOut) > 0
    absAll = absAll(~allOut,:);
    outliers = isoutlier(absAll);
    allOut = outliers(:,1) | outliers(:,2);
end
X = absAll(~allOut,2);
Y = absAll(~allOut,1);
% 
% maxX = ceil(max(X)/pixelSize);
% maxY = ceil(max(Y)/pixelSize);
% hMat = zeros([maxY, maxX]);
% 
% for m = 1:maxY
%     for n = 1:maxX
%         filter = (X <= n*64.8) & (Y <= m*64.8);
%         hMat(m,n) = sum(filter);
%         X(filter) = nan;
%         Y(filter) = nan;
%     end
% end
% hFlip = flipud(hMat);
% h = [hFlip;hMat];
% figure;
% imagesc(h);
% colorbar;
% colormap hot;
% xticks = 0.5:1:maxX+0.5;
% xvals = round((0:maxX)*64.8);
% xlabels = arrayfun(@num2str, xvals, 'UniformOutput', 0);
% yticks = 0.5:1:(maxY*2)+0.5;
% yvals = fliplr(round((-maxY:maxY)*64.8));
% ylabels = arrayfun(@num2str, yvals, 'UniformOutput', 0);
% set(gca,'XTick',xticks)
% set(gca,'XTickLabel',xlabels)
% set(gca,'YTick', yticks)
% set(gca,'YTickLabel',ylabels)