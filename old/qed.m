%% QED
%
% Quantitative Edge Detection
% 
% Author :          Quentin CAUDRON
%                   Centre for Complexity Science
%                   D2.05, Mathematics Institute
%                   University of Warwick
%                   Coventry, CV4 7AL, UK
%                   q.caudron@warwick.ac.uk
%                   http://www.quentincaudron.com
%
% Contributors :    John ASTON, Statistics, University of Warwick
%                   Ceri LYN-ADAMS, Biology, University of Warwick
%                   Bruno FRENGUELLI, Biology, University of Warwick
%                   Kevin MOFFAT, Biology, University of Warwick
%
% Maintenance :     http://go.warwick.ac.uk/qcaudron/qed
%                   
%
%
% This code was written with the aim of obtaining quantitative measurements
% for the distortion present in images, specifically applied to models of
% neurodegerative disease, though the idea holds for many biomedical image
% types. 
% This specific implementation was designed to analyse the disorder
% caused in the Drosophila eye when expressing Alzheimer's-related genes
% that alter the surface of the eye, such as Tau protein. It reads in a
% directory that contains .tif images and detects edges in these images
% before extracting information used in measuring the distortion present.
% The edge detection techniques are valid for many biomedial images, but
% the specific measures of distortion calculated here are aimed at the
% phenotypic variations inherent to the Drosophila eye.
% 
%
function q = qed
%
% USAGE :
% This should be executed without any arguments. The user will be guided
% through the required steps.






%% Set Directory

% Clear all
clear all;
close all;


% Define OS-specific slash
slash = '\';
if isempty(strfind(getenv('OS'), 'Windows'))
    slash = '/';
end


% Prompt user for directory
directory = uigetdir;


% Check for .tiff files
dirtiff = ls(strcat(directory, slash, '*.tiff'));


% If present, change them to .tif
for i = 1 : size(dirtiff, 1)
    movefile(strcat(directory, slash, dirtiff(i, :)), ...
        strcat(directory, slash, strrep(dirtiff(i, :), '.tiff', '.tif')));
end


% Get .tif file list
dirlist = ls(strcat(directory, '\*.tif'));


% Set data creation flag
dataCreated = 0;


% OS
q = 0;


% Create Results and Rejected directories
mkdir(strcat(directory, slash, 'Results'));
mkdir(strcat(directory, slash, 'Results', slash, 'Dispersion Coefficients'));
mkdir(strcat(directory, slash, 'Results', slash, 'Raw Data'));
mkdir(strcat(directory, slash, 'Results', slash, 'Raw Data', slash, 'Roundness'));
mkdir(strcat(directory, slash, 'Results', slash, 'Raw Data', slash, 'Distances'));
mkdir(strcat(directory, slash, 'Results', slash, 'Raw Data', slash, 'Angles'));
mkdir(strcat(directory, slash, 'Rejected'));







%% Genotypes

% Attempt to open the genotypes file
fin = fopen(strcat(directory, slash, 'genotypes.qed'), 'rt');


% If this file is not present
if fin < 0
    
    % Prompt for the genotype list
    geno = inputdlg({'Control Genotype', 'Comparison Genotype'}, 'Genotypes');
    
    % Write the genotype list to file
    fout = fopen(strcat(directory, slash, 'genotypes.qed'), 'wt');
    fprintf(fout, strcat(geno{1}, '\n', geno{2}, '\n'));
    
    
    
% If the genotype file exists
else
    
    % Read in the genotypes
    geno{1} = fgetl(fin);
    geno{2} = fgetl(fin);
    
end


% Close file streams
fclose('all');
















%% Edge Detection

