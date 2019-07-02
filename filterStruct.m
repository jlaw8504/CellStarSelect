function [filterCell, s] = filterStruct(matPattern, spbChannel, spindleBounds, zTilt, skewThresh, pixelSize)
%%radialDispStruct Creates a structural array containing all the
%%information needed to calculate radial displacements of foci reative to
%%spindle axis
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
%       skewThresh : A numeric variable indicating how skewed the foci
%       signal intensity histogram must be. Suggested value of 0.5.
%
%       pixelSize : The size of a pixel in nanometers.
%
%   output :
%       s : A structure array contianing the following fields:
%           s.allDataCell : The cell array outputted by aggImages function
%
%       filterCell : A cell array filtered by the spindle length,
%       specified by spindleBounds, and zTilt.

%% Store input variables
s.matPattern = matPattern;
s.spbChannel = spbChannel;
s.spindleBounds = spindleBounds;
s.zTilt = zTilt;
s.skewThresh = skewThresh;
s.pixelSize = pixelSize;
%% Data parsing and filtering
s.allDataCell = aggImages(s.matPattern);
s.filterCell = filterSlength(...
    s.allDataCell, s.spbChannel, s.spindleBounds, s.zTilt, s.pixelSize);
s.filterCell = filterPosition(s.filterCell, s.spbChannel, 10);
s.filterCell = filterFoci(s.filterCell, s.skewThresh);
filterCell = s.filterCell;
