function [fitresult, gof] = fit2dGauss(X, Y, fociIm)
%CREATEFIT(X,Y,FOCIIM)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : X
%      Y Input : Y
%      Z Output: fociIm
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 05-Dec-2018 15:04:11


%% Fit: 'untitled fit 1'.
[xData, yData, zData] = prepareSurfaceData( X, Y, fociIm );

% Set up fittype and options.
ft = fittype( 'a*exp(-(((x-mx)^2)/(2*sx^2)+((y-my)^2)/(2*sy^2)))', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0 0 0];
midpoint = (size(fociIm,1)-1)/2;
maxsize = size(fociIm,1);
opts.StartPoint = [max(fociIm(:)) midpoint midpoint 1 1];
opts.Upper = [max(fociIm(:))*2 maxsize maxsize maxsize maxsize];

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );

% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, [xData, yData], zData );
% legend( h, 'untitled fit 1', 'fociIm vs. X, Y', 'Location', 'NorthEast' );
% % Label axes
% xlabel X
% ylabel Y
% zlabel fociIm
% grid on
% view( -0.3, 90.0 );

