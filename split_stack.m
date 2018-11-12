function split_stack(filename, output_directory)
%%Split an image stack into individual images in the output directory

stk_cell = bfopen(filename);
im_stack = bf2mat(stk_cell);
[~, basename, ~] = fileparts(filename);
for n = 1:size(im_stack,3)
    if n < 10
        newname = sprintf('%s_00%d.tif', basename, n);
    elseif n < 100
        newname = sprintf('%s_00%d.tif', basename, n);
    elseif n < 1000
        newname = sprintf('%s_0%d.tif', basename, n);
    end
    imwrite(im_stack(:,:,n), fullfile(output_directory, newname), 'tif');
end