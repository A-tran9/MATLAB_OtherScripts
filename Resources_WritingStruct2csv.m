% FileData = load('FileNameThatisMATLABFormat.mat');
% csvwrite('DesiredSpreadsheetName.csv',FileData);

% Won't write, because it has/is a structure, but should work for regular spreadsheets or cells

%Found a web answer of how to write structure to csv  
%https://www.mathworks.com/matlabcentral/answers/158415-saving-a-structure-to-excel

a.b.c.d = rand(16,1);
a.b.c.e = rand(16,1);
my_last_field = fieldnames(a.b.c);
% write the last field values in a single matrix
L = numel(my_last_field);
%number of elements in the fields
my_data = zeros(16,L);
%initialized data variable
for k=1:L
    my_data(:,k) = a.b.c.(my_last_field{k});%my_data=all rows from k column filled with data from original structure, 
                                            % that has last field name k, complete to L fields                                      
end
% write the matrix to excel sheet
xlswrite('text.xls',my_data)