function spot_struct_array = spot_detection(trans_filepath, stack_filepath_1, stack_filepath_2, z_steps, region_size, snr_threshold)

%% Collect metadata
spot_struct_array.z_steps = z_steps;
spot_struct_array.region_size = region_size;
spot_struct_array.snr_threshold = snr_threshold;
spot_struct_array.root_dir = fileparts(trans_filepath);
[~,stack_basename_1, ext_1] = fileparts(stack_filepath_1);
[~,stack_basename_2, ext_2] = fileparts(stack_filepath_2);
[~,trans_basename, ext_trans] = fileparts(trans_filepath);
spot_struct_array.stack_filename_1 = strcat(stack_basename_1, ext_1);
spot_struct_array.stack_filename_2 = strcat(stack_basename_2, ext_2);
spot_struct_array.trans_filename = strcat(trans_basename, ext_trans);
%% Parse fluorescent image stacks and convert to matrices
% since GFP and RFP MUST HAVE THE SAME NUMBER of IMAGE PLANES!!!
info_1 = imfinfo(stack_filepath_1);
num_images = numel(info_1);
%pre-allocate matrices
im_mat_1 = zeros([info_1(1).Height, info_1(1).Width, num_images]);
im_mat_2 = im_mat_1;
for k = 1:num_images
    im_mat_1(:,:,k) = imread(stack_filepath_1, k);
    im_mat_2(:,:,k) = imread(stack_filepath_2, k);
end
%% Create data cell and Counter for indexing spot inside cells
spot_struct_array.data_cell(1,:) = ...
    {'Image1 Spot1','Image 1 Spot2','Image 2 Spot 1','Image2 Spot 2'};
cnt = 1;
%% Loop through each Z-stack
for n = 1:size(im_mat_1,3)/z_steps
    %parse out the z-stack
    planes = ((n-1)*z_steps)+1:n*z_steps;
    stack_1 = im_mat_1(:,:,planes);
    stack_2 = im_mat_2(:,:,planes);
    %parse out the maximum intensity planes and stacks to be interrogated
    mip_1 = max(stack_1, [], 3);
    mip_2 = max(stack_2, [], 3);
    %load the correct masks from YeaZ segmentation
    %put in a try catch loop in case no segments were found for that set
    try
        data = load(strrep(trans_filepath, '.tif', '.mat'));
    catch
        continue
    end
    %save snakes into the structure array
    spot_struct_array.polygons{n} = data;
    
    %% Locate cells with two foci in each channel
    [spots_1, spots_2, xy_list, polygon_list] = ...
        locate_two_spot_images(data, mip_1, mip_2);
    if isempty(spots_1)
        continue
    end
    bright_array_1 = zeros([size(spots_1,1),1]);
    bright_array_2 = zeros([size(spots_2,1),1]);
    bp1 = zeros(size(spots_1));
    bp2 = zeros(size(spots_2));
    
    %% Loop through all bright foci to determine brightest voxel
    for j = 1:size(spots_1)
        % Find brightest voxel in original stacks
        %image 1 spots
        [bp1(j,1),bp1(j,2),bp1(j,3),bp1(j,4)] = findVoxel(spots_1(j,:), stack_1, region_size);
        %filter out dim spots using signal to noise ratio threshold
        [bright_array_1(j), ~] = findBrightSpots(bp1(j,1:2), snr_threshold, stack_1(:,:,bp1(j,3)),region_size);
        
        %image 2 spots
        [bp2(j,1),bp2(j,2),bp2(j,3),bp2(j,4)] = findVoxel(spots_2(j,:), stack_2, region_size);
        [bright_array_2(j), ~] = findBrightSpots(bp2(j,1:2), snr_threshold, stack_1(:,:,bp2(j,3)), region_size);
        
    end
    %% combine the brightArrays
    all_bright = and(bright_array_1, bright_array_2);
    %Loop through the allBright array. Since each spot is paired with the
    %spot directly below it (i.e, 1 with 2, 3 with 4, etc). Need to filter
    %out incomplete sets entirely
    filter_array = zeros(size(all_bright));
    for i = 1:2:size(all_bright)
        filter_array(i,1) = and(all_bright(i), all_bright(i+1));
        filter_array(i+1,1) = filter_array(i);
    end
    %convert filterArray to logical
    filter_array = logical(filter_array);
    if sum(filter_array) > 0
        brights_1 = bp1(filter_array,:);
        brights_2 = bp2(filter_array,:);
        brights_xy = xy_list(filter_array(1:2:end));
        brights_polygon = polygon_list(filter_array(1:2:end));
    else
        continue
    end
    %% Loop through all bright foci to determine brightest voxel
    for j = 1:2:size(brights_1,1)
        %convert plane to total stack index
        %image 1 spot 1
        brights_1(j,3) = ((n-1)*z_steps)+brights_1(j,3);
        spot_struct_array.data_cell{cnt+1,1} = brights_1(j,:);
        %image 1 spot 2
        brights_1(j+1,3) = ((n-1)*z_steps)+brights_1(j+1,3);
        spot_struct_array.data_cell{cnt+1,2} = brights_1(j+1,:);
        %image 2 spot 1
        brights_2(j,3) = ((n-1)*z_steps)+brights_2(j,3);
        spot_struct_array.data_cell{cnt+1,3} = brights_2(j,:);
        %image 2 spot 2
        brights_2(j+1,3) = ((n-1)*z_steps)+brights_2(j+1,3);
        spot_struct_array.data_cell{cnt+1,4} = brights_2(j+1,:);
        %Index the xyPoly and inPoly variables
        %adjust index since there are half values as img1Brights
        spot_struct_array.xy_list{cnt} = brights_xy{ceil(j/2)};
        spot_struct_array.polygon_list{cnt} = brights_polygon{ceil(j/2)};
        %update data_cell counter
        cnt = cnt + 1;
    end
end

