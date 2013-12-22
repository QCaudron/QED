%% QEDGESET
% Detects edges using the PLUS filter, then applies a Sobel filter.
% Thanks to Sergei Koptenko of Resonant Medical, Montreal 
% for the vast majority of this implementation.
%
% 
% USAGE :
function edgeset = qedgeset(image_in, gauss_width, gauss_mean, gauss_std, gauss_cutoff, sobel_par, directory, filename, qclahe)
%
% image_in -        2D matrix representing the image
% gauss_width -     width of the Gaussian kernel
% gauss_mean -      mean of the Gaussian kernel
% gauss_std -       standard deviation of the Gaussian function
% gauss_cutoff -    defines where to cut the Gaussian kernel tail. Default
%                   is 3, or 98% of the Gaussian. Larger values lead to
%                   more of the Gaussian being included.
% sobel_par -       Threshold parameter for the Sobel filter




%% Contrast-Limited Adaptive Histogram Equalisation
if qclahe
    image_in = adapthisteq(image_in);
end



%% Disable warnings
image_in = double(image_in); % to avoid warning "CONV2 on values of class UINT8 is obsolete."
warning off MATLAB:divideByZero % some images' pixels may have a_x=0 and a_y=0



%% Kernel Derivatives

% First derivatives
Gx = qgauss2d(gauss_width, gauss_mean, gauss_std, gauss_cutoff);
Gy = Gx';

% Second derivatives
Gxx = conv2(Gx, Gx, 'same');
Gyy = Gxx';
Gxy = conv2(Gx, Gy, 'same');



%% Image Convolutions
Cx = conv2(image_in, Gx, 'same');
Cy = conv2(image_in, Gy, 'same'); 
Cxx = conv2(image_in, Gxx, 'same');
Cyy = conv2(image_in, Gyy, 'same');
Cxy = conv2(image_in, Gxy, 'same');



%% Marr-Hildreth Approximation
edgeset = Cxx + Cyy + ((Cxx .* Cx.^2) + (2 * Cxy .* Cx .* Cy) + (Cyy .* Cy.^2)) ./ (Cx.^2 + Cy.^2);



%% Normalisation of the Edgeset

% Set all NaN and negatives to zero - these occur due to division by zero
edgeset(~isfinite(edgeset)) = 0;
edgeset(edgeset < 0) = 0;

% Normalise
edgeset = 255 .* edgeset ./ max(max(edgeset));



%% Write Marr-Hildreth Image to file
imwrite(edgeset, strcat(directory, '\', filename, '-Files\2-MarrHildreth-edgeset.tif'), 'tif');




%% Sobel Filter

edgeset = logical(bwmorph(bwmorph(edge(edgeset, 'sobel', sobel_par), 'dilate', 2), 'thin', Inf));



%% Write Sobel Image to file
imwrite(edgeset, strcat(directory, '\', filename, '-Files\3-MarrHildreth-Sobel-edgeset.tif'), 'tif');





