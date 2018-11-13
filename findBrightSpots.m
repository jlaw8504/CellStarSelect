function [ brightArray, snrArray ] = findBrightSpots( imgSpots, snrThreshold, img, regionSize )
%findBrightSpots filters out spots in max intensity projection images less
%than specified signal-to-noise threshold
%   Inputs :
%       imgSpots : Matrix of spot positions. Row represents a spot. Columns
%       are Y (row) position and X (column) position
%
%       snrThreshold : The threshold value of the signal to noise ratio
%
%       img : Image plane. Usually maximum intensity projection.
%
%       regionSize : Integer value of the length/width of the square region
%       used to crop the spot image.
%
%   Outputs :
%       brightArray : Binary array indicating which spots are above the
%       signal to noise threshold.
%% Calculate the mean and standard deviation of image background
%Otsu Thresholding to remove foreground from background
thresh = multithresh(img);
img_nan = img;
img_nan(img_nan > thresh) = nan; %remove foreground with nans
bg_std = std(img_nan(:), 'omitnan');
bg_mean = mean(img_nan(:), 'omitnan');

%% Determine half size of region
if mod(regionSize,2) == 0
    error('Variable regionSize must be an odd integer');
else
    halfRS = (regionSize-1)/2;
end
%% Instantiate brightArray and snrArray
brightArray = zeros([size(imgSpots,1),1]);
snrArray = zeros([size(imgSpots,1),1]);
%% Loop through each spot for evaluation
for n = 1:size(imgSpots, 1)
    spotImg = img(imgSpots(n,1)-halfRS:imgSpots(n,1)+halfRS,...
                  imgSpots(n,2)-halfRS:imgSpots(n,2)+halfRS);
    spotBgSub = spotImg - bg_mean;
    spotSNR = mean(spotBgSub(:))/bg_std;
    snrArray(n,1) = spotSNR;
    brightArray(n,1) = spotSNR > snrThreshold;

end

