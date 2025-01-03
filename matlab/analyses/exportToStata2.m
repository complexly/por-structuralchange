function countryDataFinal = exportToStata2()
global pp
announceFunction()




%==================================================================%
% Load "regular" countryData (contains GDPpc)
%==================================================================%
% Load countryData
if ~pp.HS_robustness_check
   load(fullfile(pp.saveFolder, 'countryData.mat'))
else
   load(fullfile(pp.saveFolder, 'countryData_HS.mat'))
end

countryData1 = countryData;

% Convert country category column to dummy columns
categoryColumn = categorical(countryData1.category);
dummyColumns   = dummyvar(categoryColumn);

% Tack dummy columns onto existing table
categoryNames = categories(categoryColumn);
dummyColumns  = array2table(dummyColumns, 'VariableNames',categoryNames);
countryData1   = [countryData1, dummyColumns];

% Correct cell arrays in countryCodes column
temp = countryData1.regionCodes;
temp = convertCharsToStrings(temp);
countryData1.regionCodes = temp;

% Label columns better
old_names = ["regionCodes"    "years"    "A"    "A_m"    "A_c"    "ECIstar"    "ECIstar_m"    "ECIstar_c"    "ECI" ];
new_names = ["region"         "year"     "A_p_1962"    "A_m_1962"    "A_c_1962"    "ECIstar_p_1962"    "ECIstar_m_1962"    "ECIstar_c_1962"    "eci_1962"];
countryData1 = renamevars(countryData1, old_names, new_names);


%==================================================================%
% Load "new" countryData (contains additional metrics like Fitness)
%==================================================================%
% Load data
region_year_metric = tdfread('save/region_year_metric.tsv');

region         = region_year_metric.region;
year           = region_year_metric.year;
%diversity      = region_year_metric.kc;           % unneeded, already in countryData1
%A              = region_year_metric.avgrca_p;     % unneeded, already in countryData1
%A_m            = region_year_metric.avgrca_m;     % unneeded, already in countryData1
%A_c            = region_year_metric.avgrca_c;     % unneeded, already in countryData1
%ECIstar        = region_year_metric.proj_p;       % unneeded, already in countryData1
%ECIstar_m      = region_year_metric.proj_m;       % unneeded, already in countryData1
%ECIstar_c      = region_year_metric.proj_c;       % unneeded, already in countryData1
%ECI            = region_year_metric.eci;          % unneeded, already in countryData1  % the more important one: given to frank for stata, used for static comparison of ECI vs. ECI_star in main text figure, used for overrides of ECIstar in phase space plots
eci            = region_year_metric.eci_year;    % equal to eci2016 in 2016. used for metric correlations in 2016. used for metric correlations over time.
fitness        = region_year_metric.fitness_year;  % equal to fitness2016 in 2016. used for metric correlations in 2016. used for metric correlations over time.
% fitness_v2     = region_year_metric.fitness_v2;  % unneeded, used other calc
Xc1            = region_year_metric.xc1;
Xc2            = region_year_metric.xc2;
genepy         = region_year_metric.genepy;
ability        = region_year_metric.ability;
fe             = region_year_metric.fe;
hc             = region_year_metric.hc;
bin            = region_year_metric.bin;
Xc1_times_d    = region_year_metric.x1d;
Xc2_div_sqrt_d = region_year_metric.x2divsqrtd;
% sign           = region_year_metric.sign;        % unneeded


% Package everything as a table
countryData2 = table(region, year, eci, fitness, Xc1, Xc2, genepy, ability, fe, hc, bin, Xc1_times_d, Xc2_div_sqrt_d);

% Correct cell arrays in countryCodes column
temp = countryData2.region;
temp = convertCharsToStrings(cellstr(temp));
countryData2.region = temp;

%==================================================================%
% Temp: Load Yang's new parquet file
%==================================================================%
countryData3 = parquetread(fullfile(pp.saveFolder, 'ecistar_rolling.parquet'));

% Relabel columns
old_names = ["avgrca_p"    "avgrca_m"    "avgrca_c"    "proj_p"    "proj_m"    "proj_c"];
new_names = ["A_p"    "A_m"    "A_c"    "ECIstar_p"    "ECIstar_m"    "ECIstar_c"];
countryData3 = renamevars(countryData3, old_names, new_names);

%==================================================================%
% Merge
%==================================================================%
% Merge
countryData12  = join(countryData1,  countryData2, "Keys",{'region', 'year'});
countryData123 = join(countryData12, countryData3, "Keys",{'region', 'year'});

% Reorder columns
newOrder = [
    % basic vars
    "region"
    "year"
    "GDPpc"
    % our coords, ECI, Fitness
    "A_p"
    "A_m"
    "A_c"
    "ECIstar_p"
    "ECIstar_m"
    "ECIstar_c"
    "eci"
    "fitness"
    % other diversity vars
    "diversity0"
    "diversity"
    "gini"
    "shannon"
    "hhi"
    % country categories
    "category"
    "ldc"
    "oecd"
    "other"
    "resource"
    "taxhaven"
    % other complexity metrics & related quantities
    "Xc1"
    "Xc2"
    "genepy"
    "ability"
    "fe"
    "hc"
    "bin"
    "Xc1_times_d"
    "Xc2_div_sqrt_d"
    % complexity metrics with fixed proximity matrices from 1962
    "A_p_1962"
    "A_m_1962"
    "A_c_1962"
    "ECIstar_p_1962"
    "ECIstar_m_1962"
    "ECIstar_c_1962"
    "eci_1962"
    "fitness_1962"
    ];
countryDataFinal = countryData123(:,newOrder);

% Export
writetable(countryDataFinal, fullfile(pp.saveFolder, 'countryData.csv'))

%todo: clean this up after refactoring coder