% For every .tif file
for i = 1 : size(dirlist, 1)
    
    % Process the image. We aren't interested in results so far - we just
    % want an edge set. This is because certain system operations are
    % slower than these calculations occur, resulting in the code "tripping
    % over itself". This work-around is slower, perhaps up to one second
    % per image, but on the general scale, this is acceptable.
    
    if ~(exist(strcat(directory, '\', strrep(dirlist(i, :), '.tif', '.qed')), 'file') == 2)
        qextract(directory, dirlist(i, :), geno, 0);
    end

    
end
        
    



% Certain images may have been rejected. These take longer to move into
% the Rejected folder than it takes for the code to get to this stage,
% which leads to "File not found" errors. We clear the directory list, and
% start again instead after a period of waiting.

% Display progress bar
resultswait = waitbar(0, 'Preparing to collate edgeset data.');


% Increase progress bar over five seconds
for i = 1 : 50
    waitbar(i / 50);
    pause(0.1);
end


% Remove progress bar
delete(resultswait);
pause(1);


% Reset directory data
clear dirlist;
dirlist = ls(strcat(directory, slash, '*.tif'));
    





% Display new progress bar
progbar = waitbar(0, 'Extracting information from edgesets...');



% Looping over files
for i = 1 : size(dirlist, 1)

%% Centroids

        % Get edge sets, ratios, centroids and genotypes
        [projectededges qratios qcentroids qgenotype] = qextract(directory, dirlist(i, :), geno, 1);

        % Matrix form of centroid point matrix
        qcentroidsmat = cell2mat(qcentroids');

        % Find the central ommatidium
        centralpoint = qcentroidsmat(dsearchn(qcentroidsmat, size(projectededges) / 2), :);



        % Find the six closest ommatidia
        qcentroidsmat(dsearchn(qcentroidsmat, centralpoint)) = 0;

        for j = 1 : 6
            neighbours(j) = dsearchn(qcentroidsmat, centralpoint);
            qcentroidsmat(neighbours(j), :) = 0;
        end



        % Distances between ommatidia
        for j = 1 : 6
            qdistances(j) = sqrt( (centralpoint(1) - qcentroids{neighbours(j)}(1))^2 + (centralpoint(2) - qcentroids{neighbours(j)}(2))^2 );
        end










    %% Angles
    
        % Set vectors about the origin
        for j = 1 : 6
            qvectors(j,:) = qcentroids{neighbours(j)} - centralpoint;
        end



        % Find angles between all vectors, in degrees
        for j = 1 : 6
            for k = 1 : 6
                qangle(j, k) = acos(dot(qvectors(k,:), qvectors(j,:)) / ( norm(qvectors(k,:)) * norm(qvectors(j,:)) )) * 180 / pi;
            end
        end


        % Extract upper triangle of the resulting symmetric matrix
        qangle = qangle(itriu(size(qangle), 1));






    %% Add data to structure

        % Only select relevant angles
        qangle = sort(qangle);
        
        qobject.genotype = qgenotype;
        qobject.ratio = qratios;
        qobject.angle = qangle(1:6);
        qobject.distance = qdistances;


        % Write raw data to file
        csvwrite(strcat(directory, slash, 'Results', slash, 'Raw Data', slash, 'Roundness', slash, dirlist(i, :), '.csv'), qobject.ratio);
        csvwrite(strcat(directory, slash, 'Results', slash, 'Raw Data', slash, 'Distances', slash, dirlist(i, :), '.csv'), qobject.distance');
        csvwrite(strcat(directory, slash, 'Results', slash, 'Raw Data', slash, 'Angles', slash, dirlist(i, :), '.csv'), qobject.angle);
        
        
        % Check for creation flag
        if ~dataCreated
            Data{1} = qobject;
            dataCreated = 1;

        else
            Data = {Data{:}, qobject};

        end

        
        
        % Update progress bar
        waitbar(i / size(dirlist, 1));

end % Looping over files


delete(progbar);
pause(1);










%% Collate data by genotype

% Counters
geno1 = 1;
geno2 = 1;


% Collation
for i = 1 : length(Data)
    
    % If this image was from Genotype 1
    if strcmp(Data{i}.genotype, '1')
        
        % Add the dispersion coefficient to the correct distribution
        uratio{1}(geno1) = qdispersion(Data{i}.ratio);
        udist{1}(geno1) = qdispersion(Data{i}.distance);
        uangle{1}(geno1) = abs(qdispersion(Data{i}.angle));
        
        % Increment counter
        geno1 = geno1 + 1;
        
    elseif strcmp(Data{i}.genotype, '2')
        
        uratio{2}(geno2) = qdispersion(Data{i}.ratio);
        udist{2}(geno2) = qdispersion(Data{i}.distance);
        uangle{2}(geno2) = abs(qdispersion(Data{i}.angle));
        
        geno2 = geno2 + 1;
        
    end
end
        









%% Mann-Whitney ( rank ) test
% This test compares two distributions, each comprised of the dispersion
% coefficients for their specific measure, per genotype.

statRatio = ranksum(uratio{1}, uratio{2});
statAngle = ranksum(uangle{1}, uangle{2});
statDist = ranksum(udist{1}, udist{2});











%% Plots

% Plot cumulative distribution functions for the roundness coefficients

hold all;

[h, diststats{1}] = cdfplot(uratio{1});
[h, diststats{2}] = cdfplot(uratio{2});

grid off;
axis([0 1 0 1]);

expon1 = floor(log10(diststats{1}.std^2));
expon2 = floor(log10(diststats{2}.std^2));

var1 = [num2str( (diststats{1}.std^2) / 10^expon1, 4 ) '\times10^{' num2str(expon1) '}'];
var2 = [num2str( (diststats{2}.std^2) / 10^expon2, 4 ) '\times10^{' num2str(expon2) '}'];

% var1 = num2str(diststats{1}.std^2, '%1.4E');
% var2 = num2str(diststats{2}.std^2, '%1.4E');
% [var11, var12] = strtok(var1, '-');
% [var21, var22] = strtok(var2, '-');
% var1 = strrep(var1, 'E-', '\times10^-');
% var2 = strrep(var2, 'E-', 'x10^-');

legend(strcat(geno{1}, sprintf(' : \nMean='), ...
    num2str(diststats{1}.mean, '%1.4f'), sprintf('\nVar='), var1, sprintf('\n')), ...
    strcat(geno{2}, sprintf(' : \nMean='), ...
    num2str(diststats{2}.mean, '%1.4f'), sprintf('\nVar='), var2, sprintf('\n')));

title(strcat('Cumulative Distribution of Roundness Dispersion Coefficients, p = ', num2str(statRatio)));
xlabel('Roundness Dispersion Coefficient \Delta_R');
ylabel('Cumulative Probability');

lines = get(get(1, 'Children'), 'Children');
set(lines{2}, 'LineWidth', 2);




% %% Plots
% 
% % Plot the Ratio dispersion coefficients
% subplot(3, 1, 1);
% hold all;
% 
% plot(uratio{1}, ones(size(uratio{1})), 'b.');
% plot(uratio{1}, ones(size(uratio{1})), 'bo');
% plot(uratio{2}, zeros(size(uratio{2})), 'r.');
% plot(uratio{2}, zeros(size(uratio{2})), 'ro');
% 
% title({'Roundness Dispersion Coefficients', strcat('P-value = ', num2str(statRatio))});
% axis([0 1 -1 2]);
% set(gca, 'ytick', []);
% 
% 
% % Plot the Distance dispersion coefficients
% subplot(3, 1, 2);
% hold all;
% 
% plot(udist{1}, ones(size(udist{1})), 'b.');
% plot(udist{1}, ones(size(udist{1})), 'bo');
% plot(udist{2}, zeros(size(udist{2})), 'r.');
% plot(udist{2}, zeros(size(udist{2})), 'ro');
% 
% title({'Nearest-Neighbour Distances Dispersion Coefficients', strcat('P-value = ', num2str(statDist))});
% axis([0 1 -1 2]);
% set(gca, 'ytick', []);
% 
% 
% % Plot the Distance dispersion coefficients
% subplot(3, 1, 3);
% hold all;
% 
% plot(uangle{1}, ones(size(uangle{1})), 'b.');
% plot(uangle{1}, ones(size(uangle{1})), 'bo');
% plot(uangle{2}, zeros(size(uangle{2})), 'r.');
% plot(uangle{2}, zeros(size(uangle{2})), 'ro');
% 
% title({'Nearest-Neighbour Angles Dispersion Coefficients', strcat('P-value = ', num2str(statAngle))});
% axis([0 1 -1 2]);
% set(gca, 'ytick', []);





% Maximise data and save plots to file
maximize;

saveas(gcf, strcat(directory, slash, 'Results', slash, geno{1}, '___', geno{2}, '.eps'), 'psc2');
saveas(gcf, strcat(directory, slash, 'Results', slash, geno{1}, '___', geno{2}, '.tif'));






% Print Dispersion Coefficients to files
qresult(uratio, geno, strcat(directory, slash, 'Results', slash, 'Dispersion Coefficients', slash, 'Roundness.csv'));
qresult(udist, geno, strcat(directory, slash, 'Results', slash, 'Dispersion Coefficients', slash, 'Distances.csv'));
qresult(uangle, geno, strcat(directory, slash, 'Results', slash, 'Dispersion Coefficients', slash, 'Angles.csv'));















% Exit successfully
q = 0;






























