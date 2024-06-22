function countryData = preprocessCountryData()
global pp

% Load data set 1
if ~pp.HS_robustness_check
   load(fullfile(pp.dataFolder, 'cntryyear_pmc.mat'));  % loads struct1
   load(fullfile(pp.dataFolder, 'fig5b.mat'));          % loads Rcpt (+ others)
   mat_file_name = 'countryData.mat';
else
   load(fullfile(pp.dataFolder, 'HS_comparison/cntryyear_pmc_hs.mat')) % loads struct1
   load(fullfile(pp.dataFolder, 'HS_comparison/rcpt.mat'))             % loads Rcpt
   mat_file_name = 'countryData_HS.mat';
end

% Unpack country data
years       = struct1.year';
regionCodes = struct1.region;
A           = struct1.zct_p';
A_m         = struct1.zct_m';
A_c         = struct1.zct_c';
ECIstar     = struct1.ecistar_p';
ECIstar_m   = struct1.ecistar_m';
ECIstar_c   = struct1.ecistar_c';
GDPpc       = struct1.gdppc';
diversity0  = struct1.bindiversity';   % diversity based on RCA > 0 threshold
ECI         = struct1.eci';
gini        = struct1.gini';
shannon     = struct1.shannon';
hhi         = struct1.hhi';
category    = strtrim( string(struct1.label) );

% Convert from character array to cell array of strings
nRegions = size(regionCodes,1);
regionCell = cell(nRegions,1);
for iRegion = 1:nRegions
   regionCell{iRegion} = regionCodes(iRegion,:);
end
regionCodes = regionCell;

% Filter out zeros
mask        = (A ~= 0) & (ECIstar ~= 0);
regionCodes = regionCodes(mask);
years       = years(mask);
GDPpc       = GDPpc(mask);
diversity0  = diversity0(mask);
A           = A(mask);
A_m         = A_m(mask);
A_c         = A_c(mask);
ECIstar     = ECIstar(mask);
ECIstar_m   = ECIstar_m(mask);
ECIstar_c   = ECIstar_c(mask);
ECI         = ECI(mask);

% Compute diversity directly from RCAs using RCA = 1 threshold
diversity   = sum( Rcpt >= 1 )';

% Package everything as a table
countryData = table(regionCodes, years, GDPpc, diversity0, diversity, A, A_m, A_c, ECIstar, ECIstar_m, ECIstar_c, ECI, gini, shannon, hhi, category);

% Store for access by analysis script
file_name = fullfile('./save/', mat_file_name);
save(file_name,'countryData')