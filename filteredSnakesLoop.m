function filteredSnakesLoop(directory, filePattern, maxIntMatrix1, maxIntMatrix2)
%%Display the segmented cells in a stack of maximum intensity projections
cd(directory)
fileStruct = dir(filePattern);
files = sort_nat({fileStruct(:).name});

for n = 1:size(maxIntMatrix1, 3)
    display(files{n});
    load(files{n}, 'snakes');
    displayFilteredSnakes(snakes, maxIntMatrix1(:,:,n), maxIntMatrix2(:,:,n))
end