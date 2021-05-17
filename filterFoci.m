function [filterCell, outlierCell] = filterFoci(dataCell, skewThresh)
%%fociFilter Filter cells in dataCell array based on the level of skew in
%%the intensity values surrounding the detected foci's brightest pixel.
%
%   inputs :
%       dataCell : The cell array outputted by aggImages function.
%
%       skewThresh : A numeric variable indicating how skewed the foci
%       signal intensity histogram must be. Suggested value of 0.5.
%
%   outputs :
%       filteredCell : A cell array containing only cells whose kinetochore
%       and spindle pole body foci have a high level of skew.
%
%       outlierCell : A cell array containing only cells whose kinetochore
%       foci are NOT between the min/max X and Y dimensions of the 
%       spindle pole body foci.

%% Pre-allocate logical array
skewArray = ones([size(dataCell,1), 4]);

%% %% Loop over dataCell array
for n=2:size(dataCell,1)
    for i = 1:6 %iterate over foci columns
        if i < 3
            col = 7;
        elseif (i>=3) && (i<5)
            col = 8;
        else
            col = 9;
        end
        infPlane = dataCell{n,col}(:,:,dataCell{n,i}(3));
        padPlane = padarray(infPlane, [3,3], 'both', 'symmetric');
        fociIm = padPlane(...
            dataCell{n,i}(1):dataCell{n,i}(1)+6,...
            dataCell{n,i}(2):dataCell{n,i}(2)+6);
        skewArray(n,i) = skewness(fociIm(:));
%         if skewArray(n) < 0
%         h = figure('WindowState', 'maximized');
%         subplot(1,2,1);
%         imshow(infPlane, []);
%         title(num2str(skewness(fociIm(:))));
%         subplot(1,2,2);
%         histogram(fociIm(:));
%         waitforbuttonpress;
%         close(h);
%         end
    end
end
keepArray = skewArray > skewThresh;
keepArray = sum(keepArray, 2);
keepArray(1) = 1;
keepArray = boolean(keepArray);
outArray = ~keepArray;
outArray(1) = 1;
filterCell = dataCell(keepArray,:);
outlierCell = dataCell(outArray,:);    