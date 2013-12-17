%% QSURFACE
% Produces a hemiellipsoidal surface for use in projection of the image
%
function projsurface = qsurface(x, y)
%
% USAGE :
% The arguments are the x and y dimensions of the required curved surface.
% Curvature is empirically measured. The curvature can be changed by
% altering the z-elevation parameter.



%% Variable Rescaling
x = x / 2;
y = y / 2;



%% Z-Elevation

% A higher number will lead to a greater curvature.
% This constant was parameterised empirically by measurements taken from
% SEM images of the Drosophila eye when expressing only the GMR driver.
z = y * 0.4865;



%% Hemiellipsoidal Surface

% Grid
[xgrid ygrid] = meshgrid( (-x : x), (-y : y) );

% Surface
projsurface = round( real( sqrt( z^2 * (1 - ( xgrid./x ).^2 - ( ygrid./y ).^2))));


