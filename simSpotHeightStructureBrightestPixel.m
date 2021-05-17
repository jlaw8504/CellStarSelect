function s = simSpotHeightStructureBrightestPixel(directory, field1nopattern, field2nopattern, field3nopattern, spbChannel, outerChannel, spindleBounds, zTilt, skewThresh, pixelSize, regionSize)
%%spotHeightStructure Parses the cellStarSelect MAT-files and analyzes the cse4
%%and spindle pole body foci.
%
%   inputs :
%       matPattern : String containing the file pattern to caputre all the
%       MAT-files to parse. For Example: sprintf('*%sTrans*.mat', filesep)

%       field1nopattern: (same as for 2 and 3) file ending (a character array e.g. 'G.tif') to recognize
%       files (use G.tif for outer/Nuf2, R.tif for spb channel, B.tif for
%       inner channel/kinet protein)
%
%       spbChannel : Integer specifying which channel in the dataCell
%       variable contains images of the spindle pole bodies (SPBs).
%
%       outerChannel : Integer specifying which channel in the dataCell
%       variable contains images of the outer (Nuf2) bodies.
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
%           s.oH : An array of outer (Nuf2) foci heights in pixels
%
%           s.oHnm : An array of outer (Nuf2) foci heights in nanometers.
%
%           s.oHnoOutnm : An array of outer (Nuf2) foci heights without
%           outliers.. Outliers determined by isoutlier function.
%
%           s.iH : An array of inner (kinet protein) foci heights in pixels
%
%           s.iHnm : An array of inner (kinet protein) foci heights in nanometers.
%
%           s.iHnoOutnm : An array of inner (kinet protein) foci heights without
%           outliers.. Outliers determined by isoutlier function.
%
%           s.sH : An array of spindle pole body foci heights in pixels.
%
%           s.sHnm : An array of spindle pole body foci heights in
%           nanometers.
%
%           s.sHnoOutnm : An array of spindle pole body foci heights
%           without outliers. Outliers determined by isoutlier function.
%
%           s.oDistancenm : An array of outer to outer (Nuf2)
%           distances in 2D (X and Y) in nm.
%
%           s.iDistancenm : An array of inner to inner (Kinet protein)
%           distances in 2D (X and Y) in nm.
%
%           s.sLengthsnm : An array of SPB to SPB distances in 2D (X and Y)
%           in nm.

%% Store input variables
s.name_struct = image_name_match_new(directory, field1nopattern, field2nopattern, field3nopattern);
s.spbChannel = spbChannel;
s.outerChannel = outerChannel;
s.spindleBounds = spindleBounds;
s.zTilt = zTilt;
s.skewThresh = skewThresh;
s.pixelSize = pixelSize;
s.regionSize = regionSize;
%% Data parsing, filtering, and foci height calculations
[s.allDataCell,s.KickedOut] = aggSimImagesModifiedBrightestPixel(s.name_struct);
s.filterCell = filterSlength(...
    s.allDataCell, s.spbChannel, s.spindleBounds, s.zTilt, s.pixelSize);
s.filterCell = filterPosition(s.filterCell, s.spbChannel, s.outerChannel, 5);
s.filterCell = filterFoci(s.filterCell, s.skewThresh);
s.filterCell = filterFuzz(s.filterCell, s.spbChannel);
s.HA = spotHeightModified(s.filterCell, s.regionSize, s.spbChannel, s.outerChannel);
%% Kinetochore and SPB foci array height outlier removal
% Collect outer (Nuf2) foci heights in single array
s.oH = [s.HA.oHeights1; s.HA.oHeights2];
s.oHnm = s.oH * pixelSize;
% Collect inner (kinet protein) foci heights in single array
s.iH = [s.HA.iHeights1; s.HA.iHeights2];
s.iHnm = s.iH * pixelSize;
% Collect SPB foci heights in single array
s.sH = [s.HA.sHeights1; s.HA.sHeights2];
s.sHnm = s.sH * pixelSize;
% Convert spindle lengths, outer distance, and inner distance to nm
s.sLengthsnm = s.HA.sLengths * s.pixelSize;
% s.oDistancenm = s.HA.oDistance * s.pixelSize;
s.iDistancenm = s.HA.iDistance * s.pixelSize;
%filter out outliers using while loop and ~isoutlier
[s.oHnoOutnm, oHnmcolumnindices] = noArrayOutliers(s.oHnm);
oHcounter = 1;
iHcounter = 1;
sHcounter = 1;
for i = 1:length(oHnmcolumnindices)
    if oHnmcolumnindices(i) <= (length(s.filterCell)-1)
        ohvalue = oHnmcolumnindices(i)+1;
        s.oHOutFilterCellIndices{oHcounter,1} = [ohvalue,7];
    else
        thisvalueofoh = (oHnmcolumnindices(i)-(length(s.filterCell)-1))+1;
        s.oHOutFilterCellIndices{oHcounter,1} = [thisvalueofoh,7];
    end
    oHcounter = oHcounter+1;
end
[s.iHnoOutnm, iHnmcolumnindices] = noArrayOutliers(s.iHnm);
for i = 1:length(iHnmcolumnindices)
    if iHnmcolumnindices(i) <= (length(s.filterCell)-1)
        thevalue = iHnmcolumnindices(i)+1;
        s.iHOutFilterCellIndices{iHcounter,1} = [thevalue,9];
    else
        thisihvalue = (iHnmcolumnindices(i)-(length(s.filterCell)-1))+1;
        s.iHOutFilterCellIndices{iHcounter,1} = [thisihvalue,9];
    end
    iHcounter = iHcounter+1;
end
[s.sHnoOutnm, sHnmcolumnindices] = noArrayOutliers(s.sHnm);
for i = 1:length(sHnmcolumnindices)
    if sHnmcolumnindices(i) <= (length(s.filterCell)-1)
        thisvalue = sHnmcolumnindices(i)+1;
        s.sHOutFilterCellIndices{sHcounter,1} = [thisvalue,8];
    else
        value = (sHnmcolumnindices(i)-(length(s.filterCell)-1))+1;
        s.sHOutFilterCellIndices{sHcounter,1} = [value,8];
    end
    sHcounter = sHcounter+1;
end
end