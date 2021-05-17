function structOutput = groupAnalysis(structArray)
%%groupAnalysis Performs 1-way ANOVA and multcompare on each field of a
%%structure array.
%
%       input :
%           structArray : A structure array where each field is the output
%           from spotHeightStructure.
%
%       output : 
%           A structure array containing the input strucutre array in
%           the "data" field and the summary statistics from the 1-way
%           ANOVA and the multcompare function calls in the "analysis"
%           field.

%% Parse field names to iterate over
fnames = fieldnames(structArray);
dataSizes = zeros([numel(fnames), 1]);
%% Pre-allocate labelCell array and data vector
for n = 1:numel(fnames)
    dataSizes(n) = numel(structArray.(fnames{n}).kHnoOutnm);
end
labelCell = cell([sum(dataSizes), 1]);
data = zeros([sum(dataSizes) 1]);
%% Iterate over structure and parse labels and data
idx = 1;
for n = 1:numel(fnames)
        labelCell(idx:idx+dataSizes(n)-1,1) = repmat(fnames(n), [dataSizes(n), 1]);
        data(idx:idx+dataSizes(n)-1,1) = structArray.(fnames{n}).kHnoOutnm;
        idx = sum(dataSizes(1:n))+1;
end
%% Perform 1-way Anova and multcomp
[...
    structOutput.analysis.anovaP,...
    structOutput.analysis.anovaTab,...
    structOutput.analysis.anovaStats] =...
    anova1(data, labelCell);
figure;
[...
    structOutput.analysis.compMat,...
    structOutput.analysis.meanSEs,...
    ~,...
    structOutput.analysis.gNames] =...
    multcompare(structOutput.analysis.anovaStats);
%% Add input structure array to structOutput
structOutput.data = structArray;