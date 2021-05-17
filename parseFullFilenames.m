function fullFilenameCell = parseFullFilenames(directory, stringPattern)
%Generate a natural sorted list of full filenames(filepath and filename)
%   Inputs :
%           directory : String containing the full path to the directory
%           containing the files you want to parse
%
%           stringPattern : String used to identify which filenames to
%           collect. Used as string pattern when calling dir().
%
%   Output :
%           fullFilenameCell : A cell array containing the full filenames
%           of each file that matches the stringPattern.

%parse files using dir
fileStruct = dir(strcat(directory, filesep, stringPattern));
%preallocate cell array to store full filenames
fullFilenameCell = cell(numel(fileStruct),1);
for n = 1:numel(fileStruct)
    try %try using folder field, not available in older versions
        fullFilenameCell{n} = fullfile(fileStruct(n).folder, fileStruct(n).name);
    catch %if that doesn't work, use the input directory
        returnDir = pwd;
        cd(directory);
        directory = pwd; %ensured directory variable is an absolute path
        cd(returnDir);
        fullFilenameCell{n} = fullfile(directory, fileStruct(n).name);
    end
end
%sort the filenames into natural language order
fullFilenameCell = sort_nat(fullFilenameCell);
