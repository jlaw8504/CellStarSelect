root_directory = 'Z:\John\rrm3_CEN15_Lac_GFP\KBY8065_YPD_11082021';
trans_filename = 'KBY065_YPD_11082021_002_Trans.tif';
trans_filepath = fullfile(root_directory, trans_filename);
stack_filepath_1 = fullfile(root_directory, strrep(trans_filename, 'Trans', 'GFP'));
stack_filepath_2 = fullfile(root_directory, strrep(trans_filename, 'Trans', 'RFP'));
clear root_directory trans_filename;
