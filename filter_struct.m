function [filter_cell, s] = filter_struct(mat_pattern, spb_channel, spindle_bounds, z_tilt, skew_thresh, pixel_size)
%%radialDispStruct Creates a structural array containing all the
%%information needed to calculate radial displacements of foci reative to
%%spindle axis
%
%   inputs :
%       mat_pattern : String containing the file pattern to caputre all the
%       MAT-files to parse. For Example: sprintf('*%sTrans*.mat', filesep)
%
%       spb_channel : Integer specifying which chanell in the dataCell
%       variable contains images of the spindle pole bodies (SPBs).
%
%       spindle_bounds : Vector containing the [min max] spindle lengths you
%       wish to collect. Note spindle length is calculated using X and Y
%       dimensions only.
%
%       z_tilt : Integer specifying how many zPlanes the SPBs can be
%       separated by.
%
%       skew_thresh : A numeric variable indicating how skewed the foci
%       signal intensity histogram must be. Suggested value of 0.5.
%
%       pixel_size : The size of a pixel in nanometers.
%
%   output :
%       s : A structure array contianing the following fields:
%           s.allDataCell : The cell array outputted by aggImages function
%
%       filter_cell : A cell array filtered by the spindle length,
%       specified by spindleBounds, and zTilt.

%% Store input variables
s.mat_pattern = mat_pattern;
s.spb_channel = spb_channel;
s.spindle_bounds = spindle_bounds;
s.z_tilt = z_tilt;
s.skew_thresh = skew_thresh;
s.pixel_size = pixel_size;
%% Data parsing and filtering
s.all_data_cell = agg_images(s.mat_pattern);
s.filter_cell = filterSlength(...
    s.all_data_cell, s.spb_channel, s.spindle_bounds, s.z_tilt, s.pixel_size);
s.filter_cell = filterPosition(s.filter_cell, s.spb_channel, 10);
s.filter_cell = filterFoci(s.filter_cell, s.skew_thresh);
filter_cell = s.filter_cell;
