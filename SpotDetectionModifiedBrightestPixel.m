function [ spotStructArray ] = SpotDetectionModifiedBrightestPixel( stack1Filename, stack2Filename, stack3filename )
%spotDetection Automatic spot detection for two channels
%

%% Parameters (later add inputParser object here)
%Directory where segmentation data of trans images will be kept
%By default use the current working directory and the transFilename without
%extension
%[~, transBasename, transExt] = fileparts(transFilename);
%spotStructArray.transOutDir = strcat(pwd, filesep, transBasename);

%filePattern to parse the trans images from the directory.
%spotStructArray.filePattern = strcat(transBasename,'*', transExt);

%Root Directory
spotStructArray.rootDir = pwd;

%Stack filenames
%spotStructArray.transFilename = transFilename;
spotStructArray.stack1Filename = stack1Filename;
spotStructArray.stack2Filename = stack2Filename;
spotStructArray.stack3filename = stack3filename;

%destDirSeg : destination of segmentation images and mat files
%By default put that information inside the transOutDir in a folder called
%segments
%spotStructArray.destDirSeg = strcat(spotStructArray.transOutDir, filesep, ...
%    'segments');

%Put transBgFullFilename into the spotStructArray
%spotStructArray.transBgFullFilename = transBgFullFilename;

%Z-steps : number Z-planes per image series
%set to 7 by default
spotStructArray.zsteps = 7;

%Signal to Noise ratio threshold
spotStructArray.snrThreshold = 3;

%Region Size (side of a square) for filtering out one foci from another
spotStructArray.regionSize = 7;

%Images that were kicked out becuase the spots could not be found in one of the images will be
%stored in a separate data cell
% spotStructArray.KickedOut = {};

%% Split the trans stacks into individual images
%splitStack(transFilename, spotStructArray.transOutDir)

%% Run Cell star on all of the individual images
%spotStructArray.parameters =  batchCellStar(...
%    spotStructArray.transOutDir, spotStructArray.filePattern,...
%    spotStructArray.destDirSeg, spotStructArray.transBgFullFilename);

%% Parse fluorescent image stacks and convert to matrices
% since GFP and RFP MUST HAVE THE SAME NUMBER of IMAGE PLANES!!!
info1 = imfinfo(stack1Filename);
num_images = numel(info1);
%pre-allocate matrices
im1Mat = zeros([info1(1).Height, info1(1).Width, num_images]);
im2Mat = im1Mat;
im3Mat = im1Mat;
for k = 1:num_images
    im1Mat(:,:,k) = imread(stack1Filename, k);
    im2Mat(:,:,k) = imread(stack2Filename, k);
    im3Mat(:,:,k) = imread(stack3filename, k);
end

%% Create data cell and Counter for indexing spot inside cells
spotStructArray.dataCell(1,:) = ...
    {'Image1 Spot1','Image 1 Spot2','Image 2 Spot 1','Image2 Spot 2','Image 3 Spot 1','Image 3 Spot 2'};
cnt = 1;
% counter = 1;
%% Loop through each Z-stack
for n = 1:size(im1Mat,3)/spotStructArray.zsteps
    %parse out the z-stack
    planes = ((n-1)*spotStructArray.zsteps)+1:n*spotStructArray.zsteps;
    imgStack1 = im1Mat(:,:,planes);
    imgStack2 = im2Mat(:,:,planes);
    imgStack3 = im3Mat(:,:,planes);
    mip1 = max(imgStack1, [], 3);
    mip2 = max(imgStack2, [], 3);
    mip3 = max(imgStack3, [], 3);
%     valarray1 = zeros(1,length(planes));
%     valarray2 = zeros(1,length(planes));
%     %find the maximum intensity from all the planes and return the plane
%     %with its value as the maximum intensity projection
%     for m = planes
%         valarray1(1,m) = max(max(imgStack1(:,:,m)));
%         valarray2(1,m) = max(max(imgStack2(:,:,m)));
%     end
%     for l = planes
%         if max(valarray1) == max(max(imgStack1(:,:,l)))
%             mip1 = imgStack1(:,:,l);
%         end
%         if max(valarray2) == max(max(imgStack2(:,:,l)))
%             mip2 = imgStack2(:,:,l);
%         end
%     end
    
    %load the correct snakes file from the CellStar segmentation
    %put in a try catch loop in case no segments were found for that set
    
%    if n < 10
%        data = load(strcat(spotStructArray.destDirSeg, filesep,...
%            transBasename, '_00', num2str(n), '_segmentation.mat'), 'snakes');
%    elseif n < 100
%        data = load(strcat(spotStructArray.destDirSeg, filesep,...
%            transBasename, '_0', num2str(n), '_segmentation.mat'), 'snakes');
%    elseif n < 1000
%        data = load(strcat(spotStructArray.destDirSeg, filesep,...
%            transBasename, '_', num2str(n), '_segmentation.mat'), 'snakes');
%    end
%    catch
%        continue
%    end
    %save snakes into the structure array
%     spotStructArray.snakes{n} = data.snakes;
    
    %% Locate cells with two foci in each channel
%     [img1Spots, img2Spots, xyList, polygonList] = ...
%         locateTwoSpotImagesModified(data.snakes, mip1, mip2);
    ptSrcImg1  = JustBrightestPixel(mip1);
    ptSrcImg2  = JustBrightestPixel(mip2);
    ptSrcImg3  = JustBrightestPixel(mip3);
    if (numel(find(ptSrcImg1))~=2)||(numel(find(ptSrcImg2))~=2)||(numel(find(ptSrcImg3))~=2)
