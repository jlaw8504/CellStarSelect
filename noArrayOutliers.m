function [arrayNoOutliers,Outliers] = noArrayOutliers(array)
%%noArrayOutliers Removes the outliers from an array using isoutlier
%%function in a while loop.
%
%   inputs :
%       array : One-dimesional array of numerical values.
%
%   outputs :
%       arrayNoOutliers : One-dimensional array of numerical values without
%       outliers.

numOutliers = sum(isoutlier(array));
if numOutliers == 0
    arrayNoOutliers = array;
    Outliers = [];
else
    arrayNoOutliers = array;
    Outliers = ind2sub(size(array),find(isoutlier(array)));
    while numOutliers > 0
        arrayNoOutliers = arrayNoOutliers(~isoutlier(arrayNoOutliers));
        numOutliers = sum(isoutlier(arrayNoOutliers));
    end
end
end