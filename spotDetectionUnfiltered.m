function [ spotStructArray ] = spotDetectionUnfiltered( transFilename, transBgFullFilename, stack1Filename, stack2Filename )
%spotDetection Automatic spot detection for two channels
%

%% Parameters (later add inputParser object here)
%Directory where segmentation data of trans images will be kept
%By default use the current working directory and the transFilename without
%extension
[~, transBasename, transExt] = fileparts(transFilename);
spotStructArray.transOutDir = strcat(pwd, filesep, transBasename);

%filePattern to parse the trans images from the directory.
spotStructArray.filePattern = strcat(transBasename,'*', transExt);

%Root Directory
spotStructArray.rootDir = pwd;

%destDirSeg : destination of segmentation images and mat files
%By default put that information inside the transOutDir in a folder called
%segments
spotStructArray.destDirSeg = strcat(spotStructArray.transOutDir, filesep, ...
    'segments');

%Put transBgFullFilename into the spotStructArray
spotStructArray.transBgFullFilename = transBgFullFilename;

%Z-steps : number Z-planes per image series
%set to 7 by default
spotStructArray.zsteps = 7;

%Signal to Noise ratio threshold
spotStructArray.snrThreshold = 10;

%Region Size (side of a square) for filtering out one foci from another
spotStructArray.regionSize = 7;

%% Split the trans stacks into individual images
splitStack(transFilename, spotStructArray.transOutDir)

%% Run Cell star on all of the individual images
spotStructArray.parameters =  batchCellStar(...
    spotStructArray.transOutDir, spotStructArray.filePattern,...
    spotStructArray.destDirSeg, spotStructArray.transBgFullFilename);

%% Parse fluorescent image stacks and convert to matrices
im1Cell = bfopen(stack1Filename);
im1Mat = bf2mat(im1Cell);
im2Cell = bfopen(stack2Filename);
im2Mat = bf2mat(im2Cell);

%% Create the max intensity projections from images
im1Mip = maxIntensityProjection(stack1Filename);
im2Mip = maxIntensityProjection(stack2Filename);

%simple error check to ensure two channels have same sizes
if ~(sum(size(im1Mip) == size(im2Mip)) == 3)
    error('%s and %s do not have same size!', stack1Filename, stack2Filename);
end

%% Create data cell and Counter for indexing spot inside cells
spotStructArray.dataCell(1,:) = ...
    {'Image1 Spot1','Image 1 Spot2','Image 2 Spot 1','Image2 Spot 2'};
cnt = 1;

%% Loop through each Z-stack
for n = 1:size(im1Mip, 3)
    %parse out the maximum intensity planes and stacks to be interrogated
    mip1 = im1Mip(:,:,n);
    mip2 = im2Mip(:,:,n);
    %parse out the z-stack
    planes = ((n-1)*spotStructArray.zsteps)+1:n*spotStructArray.zsteps;
    imgStack1 = im1Mat(:,:,planes);
    imgStack2 = im2Mat(:,:,planes);
    %load the correct snakes file from the CellStar segmentation
    if n < 10
        data = load(strcat(spotStructArray.destDirSeg, filesep,...
            transBasename, '_00', num2str(n), '_segmentation.mat'), 'snakes');
    elseif n < 100
        data = load(strcat(spotStructArray.destDirSeg, filesep,...
            transBasename, '_0', num2str(n), '_segmentation.mat'), 'snakes');
    elseif n < 1000
        data = load(strcat(spotStructArray.destDirSeg, filesep,...
            transBasename, '_', num2str(n), '_segmentation.mat'), 'snakes');
    end
    %save snakes into the structure array
    spotStructArray.snakes{n} = data.snakes;
    
    %% Locate cells with two foci in each channel
    [img1Spots, img2Spots] = locateTwoSpotImages(data.snakes, mip1, mip2);
    
%     %% Filter out the dim signals
%     [brightArray1, ~] = findBrightSpots(img1Spots, spotStructArray.snrThreshold, mip1, spotStructArray.regionSize);
%     [brightArray2, ~] = findBrightSpots(img2Spots, spotStructArray.snrThreshold, mip2, spotStructArray.regionSize);
%     %combine the brightArrays
%     allBright = and(brightArray1, brightArray2);
%     %Loop through the allBright array. Since each spot is paired with the
%     %spot directly below it (i.e, 1 with 2, 3 with 4, etc). Need to filter
%     %out incomplete sets entirely
%     filterArray = zeros(size(allBright));
%     for i = 1:2:size(allBright)
%         filterArray(i,1) = and(allBright(i), allBright(i+1));
%         filterArray(i+1,1) = filterArray(i);
%     end
%     %convert filterArray to logical
%     filterArray = boolean(filterArray);
%     if sum(filterArray) > 0
%         img1Brights = img1Spots(filterArray,:);
%         img2Brights = img2Spots(filterArray,:);
%     else
%         continue
%     end
    %% Loop through all bright foci to determine brightest voxel
    for j = 1:2:size(img1Spots,1)
        
        %% Find brightest voxel in original stacks
        %image 1 spot 1
        [Y,X,plane,peakIntensity] = findVoxel(img1Spots(j,:), imgStack1, spotStructArray.regionSize);
        %convert plane to total stack index
        stackPlane = ((n-1)*spotStructArray.zsteps)+plane;
        spotStructArray.dataCell{cnt+1,1} = [X, Y, stackPlane, peakIntensity];
        %image 1 spot 2
        [Y,X,plane,peakIntensity] = findVoxel(img1Spots(j+1,:), imgStack1, spotStructArray.regionSize);
        stackPlane = ((n-1)*spotStructArray.zsteps)+plane;
        spotStructArray.dataCell{cnt+1,2} = [X, Y, stackPlane, peakIntensity];
        %image 2 spot 1
        [Y,X,plane,peakIntensity] = findVoxel(img2Spots(j,:), imgStack2, spotStructArray.regionSize);
        stackPlane = ((n-1)*spotStructArray.zsteps)+plane;
        spotStructArray.dataCell{cnt+1,3} = [X, Y, stackPlane, peakIntensity];
        %image 2 spot 2
        [Y,X,plane,peakIntensity] = findVoxel(img2Spots(j+1,:), imgStack2, spotStructArray.regionSize);
        stackPlane = ((n-1)*spotStructArray.zsteps)+plane;
        spotStructArray.dataCell{cnt+1,4} = [X, Y, stackPlane, peakIntensity];
        %update dataCell counter
        cnt = cnt + 1;
    end
end
end