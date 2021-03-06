function heightArray = spotHeight(dataCell, regionSize, spbChannel)
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
%
%   Outputs :
%       heightArray = Structural array containing the spot heights, in
%       pixels, of the two kinetochore foci, the two SPB foci, each
%       foci's Gaussian fit R squared value for post hoc filtering, 2D
%       spindle length, and 2D kkdistance.

%% Loop over data in dataCell
%pre-allocate structural array
num = size(dataCell,1) - 1;
heightArray.kHeights1 = zeros([num, 1]);
heightArray.kHeights2 = zeros([num, 1]);
heightArray.sHeights1 = zeros([num, 1]);
heightArray.sHeights2 = zeros([num, 1]);
heightArray.kHeightsRsq1 = zeros([num, 1]);
heightArray.kHeightsRsq2 = zeros([num, 1]);
heightArray.sHeightsRsq1 = zeros([num, 1]);
heightArray.sHeightsRsq2 = zeros([num, 1]);
heightArray.sLengths = zeros([num,1]);
heightArray.kkDistance=zeros([num,1]);
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
    %% Assign spots to kinet or spb variables
    if spbChannel == 1
        spb1 = ch1spt1(1:3);
        spb2 = ch1spt2(1:3);
        kinet1 = ch2spt1(1:3);
        kinet2 = ch2spt2(1:3);
        spbIm = dataCell{n,5};
        kinetIm = dataCell{n,6};
    elseif spbChannel == 2
        spb1 = ch2spt1(1:3);
        spb2 = ch2spt2(1:3);
        kinet1 = ch1spt1(1:3);
        kinet2 = ch1spt2(1:3);
        kinetIm = dataCell{n,5};
        spbIm = dataCell{n,6};
    else
        error('Variable spbChannel must be either 1 or 2');
    end
    %% Extract the in-focus planes of all the recorded spots
    imKinet1 = extractFoci(kinet1, kinetIm, regionSize);
    imKinet2 = extractFoci(kinet2, kinetIm, regionSize);
    imSpb1 = extractFoci(spb1, spbIm, regionSize);
    imSpb2 = extractFoci(spb2, spbIm, regionSize);
    %% Rotate the foci images
    spbSub = spb1 - spb2;
    kkSub = kinet1-kinet2;
    theta = atan2(spbSub(1), spbSub(2));
    rotKinet1 = imrotate(imKinet1, rad2deg(theta));
    rotKinet2 = imrotate(imKinet2, rad2deg(theta));
    rotSpb1 = imrotate(imSpb1, rad2deg(theta));
    rotSpb2 = imrotate(imSpb2, rad2deg(theta));
    %% Calculate the FWHM of the rotated images
    [heightArray.kHeights1(n-1), heightArray.kHeightsRsq1(n-1)] = calcFwhm(rotKinet1);
    [heightArray.kHeights2(n-1), heightArray.kHeightsRsq2(n-1)] = calcFwhm(rotKinet2);
    [heightArray.sHeights1(n-1), heightArray.sHeightsRsq1(n-1)] = calcFwhm(rotSpb1);
    [heightArray.sHeights2(n-1), heightArray.sHeightsRsq2(n-1)] = calcFwhm(rotSpb2);
    %% Calculate the 2D Spindle Length in Pixels
    heightArray.sLengths(n-1) = norm(spbSub(1:2));
    heightArray.kkDistance(n-1)= norm(kkSub(1:2));
    %% Update waitbar
    waitbar(n/num);
end
%% Close waitbar
close(h);