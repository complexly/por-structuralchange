function countryName = countryCodes_to_Names(codeList)

global pp

% Used data importer GUI to go from a csv file to a .mat file
%save(fullfile(pp.dataFolder, 'Code2Country.mat'), 'Code2Country')
load(fullfile(pp.dataFolder, 'Code2Country.mat'))

countryName = table2array( Code2Country( ismember(Code2Country.code, codeList), 'countryName' ) );

if isempty(countryName)
   countryName = '?????';
end