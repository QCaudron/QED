%% QGAUSS2D
% Computes the derivative of a 2D Gaussian
% Adapted from the work of Sergei Koptenko of Resonant Medical, Montreal 
% for the entirety of this implementation.
%
function gauss2d = qgauss2d(gauss_width, gauss_mean, gauss_std, gauss_cutoff)
%
% USAGE :
% gauss_width -     width of the Gaussian kernel
% gauss_mean -      mean of the Gaussian kernel
% gauss_std -       standard deviation of the Gaussian kernel
% gauss_cutoff -    defines where to cut the Gaussian kernel tail. Default
%                   is 3, or 98% of the Gaussian. Larger values lead to
%                   more of the Gaussian being included.



%% X

gauss_cutoff = ceil(gauss_cutoff * gauss_std); % Correct scaling of the cutoff
x = linspace(-gauss_cutoff, gauss_cutoff, gauss_width); % x range



%% Gaussian

Gaussian = 1 / ( sqrt(2 * pi * gauss_std^2)) * exp( -0.5 * ( (x - gauss_mean) / gauss_std) .^2); % 1D Gaussian
Gaussian = Gaussian / sum(Gaussian); % Normalisation



%% Kernel

gauss1d = (gauss_mean - x) .* Gaussian / gauss_std^2; % First derivative of Gaussian, 1D
gauss1d  = gauss1d  /sum(gauss1d .* (gauss_mean - x)); % Normalisation

gauss2d = conv2(gauss1d, Gaussian', 'full');


