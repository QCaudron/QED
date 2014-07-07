%% QRESULTS
% Parses dispersion coefficients for writing
%
function qresults = qresult(result, genotypes, filename)
%
% USAGE :
% This function takes as its first argument, a 1x2 cell array, with each 
% element containing a vector, and writes the vectors to a CSV file in 
% separate columns. The second argument is the genotype cell array, and the
% third is the file to write to.


%% Open File and Print Column Titles

% Open file-out stream
fout = fopen(filename, 'wt');

% Print titles
fprintf(fout, '%s,%s\n', genotypes{1}, genotypes{2});




%% Print Results

% Print results until shortest column is fully printed
for i = 1 : min(length(result{1}), length(result{2}))
    fprintf(fout, '%f,%f\n', [result{1}(i), result{2}(i)]);
end

% Complete the CSV by filling in the last data points of the longest column
if length(result{1}) > length(result{2})
    for i = length(result{2}) + 1 : length(result{1})
        fprintf(fout, '%f,\n', result{1}(i));
    end
    
elseif length(result{2}) > length(result{1})
    for i = length(result{1}) + 1 : length(result{2})
        fprintf(fout, ',%f\n', result{2}(i));
    end
end



qresults = fclose(fout);