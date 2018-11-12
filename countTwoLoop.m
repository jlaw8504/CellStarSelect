function totalCount = countTwoLoop(directory, filePattern,...
    maxIntMatrix1, maxIntMatrix2)
%%Count the number of segments with two spots in maxIntMatrix1 and
%%maxIntMatrix2

%Instantiate totalCount
totalCount = 0;

cd(directory)
fileStruct = dir(filePattern);
files = sort_nat({fileStruct(:).name});

for n = 1:size(maxIntMatrix1, 3)
    load(files{n}, 'snakes');
    count = countTwoSpotImages(snakes, maxIntMatrix1(:,:,n),...
        maxIntMatrix2(:,:,n));
    totalCount = totalCount + count;
end