function [fwhmX, fwhmY, rsq] = calcFwhm(fociIm)
%%clacFwhm Calculate the full-width half-max in X and Y of an image of a
%%foci
%% parse the middle 7 columns (X) from fociIm and middle 15 rows (Y)
%The foci are centered around the brightest pixel
if mod(size(fociIm,1), 2) == 0
    mid = (size(fociIm,1))/2;
else
    mid = size(fociIM,1) + 1/2;
end
midFoci = fociIm(mid-7:mid+7, mid-3:mid+3);
%% Collapse midFoci into 1D array and process for fitting
sumY = sum(midFoci,2);
subVal = mean([sumY(1), sumY(end)]);
subY = sumY - subVal;
%% Fit 2D gaussian to fociIm
[fitresult, gof] = fit2dGauss(0:size(fociIm,2)-1, 0:size(fociIm,1)-1, midFoci);
%% Extract sigmaX and sigmaY
coefficients = coeffvalues(fitresult);
sigmaX = coefficients(end-1);
sigmaY = coefficients(end);
%% Convert to FWHM
fwhmX = sigmaX*2.355;
fwhmY = sigmaY*2.355;
%% Extract R squared value
rsq = gof.rsquare;