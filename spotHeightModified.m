function heightArray = spotHeightModified(dataCell, regionSize, spbChannel, outerChannel)
%%spotHeight Measures the spot heights of foci in the images stored in a
%%cell array generated by CellStarSelect pipeline.
%   Inputs :
%       dataCell : The cell array outputted by aggImages function
%
%       regionSize : The length, in pixels, of the sides of the square
%       region used to crop out the foci surrounding the brightest pixel.
%       Must be at least 15 pixels.
%
%       spbChannel : 1 or 2. Specifies which fluorescent image channel
%       contains images of the spindle pole bodies.

%       outerChannel : 1, 2, or 3. Specifies which fluorescent image channel
%       contains images of the outer (Nuf 2) bodies.
%
%   Outputs :
%       heightArray = Structural array containing the spot heights, in
%       pixels, of the two outer (Nuf2) foci, the two SPB foci, the two inner (kinetochore protein) foci, each
%       foci's Gaussian fit R squared value for post hoc filtering, 2D
%       spindle length, and 2D kkdistance.

%% Loop over data in dataCell
%pre-allocate structural array
num = size(dataCell,1) - 1;
heightArray.oHeights1 = zeros([num, 1]);
heightArray.oHeights2 = zeros([num, 1]);
heightArray.iHeights1 = zeros([num, 1]);
heightArray.iHeights2 = zeros([num, 1]);
heightArray.sHeights1 = zeros([num, 1]);
heightArray.sHeights2 = zeros([num, 1]);
heightArray.oHeightsRsq1 = zeros([num, 1]);
heightArray.oHeightsRsq2 = zeros([num, 1]);
heightArray.iHeightsRsq1 = zeros([num, 1]);
heightArray.iHeightsRsq2 = zeros([num, 1]);
heightArray.sHeightsRsq1 = zeros([num, 1]);
heightArray.sHeightsRsq2 = zeros([num, 1]);
heightArray.sLengths = zeros([num,1]);
heightArray.oDistance = zeros([num,1]);
heightArray.iDistance = zeros([num,1]);
%% Check that regionSize is at least 15 pixels
if regionSize < 15
    error('Set regionSize to value of 15 pixels or greater');
end
%% Set up waitbar
h = waitbar(0, 'Calculating 1D Gaussians now...');
for n = 2:size(dataCell,1)
    %% Parse coordinate data
    ch1spt1 = dataCell{n,1};
    ch1spt2 = dataCell{n,2};
    ch2spt1 = dataCell{n,3};
    ch2spt2 = dataCell{n,4};
    ch3spt1 = dataCell{n,5};
    ch3spt2 = dataCell{n,6};
    %% Assign spots to kinet or spb variables
    if spbChannel == 1
        if outerChannel == 2
            spb1 = ch1spt1(1:3);
            spb2 = ch1spt2(1:3);
            outer1 = ch2spt1(1:3);
            outer2 = ch2spt2(1:3);
            inner1 = ch3spt1(1:3);
            inner2 = ch3spt2(1:3);
            spbIm = dataCell{n,7};
            outerIm = dataCell{n,8};
            innerIm = dataCell{n,9};
        elseif outerChannel == 3
            spb1 = ch1spt1(1:3);
            spb2 = ch1spt2(1:3);
            outer1 = ch3spt1(1:3);
            outer2 = ch3spt2(1:3);
            inner1 = ch2spt1(1:3);
            inner2 = ch2spt2(1:3);
            spbIm = dataCell{n,7};
            outerIm = dataCell{n,9};
            innerIm = dataCell{n,8};
        end
    elseif spbChannel == 2
        if outerChannel == 1
            spb1 = ch2spt1(1:3);
            spb2 = ch2spt2(1:3);
            outer1 = ch1spt1(1:3);
            outer2 = ch1spt2(1:3);
            inner1 = ch3spt1(1:3);
            inner2 = ch3spt2(1:3);
            spbIm = dataCell{n,8};
            outerIm = dataCell{n,7};
            innerIm = dataCell{n,9};
        elseif outerChannel == 3
            spb1 = ch2spt1(1:3);
            spb2 = ch2spt2(1:3);
            outer1 = ch3spt1(1:3);
            outer2 = ch3spt2(1:3);
            inner1 = ch1spt1(1:3);
            inner2 = ch1spt2(1:3);
            spbIm = dataCell{n,8};
            outerIm = dataCell{n,9};
            innerIm = dataCell{n,7};
        end
    else
        error('Variable spbChannel must be either 1 or 2');
    end
    %% Rotate the foci images
    [finalspb, SPB1, SPB2] = rotateimage(spbIm, spb1, spb2);
    dataCell{n,10} = [SPB1(1),SPB1(2),SPB1(3),SPB1(4)];
    dataCell{n,11} = [SPB2(1),SPB2(2),SPB2(3),SPB2(4)];
    dataCell{n,16} = finalspb;
    [finalouter, OUTER1, OUTER2] = rotateimage(outerIm, outer1, outer2);
    dataCell{n,12} = [OUTER1(1),OUTER1(2),OUTER1(3),OUTER1(4)];
    dataCell{n,13} = [OUTER2(1),OUTER2(2),OUTER2(3),OUTER2(4)];
    dataCell{n,17} = finalouter;
    [finalinner, INNER1, INNER2] = rotateimage(innerIm, inner1, inner2);
    dataCell{n,14} = [INNER1(1),INNER1(2),INNER1(3),INNER1(4)];
    dataCell{n,15} = [INNER2(1),INNER2(2),INNER2(3),INNER2(4)];
    dataCell{n,18} = finalinner;
    %% Extract the in-focus planes of all the recorded spots
    rotOuter1 = extractFoci(OUTER1(1:3), finalouter, regionSize);
    rotOuter2 = extractFoci(OUTER2(1:3), finalouter, regionSize);
    rotSpb1 = extractFoci(SPB1(1:3), finalspb, regionSize);
    rotSpb2 = extractFoci(SPB2(1:3), finalspb, regionSize);
    rotInner1 = extractFoci(INNER1(1:3), finalinner, regionSize);
    rotInner2 = extractFoci(INNER2(1:3), finalinner, regionSize);
    %% Calculate the FWHM of the rotated images
    [heightArray.oHeights1(n-1), heightArray.oHeightsRsq1(n-1)] = calcFwhm(rotOuter1, regionSize);
    [heightArray.oHeights2(n-1), heightArray.oHeightsRsq2(n-1)] = calcFwhm(rotOuter2, regionSize);
    [heightArray.sHeights1(n-1), heightArray.sHeightsRsq1(n-1)] = calcFwhm(rotSpb1, regionSize);
    [heightArray.sHeights2(n-1), heightArray.sHeightsRsq2(n-1)] = calcFwhm(rotSpb2, regionSize);
    [heightArray.iHeights1(n-1), heightArray.iHeightsRsq1(n-1)] = calcFwhm(rotInner1, regionSize);
    [heightArray.iHeights2(n-1), heightArray.iHeightsRsq2(n-1)] = calcFwhm(rotInner2, regionSize);
    %% Calculate the 2D Spindle Length in Pixels
    spbSub = spb1 - spb2;
    outerSub = outer1 - outer2;
    innerSub = inner1 - inner2;
    heightArray.sLengths(n-1) = norm(spbSub(1:2));
    heightArray.oDistance(n-1)= norm(outerSub(1:2));
    heightArray.iDistance(n-1)= norm(innerSub(1:2));
    %% Update waitbar
    waitbar(n/num);
end
%% Close waitbar
close(h);