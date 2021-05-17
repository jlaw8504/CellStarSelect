function h = drawHeatmap(X, Y, pixelSize, varargin)

%% Default values
defXdim = ceil(max(X)/pixelSize);
defYdim = ceil(max(Y)/pixelSize);

%% inputParser object
p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
validWholePosNum = @(x) isnumeric(x) && mod(x,1) == 0 && (x > 0);
validArray = @(x) isvector(x) && not(isempty(x));
addRequired(p,'X', validArray);
addRequired(p,'Y', validArray);
addRequired(p,'pixelSize', validScalarPosNum);
addParameter(p, 'xDim', defXdim, validWholePosNum);
addParameter(p, 'yDim', defYdim, validWholePosNum);
parse(p,X,Y,pixelSize,varargin{:});
%% Pull out values from inputParser object
%This is just for readability
xDim = p.Results.xDim;
yDim = p.Results.yDim;
%% Instantiate hMat matrix and loop over each index
hMat = zeros([yDim, xDim]);
for m = 1:yDim
    for n = 1:xDim
        filter = (X <= n*pixelSize) & (Y <= m*pixelSize);
        hMat(m,n) = sum(filter);
        X(filter) = nan;
        Y(filter) = nan;
    end
end
hFlip = flipud(hMat);
h = [hFlip;hMat];
figure;
imagesc(h./max(h(:)));
colorbar;
colormap hot;
xticks = 0.5:1:xDim+0.5;
xvals = round((0:xDim)*pixelSize);
xlabels = arrayfun(@num2str, xvals, 'UniformOutput', 0);
yticks = 0.5:1:(yDim*2)+0.5;
yvals = fliplr(round((-yDim:yDim)*pixelSize));
ylabels = arrayfun(@num2str, yvals, 'UniformOutput', 0);
set(gca,'XTick',xticks)
set(gca,'XTickLabel',xlabels)
set(gca,'YTick', yticks)
set(gca,'YTickLabel',ylabels)