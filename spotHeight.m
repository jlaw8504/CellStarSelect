function heightArray = spotHeight(dataCell, regionSize, spbChannel)
%%spotHeight Measures the spot heights of foci in the images stored in a
%%cell array generated by CellStarSelect pipeline.
%   Inputs :
%       dataCell : The cell array outputted by aggImages function
%
%   Outputs :
%       spotHeights = Matrix of spot heights where each row is a record of
%       [im1spot1, im1spot2, im2spot1, im2spot2].

%% Loop over data in dataCell
%pre-allocate structural array
num = size(dataCell,1);
heightArray.kHeights1 = zeros([num, 1]);
heightArray.kHeights2 = zeros([num, 1]);
heightArray.sHeights1 = zeros([num, 1]);
heightArray.sHeights2 = zeros([num, 1]);
heightArray.kHeightsRsq1 = zeros([num, 1]);
heightArray.kHeightsRsq2 = zeros([num, 1]);
heightArray.sHeightsRsq1 = zeros([num, 1]);
heightArray.sHeightsRsq2 = zeros([num, 1]);
%% Set up waitbar
h = waitbar(0, 'Calculating 2D Gaussians now...');
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
    fig = figure;
    subplot(2,4,1);
    imshow(imKinet1, []);
    subplot(2,4,2);
    imshow(imKinet2, []);
    subplot(2,4,3);
    imshow(imSpb1, []);
    subplot(2,4,4);
    imshow(imSpb2, []);
    %% Rotate the foci images
    spbSub = spb1 - spb2;
    theta = atan2(spbSub(1), spbSub(2));
    rotKinet1 = imrotate(imKinet1, rad2deg(theta));
    rotKinet2 = imrotate(imKinet2, rad2deg(theta));
    rotSpb1 = imrotate(imSpb1, rad2deg(theta));
    rotSpb2 = imrotate(imSpb2, rad2deg(theta));
    subplot(2,4,5);
    imshow(rotKinet1, []);
    subplot(2,4,6);
    imshow(rotKinet2, []);
    subplot(2,4,7);
    imshow(rotSpb1, []);
    subplot(2,4,8);
    imshow(rotSpb2, []);
    % Show original and rotated max projection images
    og = figure;
    subplot(2,2,1);
    imshow(max(dataCell{n,5}, [], 3),[]);
    subplot(2,2,2);
    imshow(max(dataCell{n,6}, [], 3),[]);
    rotKinet = imrotate(max(dataCell{n,5},[],3), rad2deg(theta));
    rotSpb = imrotate(max(dataCell{n,6}, [], 3), rad2deg(theta));
    subplot(2,2,3);
    imshow(rotKinet, []);
    subplot(2,2,4);
    imshow(rotSpb, []);
    waitforbuttonpress;
    close(og);
    close(fig);
    %% Calculate the FWHM of the rotated images
    [heightArray.kHeights1(n), heightArray.kHeightsRsq1(n)] = calcFwhm(rotKinet1);
    [heightArray.kHeights2(n), heightArray.kHeightsRsq2(n)] = calcFwhm(rotKinet2);
    [heightArray.sHeights1(n), heightArray.sHeightsRsq1(n)] = calcFwhm(rotSpb1);
    [heightArray.sHeights2(n), heightArray.sHeightsRsq2(n)] = calcFwhm(rotSpb2);
    %% Update waitbar
    waitbar(n/num);
end
%% Close waitbar
close(h);