function parameters =  batchCellStar(transImageDir, filePattern, destDirSeg, bgImageFullFilename)
%%Run CellStar in batch mode
% Inputs :
%       fullFilenames : Cell array containing the full filnames
%       (filpath/filename) of all the DIC images to segment using CellStar
%
%       destDirSeg : Directory where the segmentation mat files and the
%       images will be stored
%
%       bgImageFullFilename : String of the full filename of the DIC image
%       of the background (no cells in the image)

%Initialize paramters structure array for CellStar segmentation
%Given pixel size of ~64.5, an 'average' cell diameter of 95 equals
%roughly 6 microns
%UPDATE JANUARY 28, 2019, KEEPS PICKING SUBSTRUCTURES INSIDE CELLS
%USING 140 PIXELS TO SKEW SELECTION HIGHER
parameters = DefaultParameters('precision', 20, 'avgCellDiameter', 95);
parameters.debugLevel = 2;
parameters.files.destinationDirectory = destDirSeg;
parameters.files.background.imageFile = bgImageFullFilename;
%parse the transImageDirectory for images
fullFilenamesCell = parseFullFilenames(transImageDir, filePattern);
parameters.files.imagesFiles = fullFilenamesCell;
%specifiy the maximum number of clusters on current parpool profile
clusterProfileStruct = parcluster;
parameters.maxThreads = clusterProfileStruct.NumWorkers;
parameters = CompleteParameters(parameters);
parameters = RunSegmentation(parameters);