function maxIntLoop(directory, filePattern, maxIntMatrix)
%%Display the segmented cells in a stack of maximum intensity projections
cd(directory)
fileStruct = dir(filePattern);
files = sort_nat({fileStruct(:).name});

for n = 1:size(maxIntMatrix, 3)
    load(files{n}, 'snakes');
    displaySnakes(snakes, maxIntMatrix(:,:,n))
end