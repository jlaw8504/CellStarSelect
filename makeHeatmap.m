function [X, Y, H] = makeHeatmap(dataCell, pixelSize, spbChannel)
%makeHeatmap Make a heatmap from coordinate data in the dataCell array
%   Input :
%       dataCell : The cell array outputted by aggImages function
%
%       pixelSize : The size of a pixel in nanometers.
%
%       spbChannel : Integer specifying which chanell in the dataCell
%       variable contains images of the spindle pole bodies (SPBs).
%
%   Output :
%       subAll : A two-dimensional matrix that contains the heatmap data.
%       Each row is the [Y X] distance of the kinetochore spot to the
%       corresponding spindle pole body.
%
%       H : The heat map matrix created by dsearchn.

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
xDim = linspace(2*(-pixelSize), 27*pixelSize, 31);
yDim = linspace(pixelSize*(-15), pixelSize*(15), 31);
H = zeros(length(yDim),length(xDim));
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

for l = 1:size(X,1)
    countX = dsearchn(xDim', X(l));
    countY = dsearchn(yDim', Y(l));
    H(countY,countX) = H(countY,countX) + 1 ;
end
%% Mirror in Y
for n = 1:16
    H(n,:) = H((32-n),:);
end
%% Create the heatmap
% code taken from Matthew Larson's Heatmap make program 
data_name = 'H';
activedata=eval(data_name);
interpnumber = 2;
activeinterp=interp2(activedata,interpnumber);%linear interpolate data
activeinterp=activeinterp/max(max(activeinterp));%standardize to max=100%
eval([data_name 'interp' num2str(interpnumber) '= activeinterp;'])%create name for interpolated data
eval(['interpvarname =''' data_name 'interp' num2str(interpnumber) ''';'])
figure
%create new plot
imagesc(activeinterp)
xlabel('Distance (nm)')
ylabel('Distance (nm)')
%adjust axis labels
xlabels=round([0:2:(size(activedata,2)-1)]*pixelSize);
xlabels=(mat2cell(xlabels,1,ones(1,length(xlabels))));
ylabels=round(fliplr(([0:2:(size(activedata,1)-1)]-floor(size(activedata,1)/2))*pixelSize));
ylabels=(mat2cell(ylabels,1,ones(1,length(ylabels))));
set(gca,'XTick',1:(2*2^interpnumber):size(activeinterp,2))
set(gca,'XTickLabel',xlabels)
set(gca,'YTick',1:(2*2^interpnumber):size(activeinterp,1))
set(gca,'YTickLabel',ylabels)
colorbar
colormap hot
%colormap jet %remove % at the beginning of this line for jet (rainbow) colormap
axis image

