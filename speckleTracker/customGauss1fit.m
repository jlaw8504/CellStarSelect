function [fitresult, gof] = customGauss1fit(X, subY)
%CREATEFIT(X,SUBY)
%  Create a fit.
%
%  Data for '1D Guassian custom' fit:
%      X Input : X
%      Y Output: subY
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 06-Dec-2018 12:08:19


%% Fit: 1D Guassian
%Not using default gauss1 fit since c is not sigma
%a = scaling factor (peak intensity value)
%mu = center position of the curve
%sigma = spread of the curve
[xData, yData] = prepareCurveData( X, subY );

% Set up fittype and options.
ft = fittype( 'a*exp((-1/2)*((x-mu)/sigma)^2)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0];
opts.StartPoint = [max(subY) size(subY)/2 1];
opts.Upper = [max(subY)*3 size(subY) size(subY)];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'subY vs. X', 'untitled fit 1', 'Location', 'NorthEast' );
% % Label axes
% xlabel X
% ylabel subY
% grid on


