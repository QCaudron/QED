%% QDISPERSION
% Measure of dispersion for distribution comparison
%
function qcoefficient = qdispersion(X)
%
% USAGE :
% X is a 1D distribution vector


%% Percentiles
Q95 = prctile(X, 95);
Q5 = prctile(X, 5);


%% Coefficient of Dispersion
qcoefficient = (Q95 - Q5) / (Q95 + Q5);