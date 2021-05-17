function splitStack(filename, output_directory)
%%Split an image stack into individual images into the output directory

%check if directory exists
if ~(7 == exist(output_directory, 'dir'))
    %if not, make the directory in the current directory
    mkdir(output_directory);
    warning('Creating %s in %s directory',...
        output_directory, pwd);
end
[~, basename, ~] = fileparts(filename);
info = imfinfo(filename);
num_images = numel(info);
for n = 1:num_images
    im = imread(filename, n);
    if n < 10
        newname = sprintf('%s_00%d.tif', basename, n);
    elseif n < 100
        newname = sprintf('%s_0%d.tif', basename, n);
    elseif n < 1000
        newname = sprintf('%s_%d.tif', basename, n);
    end
    imwrite(im, fullfile(output_directory, newname), 'tif');
end
