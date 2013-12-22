%% QEXTRACT
% Extracts information from an image. This is the single-image tool that is
% called repeatedly when a directory of images is processed.
% 
% 1. Masks irrelevant background information
% 2. Detects edges
% 3. Projects image onto a curved surface and back onto a plane
% 4. Finds boundary sets for ommatidia
% 5. Calculates boundary to area ratios and geometric centroids
%
function [projectededges qratios qcentroids genotype] = qextract(directory, filename, genolist, calculations)
%
% USAGE :
% directory -   full path
% filename -    name of the image file to process
% genolist -    a list of genotypes, formatted as a cell of strings
%
% OUTPUT :
% projectededges is a binary matrix representing the final edge set
% qratios is a vector containing area-to-perimeter ratios of ommatidia
% qgenotype is the genotype index of the current image
% qcentroids is a cell array, with each cell containing the x- and
% y-coordinates of the geometric centroid of an ommatidia




%% Read image
preimage = imread(strcat(directory, '\', filename), 'tif');









%% Check for existing metadata file

% The metadata file contains the mask information, the genotype and the
% preferred edge detection parameterisation. If it is not present, this
% information will be obtained and the file created.


% If the file has been processed before
if (exist(strcat(directory, '\', strrep(filename, '.tif', '.qed')), 'file') == 2)
    
    % Read the edge data directly from file
    imagedata = dicominfo(strcat(directory, '\', strrep(filename, '.tif', '.qed')));
    genotype = imagedata.Modality;    
    projectededges = uint8(dicomread(imagedata));
    


    
    
    
    
    
    
    
    
    

%% 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% If the file has not been processed before    
else
    
    
    % Prompt user to cut around the eye
    qhandle = msgbox({'Image : ', filename, '',...
        'Please cut around the eye. Include all ommatidia,', ...
        'but as little other parts of the image as possible.'}, 'Define Eye Region');
    waitfor(qhandle);
    
        
    % Generate a mask from the region cutout
    mask = uint8(roipoly(preimage));
    
    
    % Close all figures
    close all;
    close all hidden;
    
    
    % Prompt user to select genotype
    genotype = listdlg('ListString', genolist, 'SelectionMode', 'single', ...
        'Name', 'Select Genotype', 'ListSize', [200 50], 'PromptString', ...
        sprintf('Select the genotype of %s', filename));
    
    
    


    
    
    
    
    

%% Mask the image

    % Mask the pre-image
    preimage = mask .* preimage;


    % Generate vectors of column and row sums of the image matrix
    x = sum(preimage);
    y = sum(preimage');


    % Find the first and last non-zero rows and columns
    xl = find(x > 0, 1, 'first');
    xr = find(x > 0, 1, 'last');
    yl = find(y > 0, 1, 'first');
    yr = find(y > 0, 1, 'last');


    % Crop the image at these rows and columns
    maskedimage = preimage(yl:yr, xl:xr);    


    % Output the masked image for reference
    mkdir(strcat(directory, '\', filename, '-Files'));
    imwrite(maskedimage, strcat(directory, '\', filename, '-Files\1-Masked.tif'), 'tif');







    
    

%% 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Find Edges

    % Process the image using the GUI
    qhandle = QGUI(maskedimage, directory, filename);
    waitfor(qhandle);


    % Close windows
    close all;
    

    % If the user has rejected the image
    if ~exist(strcat(directory, '\temp.qed'), 'file') > 0

        % Move it to the Rejected folder
        movefile(strcat(directory, '\', filename), strcat(directory, '\Rejected'));
        
        % Return empty edgeset
        projectededges = [];
        qratios = [];
        qcentroids = [];
        genotype = [];
        
        
        
        
    % If the user has created an edge set
    else
        
        % Read in the image
        edgeimage = imread(strcat(directory, '\temp.qed'), 'tif');
        
        % Delete the temporary file from the GUI environment
        delete(strcat(directory, '\temp.qed'));

        
        
        
        
        
        
        
        
        
        
%% 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Perspective Projection - To Curved Surface

        % Make image dimensions odd
        if mod(size(edgeimage, 1), 2) == 0
            edgeimage(size(edgeimage, 1) + 1, :) = zeros(1, size(edgeimage, 2));
        end

        if mod(size(edgeimage, 2), 2) == 0
            edgeimage(:, size(edgeimage, 2) + 1) = zeros(size(edgeimage, 1), 1);
        end



        % Create an ellipsoid surface
        qellipsoid = qsurface(floor(size(edgeimage, 2)), floor(size(edgeimage, 1)));


        % Create 3D matrix to receive curved image
        image3d = uint8(zeros(size(edgeimage, 1), size(edgeimage, 2), max(max((qellipsoid)))));


        % Project the image orthographically onto the curved surface
        for x = 1 : size(edgeimage, 1)
            for y = 1 : size(edgeimage, 2)
                image3d(x, y, qellipsoid(x, y) + 1) = edgeimage(x, y);
            end
        end






        %% Perspective Projection - To Plane

        % Define origin of 3D image
        orix = ceil(size(image3d, 1) / 2);
        oriy = ceil(size(image3d, 2) / 2);


        % Define projection distance
        proj = size(image3d, 3) * 10;


        % Calculate projected image size
        newx = (proj + size(image3d, 3)) / proj * ( orix - 1 );
        newx = round(2 * newx) + 1;

        newy = (proj + size(image3d, 3)) / proj * ( oriy - 1 );
        newy = round(2 * newy) + 1;


        % Define new image
        flattened = uint8(zeros(newx, newy));


        % Define projected image's origin
        projx = ceil(size(flattened, 1) / 2);
        projy = ceil(size(flattened, 2) / 2);


        % Loop over slices
        for z = 1 : size(image3d, 3)
            for y = 1 : size(image3d, 2)
                for x = 1 : size(image3d, 1)
                    if image3d(x, y, z) ~= 0
                        thisx = round((proj + size(image3d, 3) - (z - 1)) / proj * ( orix - x ));
                        thisy = round((proj + size(image3d, 3) - (z - 1)) / proj * ( oriy - y ));
                        flattened(projx - thisx + 1, projy - thisy + 1) = image3d(x, y, z);
                    end
                end
            end
        end



        % Final Edge Set matrix
        projectededges = logical(bwmorph(bwmorph(flattened, 'dilate', 1), 'thin', Inf));
        
        
        
        
        
        % Write the edgeset to file
        dicomwrite(projectededges, strcat(directory, '\', strrep(filename, '.tif', '.qed')), 'Modality', int2str(genotype));
        imwrite(projectededges, strcat(directory, '\', filename, '-Files\4-Final-Edgeset.tif'), 'tif');


        
        
    
    
    end  % if user accepted an edgeset
    
end % if a .qed file wasn't found






%% 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Boundary Search and Calculations

% If these calculations are required
if calculations

    % If the image wasn't rejected
    if ~isempty(projectededges)

        % Reject ommatidia if their boundaries are smaller than :
        qreject = 30; % pixels



        % Locate boundaries
        qboundaries = bwboundaries(projectededges);




        % Iterating over boundaries, we calculate their lengths and areas.
        % We start at i = 2, because i = 1 is the boundary around the eye, and is
        % therefore not an ommatidial boundary

        % Preallocate vectors
        qlengths = zeros(length(qboundaries) - 1, 1);
        qareas = zeros(length(qboundaries) - 1, 1);


        % Calculate lengths and areas
        for i = 2 : length(qboundaries)
            if length(qboundaries{i}) > qreject
                qlengths(i-1) = length(qboundaries{i});
                qareas(i-1) = polyarea(qboundaries{i}(:,1), qboundaries{i}(:,2));
            end
        end




        % Remove unclosed loops ( these are very rare )
        for i = 1 : length(qareas)
            if qareas(i) == 0
                qlengths(i) = 0;
            end
        end



        % Make length and area vectors dense
        qlengths = nonzeros(qlengths);
        qareas = nonzeros(qareas);



        % Calculate centroids
        for i = 2 : length(qboundaries)
            qcentroids{i-1} = round(sum(qboundaries{i} / length(qboundaries{i})));
        end



        % Calculate Area-to-Perimeter Ratios (dimensionless)
        qratios = double(4 * pi * qareas ./ (qlengths.^2));




        % Create image matrix
        boundaryimage = zeros(size(projectededges)); % Create matrix

        for i = 2 : length(qboundaries)
            for j = 1 : length(qboundaries{i})
                boundaryimage(qboundaries{i}(j, 1), qboundaries{i}(j, 2)) = 1;
            end % Fill in foreground pixels
        end

        for i = 2 : length(qcentroids)
            boundaryimage(qcentroids{i}(1), qcentroids{i}(2)) = 1;
        end % Fill in centroid pixels



        % Write the image to a file
        mkdir(strcat(directory, '\', filename, '-Files'));
        imwrite(boundaryimage, strcat(directory, '\', filename, '-Files\5-Boundaries-and-Centres.tif'), 'tif');



    end
end % if Calculations are required