%         spotStructArray.KickedOut{counter,1} = stack1Filename((length(stack1Filename)-16):end);
%         counter=counter+1;
         continue
    end
    %brightArray1 = zeros([size(img1Spots,1),1]);
    %brightArray2 = zeros([size(img2Spots,1),1]);
    %bp1 = zeros(size(img1Spots));
    %bp2 = zeros(size(img2Spots));
    %% New code replacing the locate cells with two foci code
    bp1 = zeros(2,4);
    bp2 = zeros(2,4);
    bp3 = zeros(2,4);
    brightArray1 = zeros(4,1);
    brightArray2 = zeros(4,1);
    brightArray3 = zeros(4,1);
    %% Loop through all bright foci to determine brightest voxel
    [rows1, cols1] = ind2sub(size(ptSrcImg1), find(ptSrcImg1));
    [rows2, cols2] = ind2sub(size(ptSrcImg2), find(ptSrcImg2));
    [rows3, cols3] = ind2sub(size(ptSrcImg3), find(ptSrcImg3));
    img1Spots = [rows1, cols1];
    img2Spots = [rows2, cols2];
    img3Spots = [rows3, cols3];
    for j = 1:size(img1Spots)
        % Find brightest voxel in original stacks
        %image 1 spots
        [bp1(j,1),bp1(j,2),bp1(j,3),bp1(j,4)] = findVoxelModified(img1Spots(j,:), imgStack1, spotStructArray.regionSize);
        %filter out dim spots using signal to noise ratio threshold
        [brightArray1(j), ~] = findBrightSpots(bp1(j,1:2), spotStructArray.snrThreshold, imgStack1(:,:,bp1(j,3)), spotStructArray.regionSize);
        %image 2 spots
        [bp2(j,1),bp2(j,2),bp2(j,3),bp2(j,4)] = findVoxelModified(img2Spots(j,:), imgStack2, spotStructArray.regionSize);
        [brightArray2(j), ~] = findBrightSpots(bp2(j,1:2), spotStructArray.snrThreshold, imgStack2(:,:,bp2(j,3)), spotStructArray.regionSize);
        %image 3 spots
        [bp3(j,1),bp3(j,2),bp3(j,3),bp3(j,4)] = findVoxelModified(img3Spots(j,:), imgStack3, spotStructArray.regionSize);
        [brightArray3(j), ~] = findBrightSpots(bp3(j,1:2), spotStructArray.snrThreshold, imgStack3(:,:,bp3(j,3)), spotStructArray.regionSize);
    end
    %% combine the brightArrays
    allBright = brightArray1 & brightArray2 & brightArray3;
    %Loop through the allBright array. Since each spot is paired with the
    %spot directly below it (i.e, 1 with 2, 3 with 4, etc). Need to filter
    %out incomplete sets entirely
    filterArray = zeros(size(allBright));
    for i = 1:2:size(allBright)
        filterArray(i,1) = and(allBright(i),allBright(i+1));
        filterArray(i+1,1) = filterArray(i);
    end
    %convert filterArray to logical
    filterArray = boolean(filterArray);
    if sum(filterArray) > 0
        img1Brights = bp1(filterArray,:);
        img2Brights = bp2(filterArray,:);
        img3Brights = bp3(filterArray,:);
        %xyBright = xyList(filterArray(1:2:end));
        %polyBright = polygonList(filterArray(1:2:end));
    else
        continue
    end
    %% Loop through all bright foci to determine brightest voxel
    for j = 1:2:size(img1Brights,1)
        %convert plane to total stack index
        %image 1 spot 1
        img1Brights(j,3) = ((n-1)*spotStructArray.zsteps)+img1Brights(j,3);
        spotStructArray.dataCell{cnt+1,1} = img1Brights(j,:);
        %image 1 spot 2
        img1Brights(j+1,3) = ((n-1)*spotStructArray.zsteps)+img1Brights(j+1,3);
        spotStructArray.dataCell{cnt+1,2} = img1Brights(j+1,:);
        %image 2 spot 1
        img2Brights(j,3) = ((n-1)*spotStructArray.zsteps)+img2Brights(j,3);
        spotStructArray.dataCell{cnt+1,3} = img2Brights(j,:);
        %image 2 spot 2
        img2Brights(j+1,3) = ((n-1)*spotStructArray.zsteps)+img2Brights(j+1,3);
        spotStructArray.dataCell{cnt+1,4} = img2Brights(j+1,:);
        %image 3 spot 1
        img3Brights(j,3) = ((n-1)*spotStructArray.zsteps)+img3Brights(j,3);
        spotStructArray.dataCell{cnt+1,5} = img3Brights(j,:);
        %image 3 spot 2
        img3Brights(j+1,3) = ((n-1)*spotStructArray.zsteps)+img3Brights(j+1,3);
        spotStructArray.dataCell{cnt+1,6} = img3Brights(j+1,:);
        %Index the xyPoly and inPoly variables
        %adjust index since there are half values as img1Brights
        %spotStructArray.xyList{cnt} = xyBright{ceil(j/2)};
        %spotStructArray.polygonList{cnt} = polyBright{ceil(j/2)};
        %update dataCell counter
        cnt = cnt + 1;
    end
end
end