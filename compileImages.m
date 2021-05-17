function compileImages(dataCell, directory, greenChannel, redChannel)
%%compileImages Generates color-combined, RGB images from dataCell array in
%%a specified directory
%   inputs :
%       dataCell : Cell array outputted by CellStarSelect pipeline
%
%       directory : Directory to which the images will be written.
%
%       greenChannel : Either 1 or 2, specifying which subStack should be
%       green.
%
%       redChannel : Either 1 or 2, specifying which subStack should be
%       red. This channel is used to center images upon cropping.
%% Parameter checks
if greenChannel == redChannel
    error('The greenChannel cannot be the same as the redChannel!');
end
if not(greenChannel == 1 || greenChannel == 2) ||...
        not(redChannel ==1 || redChannel == 2)
    error('The greenChannel and redChannel variables are specified as 1 or 2');
end
%check if directory exists, if not make it
if ~(exist(directory, 'dir'))
    warning('Warning: %s does not exist. Creating it withing %s', directory, pwd);
    mkdir(directory)
end

%% Loop through dataCell array
for n = 2:size(dataCell,1)
    if greenChannel == 1 && redChannel == 2
        green = dataCell{n,5};
        red = dataCell{n,6};
    else
        red = dataCell{n,5};
        green = dataCell{n,6};
    end
    %greenMax = max(green, [], 3);
    %redMax = max(red, [], 3);
    if greenChannel == 1
        gp1 = dataCell{n,1}(3);
        gp2 = dataCell{n,2}(3);
        rp1 = dataCell{n,3}(3);
        rp2 = dataCell{n,4}(3);
    else
        gp1 = dataCell{n,3}(3);
        gp2 = dataCell{n,4}(3);
        rp1 = dataCell{n,1}(3);
        rp2 = dataCell{n,2}(3);
    end
    greenSum = green(:,:,gp1) + green(:,:,gp2);
    redSum = red(:,:,rp1) + red(:,:,rp2);
    %% Double Otsu Threshold
    gThresh1 = multithresh(greenSum);
    rThresh1 = multithresh(redSum);
    greenSum(greenSum < gThresh1) = nan;
    redSum(redSum < rThresh1) = nan;
    gThresh2 = multithresh(greenSum);
    rThresh2 = multithresh(redSum);
    greenSum(greenSum < gThresh2) = nan;
    redSum(redSum < rThresh2) = nan;
    greenSum(isnan(greenSum)) = 0;
    redSum(isnan(redSum)) = 0;
    %% Wiener2 filtering
    greenSub = uint16(greenSum) - multithresh(greenSum(:));
    redSub = uint16(redSum) - multithresh(redSum(:));
    greenFilt = wiener2(greenSub);
    redFilt = wiener2(redSub);
    
    %% Pad images by 25 on all sides with zeros
    greenPad = padarray(greenFilt, [25, 25], 'both');
    redPad = padarray(redFilt, [25, 25], 'both');
    %find center of red channel (spindle channel)
    if redChannel == 1
        center = round((dataCell{n,1}(1:2) + dataCell{n,2}(1:2))/2);
    elseif redChannel == 2
        center = round((dataCell{n,3}(1:2) + dataCell{n,4}(1:2))/2);
    end
    %Crop out a 50x50 pixel region
    % since padded by 25, can use original center coordinates since they
    % are already shifted by 25, but must adjust the larger coordinate
    % values by 24 + 25.
    greenCrop = greenPad(center(1):center(1)+49,center(2):center(2)+49);
    redCrop = redPad(center(1):center(1)+49,center(2):center(2)+49);
    greenDbl = double(greenCrop);
    redDbl = double(redCrop);
    greenFinal = (greenDbl/max(greenDbl(:))).*(2^16 - 1);
    redFinal = (redDbl/max(redDbl(:))).*(2^16 - 1);
    %% Rotate the images by 45 degrees
    for i = 0:7
        greenFinal = imrotate(greenFinal, i*45, 'crop');
        redFinal = imrotate(redFinal, i*45, 'crop');
        
        %Cat matrices and save an RGB tiff image
        rgb = cat(3, uint16(redFinal), uint16(greenFinal),...
            uint16(zeros(size(redFinal)))); %blue channel is blank with 0s
        %Zero pad name string
        if n < 10
            name = sprintf('image_00%d_%d.tif', n-1, i+1);
        elseif n < 100
            name = sprintf('image_0%d_%d.tif', n-1, i+1);
        elseif n < 1000
            name = sprintf('image_%d_%d.tif', n-1, i+1);
        end
        imwrite(rgb, fullfile(directory,name), 'tiff');
    end
end

