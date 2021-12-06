function all_data_cell = agg_images(mat_pattern)
%aggImages Aggreated coordinate information and filtered image stacks into
%a single cell array
%   Function loops over all the MAT files contianing the spotStructArray
%   variable and uses that stored information to parse image stacks to
%   aggregate both the coordinate information and filtered image stacks
%   into the cell array imageCell.

%% Use matPattern in to identify MAT file of interest
mat_files = dir(mat_pattern);
%% Loop through matFiles to determine proper cell array size
num = 0;
for i = 1:numel(mat_files)
    full_filename = fullfile(mat_files(i).folder, mat_files(i).name);
    load(full_filename, 'spot_struct_array');
    data_cell = spot_struct_array.data_cell;
    data_num = size(data_cell,1) - 1;
    num = num + data_num;
end
%% Create allDataCell array
all_data_cell = cell([num + 1, size(data_cell,2)]); % +1 is for label row
all_data_cell(1,:) = data_cell(1,:);
all_data_cell(1,5) = {'subStack1'};
all_data_cell(1,6) = {'subStack2'};
all_data_cell(1,7) = {'subTrans'};
%% Loop through all files again to place the data in allDataCell
%instantiate counter
cnt = 2; % to prevent label row overwrite
%% Waitbar
h = waitbar(0, 'Parsing MAT files and images now');
for n = 1:numel(mat_files)
    full_filename = fullfile(mat_files(n).folder, mat_files(n).name);
    load(full_filename, 'spot_struct_array');
    %% Load in the GFP, RFP and Trans Stacks
    stack1 = readTiffStack(fullfile(spot_struct_array.root_dir, spot_struct_array.stack_filename_1));
    stack2 = readTiffStack(fullfile(spot_struct_array.root_dir, spot_struct_array.stack_filename_2));
    trans = readTiffStack(fullfile(spot_struct_array.root_dir, spot_struct_array.trans_filename));
    for i = 1:(size(spot_struct_array.data_cell,1)-1)
        all_data_cell(cnt,1:4) = spot_struct_array.data_cell(i+1,:);
        %Trans image plan index, AKA zstack index
        poly_idx = ceil(all_data_cell{cnt,1}(3)/spot_struct_array.z_steps);
        %Pull out all xyPolys and inPolys for that zstack index
        xy_poly = spot_struct_array.xy_list{i};
        in_poly = spot_struct_array.polygon_list{i};
        %% Create 3D filter
        planes = ((poly_idx-1)*spot_struct_array.z_steps)+1:...
            poly_idx*spot_struct_array.z_steps;
        %% Crop images
        sub_stack1 = stack1(xy_poly(1):xy_poly(1)+size(in_poly,1)-1,...
            xy_poly(2):xy_poly(2)+size(in_poly,2)-1,planes);
        %zStack2 = stack2(:,:,planes) .* stackPoly;
        sub_stack2 = stack2(xy_poly(1):xy_poly(1)+size(in_poly,1)-1,...
            xy_poly(2):xy_poly(2)+size(in_poly,2)-1,planes);
        %subTrans = trans(:,:,polyIdx) .* padPoly;
        sub_trans = trans(xy_poly(1):xy_poly(1)+size(in_poly,1)-1,...
            xy_poly(2):xy_poly(2)+size(in_poly,2)-1, poly_idx);
        %% Correct addDataCell Coordinates
        for j = 1:4
            new_coords = all_data_cell{cnt,j} - ...
                [xy_poly(1)-1, ...
                xy_poly(2)-1, ...
                ((poly_idx -1 ) * spot_struct_array.z_steps),...
                0];
            all_data_cell(cnt,j) = {new_coords};
        end
        all_data_cell{cnt,5} = sub_stack1;
        all_data_cell{cnt,6} = sub_stack2;
        all_data_cell{cnt,7} = sub_trans;
        cnt = cnt +1;
        waitbar(cnt/num);
    end
end
%% Close waitbar
close(h);
end
