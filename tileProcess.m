function tileProcess(input_dir, output_dir, label_cell, trans_idx, file_prefix)
%% tileProcess parses a directory of Nikon Scan Tiles for CellStar Selection
%
%   input :
%       input_dir : A string variable specifying the directory to parse
%
%       output_dir : A string variable specifying the directory to output
%       the compiled hyperstack to. NOTE, must be relative to cwd or
%       absolute.
%
%       label_cell : A cell array containing the labels for each channel.
%       Order should correspond to channel order of image acquisition.
%
%       trans_idx : A scalar variable specifying which channel is the
%       transmitted light channel, i.e. 1.
%
%       file_prefix : A character array specifying the file prefix to
%       append to the beginning of each ouput filename, i.e.
%       'benomyl_001_'.

%% Parse the number of Z-steps and number of channels
[height, width, num_z, num_c, file_S] = parseTileSizes(input_dir);
im_mat = zeros([height, width, num_z, num_c, numel(file_S)/num_z]);
z_idx = 1;
r_cnt = 1;
r_h = waitbar(0, 'Parsing tile stacks...');
for n = 1:numel(file_S)
    im_mat(:,:,z_idx,:,r_cnt) = ...
        readTiffStack(fullfile(file_S(n).folder, file_S(n).name));
    z_idx = z_idx + 1;
    if z_idx > num_z
        r_cnt = r_cnt + 1;
        z_idx = 1;
    end
    waitbar(n/numel(file_S));
end
close(r_h);
%% Check bit depth and convert im_mat
info = imfinfo(fullfile(file_S(n).folder, file_S(n).name));
if info(1).BitDepth == 16
    im_mat = uint16(im_mat);
elseif info(1).BitDepth == 8
    im_mat = uint8(im_mat);
else
    error('Image Bit Depth was %d', info(1).BitDepth);
end
%% Save channels
%only save middle plane of trans channel and save median trans image
w_h = waitbar(0, 'Writing channel stacks..');
w_cnt = 0;
max_w_cnt = size(im_mat, 5) * size(im_mat, 4);
mid_z = ceil(num_z/2);
for c = 1:num_c
    pathname = fullfile(output_dir, strcat(file_prefix, label_cell{c}, '.tif'));
    if c == trans_idx
        trans_mat = im_mat(:,:,mid_z,c,:);
        med_trans = median(reshape(trans_mat, size(trans_mat,1), size(trans_mat,2), []), 3);
        med_trans_full = fullfile(output_dir, strcat(file_prefix, 'med_trans.tif'));
        imwrite(med_trans, med_trans_full, 'tiff');
    end
    for n = 1:size(im_mat, 5)
        if c == trans_idx
            if n == 1
                imwrite(im_mat(:,:,mid_z,c,n), pathname, 'tiff');
            else
                imwrite(im_mat(:,:,mid_z,c,n), pathname, 'tiff', 'WriteMode', 'append');
            end
        else
            for z = 1:num_z
                if n == 1 && z == 1
                    imwrite(im_mat(:,:,z,c,n), pathname, 'tiff');
                else
                    imwrite(im_mat(:,:,z,c,n), pathname, 'tiff', 'WriteMode', 'append');
                end
            end
        end
        w_cnt = w_cnt + 1;
        waitbar(w_cnt/max_w_cnt);
    end
end
close(w_h);
