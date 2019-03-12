function s = spotHeightStructure(matPattern, spbChannel, spindleBounds, zTilt, pixelSize, regionSize)
%%cse4Structure Parses the cellStarSelect MAT-files and analyzes the cse4
%%and spindle pole body foci.
%
%   inputs :
%       matPattern : String containing the file pattern to caputre all the
%       MAT-files to parse. For Example: sprintf('*%sTrans*.mat', filesep)
%
%       spbChannel : Integer specifying which chanell in the dataCell
%       variable contains images of the spindle pole bodies (SPBs).
%
%       spindleBounds : Vector containing the [min max] spindle lengths you
%       wish to collect. Note spindle length is calculated using X and Y
%       dimensions only.
%
%       zTilt : Integer specifying how many zPlanes the SPBs can be
%       separated by.
%
%       pixelSize : The size of a pixel in nanometers. 
%
%       regionSize : The length, in pixels, of the sides of the square
%       region used to crop out the foci surrounding the brightest pixel.
%       Must be at least 15 pixels.
%
%   output :
%
%       s : A structure array containing the above input variables and the
%       following outputs:
%
%           s.HA = Structural array of the foci heights, in
%           pixels, of the two kinetochore foci, the two SPB foci, and each
%           foci's Gaussian fit R-squared value.
%
%           s.dataCell : The cell array outputted by aggImages function
%
%           s.filterCell : A cell array filtered by the spindle length,
%           specified by spindleBounds, and zTilt.
%
%           s.kH : An array of kinetchore foci heights in pixels
%
%           s.kHnm : An array of kinetochore foci heights in nanometers.
%
%           s.kHnoOutnm : An array of kinetochore foci heights without
%           outliers.. Outliers determined by isoutlier function.
%
%           s.sH : An array of spindle pole body foci heights in pixels.
%
%           s.sHnm : An array of spindle pole body foci heights in
%           nanometers.
%
%           s.sHnoOutnm : An array of spindle pole body foci heights
%           without outliers. Outliers determined by isoutlier function.

%% Store input variables
s.matPattern = matPattern;
s.spbChannel = spbChannel;
s.spindleBounds = spindleBounds;
s.zTilt = zTilt;
s.pixelSize = pixelSize;
s.regionSize = regionSize;
%% Data parsing, filtering, and foci height calculations
s.allDataCell = aggImages(s.matPattern);
s.filterCell = filterSlength(...
    s.allDataCell, s.spbChannel, s.spindleBounds, s.zTilt, s.pixelSize);
s.HA = spotHeight(s.filterCell, s.regionSize, s.spbChannel);
%% Kinetochore and SPB foci array height outlier removal
% Collect kinetochore foci heights in single array
s.kH = [s.HA.kHeights1; s.HA.kHeights2];
s.kHnm = s.kH * pixelSize;
% Collect SPB foci heights in single array
s.sH = [s.HA.sHeights1; s.HA.sHeights2];
s.sHnm = s.sH * pixelSize;
%filter out outliers using while loop and ~isoutlier
s.kHnoOutnm = noArrayOutliers(s.kHnm);
s.sHnoOutnm = noArrayOutliers(s.sHnm);
