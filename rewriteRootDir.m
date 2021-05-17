function rewriteRootDir(matPattern)
%%rewriteRootDir Rewrite the rootDir parameter in the spotStructArray to
%%the current location of the parsed MAT-file.
%
%   inputs :
%       matPattern : String containing the file pattern to caputre all the
%       MAT-files to parse. For Example: sprintf('*%sTrans*.mat', filesep).

%% Locate and iterate over files
files = dir(matPattern);
for n = 1:numel(files)
    load(strcat(files(n).folder, filesep, files(n).name),...
        'spotStructArray');
    spotStructArray.rootDir = files(n).folder;
    save(strcat(files(n).folder, filesep, files(n).name));
end
    
